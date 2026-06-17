extends Node2D

@export var debug_mode: String = "stage1"

const StartMenuScene = preload("res://ui/StartMenu.tscn")
const UI_FONT_PATH = "res://assets/fonts/PixelifySans-VariableFont_wght.ttf"
const CampaignFlow = preload("res://CampaignFlow.gd")
const MAIN_MENU_MUSIC_PATH = "res://assets/audio/music/main_menu_theme.ogg"
var campaign_runner: Node = null
var start_menu: CanvasLayer = null
var ui_theme: Theme = null
var menu_music_player: AudioStreamPlayer = null

@onready var pause_menu = $PauseMenu
@onready var dialogue_box = $DialogueBox

var current_stage: Node = null

signal victory_closed



# ─────────────────────────────
# DIALOGUES
# ─────────────────────────────
func load_dialogue(id: String, choice_id: String = ""):
	match id:
		"test":
			return preload("res://data/dialogues/test.gd").new().get_lines()
		"tutorial":
			return preload("res://data/dialogues/tutorial.gd").new().get_lines()
		"stage1_pre_boss":
			return preload("res://data/dialogues/stage1_pre_boss.gd").new().get_lines()
		"stage1_post_boss":
			return preload("res://data/dialogues/stage1_post_boss.gd").new().get_lines(choice_id)
		"stage2_intro":
			return preload("res://data/dialogues/stage2_intro.gd").new().get_lines()
		"stage2_pre_boss":
			return preload("res://data/dialogues/stage2_pre_boss.gd").new().get_lines()
		"stage2_post_boss":
			return preload("res://data/dialogues/stage2_post_boss.gd").new().get_lines(choice_id)
		"stage3_intro":
			return preload("res://data/dialogues/stage3_intro.gd").new().get_lines()
		"stage3_pre_boss":
			return preload("res://data/dialogues/stage3_pre_boss.gd").new().get_lines()
		"stage3_post_boss":
			return preload("res://data/dialogues/stage3_post_boss.gd").new().get_lines(choice_id)
		"endings":
			return preload("res://data/dialogues/endings.gd").new().get_lines(choice_id)
	return []


func show_victory_screen(ending_id: String, is_new: bool):
	var scene = preload("res://ui/EndingUnlocked.tscn")
	var ui = scene.instantiate()

	add_child(ui)

	ui.show_result(ending_id, is_new)

	ui.closed.connect(func():
		victory_closed.emit()
	)

func apply_ui_to_menu():
	var ui_font := _load_ui_font()
	if ui_font == null:
		return

	var root := start_menu.get_node_or_null("Root") as Control
	if root:
		var theme := Theme.new()
		theme.default_font = ui_font
		theme.default_font_size = 24
		root.theme = theme


func return_to_menu():
	get_tree().paused = false
	pause_menu.visible = false
	if dialogue_box.has_method("stop_dialogue"):
		dialogue_box.stop_dialogue()

	if campaign_runner:
		campaign_runner.queue_free()
		campaign_runner = null

	if current_stage:
		current_stage.queue_free()
		current_stage = null

	if start_menu == null:
		start_menu = StartMenuScene.instantiate()
		add_child(start_menu)
		apply_ui_to_menu()
		start_menu.start_pressed.connect(_on_start_pressed)
	else:
		start_menu.visible = true

	if menu_music_player != null and not menu_music_player.playing:
		menu_music_player.play()


# ─────────────────────────────
# PAUSE
# ─────────────────────────────
func get_current_tutorial() -> Dictionary:
	if current_stage == null:
		return Tutorials.TUTORIALS["vn"]

	if current_stage.has_method("get_stage_type"):
		var type = current_stage.get_stage_type()
		return Tutorials.TUTORIALS.get(type, Tutorials.TUTORIALS["vn"])

	return Tutorials.TUTORIALS["vn"]


func _open_pause():
	var data = get_current_tutorial()
	pause_menu.show_menu(data.tutorial, data.objective)


func _close_pause():
	get_tree().paused = false
	pause_menu.visible = false


func _return_to_main_menu() -> void:
	return_to_menu()


func _unhandled_input(event):
	if is_instance_valid(start_menu) and start_menu.visible:
		return

	if event.is_action_pressed("ui_cancel"):
		if not get_tree().paused:
			_open_pause()
			get_viewport().set_input_as_handled()


# ─────────────────────────────
# VN
# ─────────────────────────────
func start_vn(id: String, choice_id: String = ""):
	var data = load_dialogue(id, choice_id)

	if dialogue_box.dialogue_finished.is_connected(_on_vn_finished):
		dialogue_box.dialogue_finished.disconnect(_on_vn_finished)

	if dialogue_box.has_method("set_dialogue_context"):
		dialogue_box.set_dialogue_context(id)

	dialogue_box.start_dialogue(data)
	dialogue_box.dialogue_finished.connect(_on_vn_finished)


func _on_vn_finished(result):
	print("VN RESULT RAW:", result)
	if campaign_runner and campaign_runner.current_runner and "notify_vn_finished" in campaign_runner.current_runner:
		campaign_runner.current_runner.notify_vn_finished(result)


# ─────────────────────────────
# BULLET HEAVEN
# ─────────────────────────────
func _on_heaven_finished(result):
	if is_instance_valid(current_stage) and current_stage.has_method("get_run_state"):
		GameState.bullet_heaven_run_state = current_stage.get_run_state()

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if campaign_runner:
		campaign_runner.current_runner.notify_heaven_finished(result)
	else:
		start_vn("test")


func start_bullet_heaven(stage_profile: String = "stage1", run_state: Dictionary = {}, debug_stage_key: String = "") -> void:
	print("CHECKING:", debug_stage_key)
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if not debug_stage_key.is_empty():
		var should_skip := GameState.should_skip_gameplay(debug_stage_key)
		if should_skip:
			if run_state and typeof(run_state) == TYPE_DICTIONARY and run_state.size() > 0:
				GameState.bullet_heaven_run_state = run_state.duplicate(true)
			call_deferred("_on_heaven_finished", "win")
			return

	var heaven_scene = preload("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var heaven = heaven_scene.instantiate()

	var backdrop = heaven.get_node_or_null("BHBackdrop")
	if backdrop and backdrop.has_method("set_stage"):
		backdrop.set_stage(stage_profile)
	

	if heaven.has_method("configure_stage"):
		heaven.configure_stage(stage_profile, run_state)

	add_child(heaven)
	current_stage = heaven
	heaven.fight_ended.connect(_on_heaven_finished)


# ─────────────────────────────
# BOSS
# ─────────────────────────────
func _on_boss_finished(result):
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if campaign_runner:
		campaign_runner.current_runner.notify_boss_finished(result)


func start_boss_test(which: String = "A", debug_stage_key: String = ""):
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if not debug_stage_key.is_empty():
		var should_skip := GameState.should_skip_gameplay(debug_stage_key)
		if should_skip:
			call_deferred("_on_boss_finished", "win")
			return

	var boss_scene = preload("res://bullet_hell/scenes/BossFight.tscn")
	var boss = boss_scene.instantiate()

	add_child(boss)
	current_stage = boss

	boss.fight_ended.connect(_on_boss_finished)

	match which:
		"A":
			boss.start_fight(boss.BOSS_A)
		"B":
			boss.start_fight(boss.BOSS_B)
		"C":
			boss.start_fight(boss.BOSS_C)


# ─────────────────────────────
# FLOW START
# ─────────────────────────────
func _start_campaign() -> void:
	campaign_runner = CampaignFlow.new()
	add_child(campaign_runner)
	campaign_runner.finished.connect(_on_campaign_finished)
	campaign_runner.start(self)


func _on_campaign_finished() -> void:
	if is_instance_valid(campaign_runner):
		campaign_runner.queue_free()
	campaign_runner = null

	print("CAMPAIGN FINISHED")


# ─────────────────────────────
# DEBUG ENTRY
# ─────────────────────────────
func _start_debug_flow() -> void:
	if debug_mode == "stage1":
		_start_campaign()
		return

	match debug_mode:
		"loop":
			start_bullet_heaven()
		"heaven":
			start_bullet_heaven()
		"vn":
			start_vn("test")
		"boss":
			start_boss_test("A")
		_:
			_start_campaign()


func _on_start_pressed() -> void:
	if menu_music_player != null:
		menu_music_player.stop()
	if is_instance_valid(start_menu):
		start_menu.queue_free()
		start_menu = null

	_start_debug_flow()

# ─────────────────────────────
# UI + READY
# ─────────────────────────────

func _setup_menu_music() -> void:
	if not ResourceLoader.exists(MAIN_MENU_MUSIC_PATH):
		return

	var stream := load(MAIN_MENU_MUSIC_PATH) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true

	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.name = "MenuMusicPlayer"
	menu_music_player.bus = &"Music"
	menu_music_player.stream = stream
	add_child(menu_music_player)
	menu_music_player.play()

func _load_ui_font() -> FontFile:
	var font_resource := load(UI_FONT_PATH)
	if font_resource is FontFile:
		return font_resource as FontFile
	return null


func _apply_ui_theme_to_controls(font: FontFile) -> void:
	if font == null:
		return

	ThemeDB.fallback_font = font
	ThemeDB.fallback_font_size = 24

	ui_theme = Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 24

	var dialogue_root := dialogue_box.get_node_or_null("Root") as Control
	if dialogue_root != null:
		dialogue_root.theme = ui_theme

	var pause_panel := pause_menu.get_node_or_null("CenterPanel") as Control
	if pause_panel != null:
		pause_panel.theme = ui_theme


func _ready() -> void:

	GameState.load_debug_config("res://debug_config.json")
	pause_menu.resume_pressed.connect(_close_pause)
	pause_menu.main_menu_pressed.connect(_return_to_main_menu)

	set_process_input(true)
	set_process_unhandled_input(true)

	var ui_font := _load_ui_font()
	_apply_ui_theme_to_controls(ui_font)

	print("MAIN READY")
	_setup_menu_music()
	start_menu = StartMenuScene.instantiate()
	add_child(start_menu)

	var start_root := start_menu.get_node_or_null("Root") as Control
	if start_root != null and ui_theme != null:
		start_root.theme = ui_theme

	start_menu.start_pressed.connect(_on_start_pressed)
