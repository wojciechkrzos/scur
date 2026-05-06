extends Node2D

@export var debug_mode: String = "stage1"  # "loop", "heaven", "vn", "boss", "stage1"
@export var debug_config_path: String = "res://debug_config.json"
@export var debug_skip_overrides: Dictionary = {}

#debug stage 1 na jutrzejszy pokaz
const Stage1Flow = preload("res://Stage1Flow.gd")
const Stage2Flow = preload("res://Stage2Flow.gd")
const StartMenuScene = preload("res://ui/StartMenu.tscn")
const UI_FONT_PATH = "res://assets/fonts/PixelifySans-VariableFont_wght.ttf"
var stage1_runner: Node = null
var stage2_runner: Node = null
var start_menu: CanvasLayer = null
var ui_theme: Theme = null

@onready var pause_menu = $PauseMenu

@onready var dialogue_box = $DialogueBox

var current_stage: Node = null

#loader dialogow, TODO poprawić to bo nie bedziemy wszystkiego tak ladowac chyba? moze do osobnego pliku
func load_dialogue(id: String, choice_id: String = ""):
	match id:
		"test":
			return preload("res://data/dialogues/test.gd").new().get_lines()
		"tutorial":
			return preload("res://data/dialogues/tutorial.gd").new().get_lines()
		"stage1_pre_boss":
			return preload("res://data/dialogues/stage1_pre_boss.gd").new().get_lines()
		"stage1_post_boss":
			return preload("res://data/dialogues/stage1_post_boss.gd").new().get_lines(GameState.get_stage_choice(1, choice_id))
		"stage2_intro":
			return preload("res://data/dialogues/stage2_intro.gd").new().get_lines()
		"stage2_pre_boss":
			return preload("res://data/dialogues/stage2_pre_boss.gd").new().get_lines(GameState.get_stage_choice(1, choice_id))
		"stage2_post_boss":
			return preload("res://data/dialogues/stage2_post_boss.gd").new().get_lines(GameState.get_stage_choice(1), GameState.get_stage_choice(2))
	return []

#metody do pausemenu

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

func _unhandled_input(event):
	if is_instance_valid(start_menu) and start_menu.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		print("ESC OK")
		if get_tree().paused:
			_close_pause()
		else:
			_open_pause()


#METODY DO VN
func start_vn(id: String, choice_id: String = ""):
	var data = load_dialogue(id, choice_id)  # ← przekaż
	if dialogue_box.dialogue_finished.is_connected(_on_vn_finished):
		dialogue_box.dialogue_finished.disconnect(_on_vn_finished)
	if dialogue_box.has_method("set_dialogue_context"):
		dialogue_box.set_dialogue_context(id)
	dialogue_box.start_dialogue(data)
	dialogue_box.dialogue_finished.connect(_on_vn_finished)
	
func _on_vn_finished(result):
	# print("VN finished, choice:", result.get("choice", ""))

	# start_boss_test("B")
	print("VN finished")

	if stage2_runner:
		stage2_runner.notify_vn_finished(result)
	elif stage1_runner:
		stage1_runner.notify_vn_finished(result)
	else:
		start_boss_test("B")


#METODY DO BULLET HEAVEN
func _on_heaven_finished(result):
	print("Heaven ended:", result)

	if is_instance_valid(current_stage) and current_stage.has_method("get_run_state"):
		GameState.bullet_heaven_run_state = current_stage.get_run_state()

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if stage2_runner:
		stage2_runner.notify_heaven_finished(result)
	elif stage1_runner:
		stage1_runner.notify_heaven_finished(result)
	else:
		start_vn("test")


func start_bullet_heaven(stage_profile: String = "stage1", run_state: Dictionary = {}, debug_stage_key: String = "") -> void:
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if not debug_stage_key.is_empty():
		var should_skip := GameState.should_skip_gameplay(debug_stage_key)
		print("[DEBUG] start_bullet_heaven key=", debug_stage_key, " value=", should_skip)
		if should_skip:
			# if a run_state was supplied, ensure it's preserved when skipping
			if run_state and typeof(run_state) == TYPE_DICTIONARY and run_state.size() > 0:
				GameState.bullet_heaven_run_state = run_state.duplicate(true)
			call_deferred("_on_heaven_finished", "win")
			return

	var heaven_scene = preload("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var heaven = heaven_scene.instantiate()
	if heaven.has_method("configure_stage"):
		heaven.configure_stage(stage_profile, run_state)
	add_child(heaven)
	current_stage = heaven
	heaven.fight_ended.connect(_on_heaven_finished)


#METODY DO BOSSA

func _on_boss_finished(result):
	print("Boss ended:", result)

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if stage2_runner:
		stage2_runner.notify_boss_finished(result)
	elif stage1_runner:
		stage1_runner.notify_boss_finished(result)
	
func start_boss_test(which: String = "A", debug_stage_key: String = ""):
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if not debug_stage_key.is_empty():
		var should_skip := GameState.should_skip_gameplay(debug_stage_key)
		print("[DEBUG] start_boss_test key=", debug_stage_key, " value=", should_skip)
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


#na przyszlosc
#stages = [
	#{"type": "vn", "id": "test"},
	#{"type": "boss", "id": "B"}
#]

func _start_stage1():
	stage1_runner = Stage1Flow.new()
	add_child(stage1_runner)
	stage1_runner.finished.connect(_on_stage1_flow_finished)
	stage1_runner.start(self)

func _start_stage2() -> void:
	stage2_runner = Stage2Flow.new()
	add_child(stage2_runner)
	stage2_runner.finished.connect(_on_stage2_flow_finished)
	stage2_runner.start(self)

func _on_stage1_flow_finished() -> void:
	if is_instance_valid(stage1_runner):
		stage1_runner.queue_free()
	stage1_runner = null
	_start_stage2()

func _on_stage2_flow_finished() -> void:
	if is_instance_valid(stage2_runner):
		stage2_runner.queue_free()
	stage2_runner = null

func _start_debug_flow() -> void:
	if debug_mode == "stage1":
		_start_stage1()
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
			_start_stage1()

func _on_start_pressed() -> void:
	if is_instance_valid(start_menu):
		start_menu.queue_free()
		start_menu = null
	_start_debug_flow()

func _load_ui_font() -> FontFile:
	var font_resource := load(UI_FONT_PATH)
	if font_resource is FontFile:
		return font_resource as FontFile
	push_warning("UI font could not be loaded from: %s" % UI_FONT_PATH)
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

	var pause_vbox := pause_menu.get_node_or_null("VBoxContainer") as Control
	if pause_vbox != null:
		pause_vbox.theme = ui_theme

func _ready() -> void:
	pause_menu.resume_pressed.connect(_close_pause)
	set_process_input(true)
	set_process_unhandled_input(true)

	var ui_font := _load_ui_font()
	_apply_ui_theme_to_controls(ui_font)

	# Load debug config from project root if present, otherwise apply inspector overrides
	if debug_config_path != "":
		var tried_paths := []
		# check both the given path and the globalized filesystem path
		var candidate1 := debug_config_path
		var candidate2 := ProjectSettings.globalize_path(debug_config_path)
		tried_paths.append(candidate1)
		tried_paths.append(candidate2)
		var found_path := ""
		for p in tried_paths:
			if FileAccess.file_exists(p):
				found_path = p
				break
		if found_path != "":
			print("Found debug config at:", found_path)
			var f := FileAccess.open(found_path, FileAccess.READ)
			if f:
				var text := f.get_as_text()
				print("Debug config contents:\n", text)
				# Try parsing robustly: normal parse, then try removing BOM or trimming
				var parse_attempts := [text, text.strip_edges(true, true), text.replace("\uFEFF", "")]
				var parse_error_code: int = -1
				var parse_result_var: Variant = null
				for attempt_text in parse_attempts:
					var p = JSON.parse_string(attempt_text)
					var err = int(p.get("error", -1))
					var res = p.get("result", null)
					print("JSON parse attempt error=", err, " result_type=", typeof(res))
					if err == OK and typeof(res) == TYPE_DICTIONARY:
						parse_error_code = err
						parse_result_var = res
						break
						break
				if parse_error_code == OK and typeof(parse_result_var) == TYPE_DICTIONARY:
					var parse_result: Dictionary = parse_result_var
					# Merge loaded config with existing defaults to avoid missing keys
					var merged := GameState.debug_skip_gameplay.duplicate(true)
					for k in parse_result.keys():
						merged[k] = parse_result[k]
					GameState.debug_skip_gameplay = merged
					print("Loaded debug config:", found_path, "->", GameState.debug_skip_gameplay)
				else:
					print("Failed to parse debug config: ", found_path, " error=", parse_error_code)
					# Diagnostic: show first bytes to detect BOM/encoding issues
					var bytes: PackedByteArray = text.to_utf8_buffer()
					var sample: Array = []
					for i in range(min(bytes.size(), 32)):
						sample.append(str(int(bytes[i])))
					print("Debug config bytes (first 32):", sample)
					# Fallback: naive extractor for boolean flags (handles simple JSON maps)
					var fallback: Dictionary = {}
					for key in GameState.debug_skip_gameplay.keys():
						var key_str: String = str(key)
						var kstr: String = '"' + key_str + '"'
						var pos: int = text.find(kstr)
						if pos != -1:
							var colon: int = text.find(":", pos + kstr.length())
							if colon != -1:
								var rest: String = text.substr(colon + 1, 64)
								rest = rest.strip_edges(true, true)
								var end := rest.find(",")
								if end == -1:
									end = rest.find("}")
								var token: String = rest
								if end != -1:
									token = rest.substr(0, end)
								token = token.strip_edges(true, true).to_lower()
								if token.find("true") != -1:
									fallback[key_str] = true
								elif token.find("false") != -1:
									fallback[key_str] = false
					if fallback.size() > 0:
						var merged2 := GameState.debug_skip_gameplay.duplicate(true)
						for k in fallback.keys():
							merged2[k] = fallback[k]
						GameState.debug_skip_gameplay = merged2
						print("Fallback parsed debug config ->", GameState.debug_skip_gameplay)
					else:
						push_warning("Failed to parse debug config: %s (error=%d)" % [found_path, parse_error_code])
				f.close()
		elif debug_skip_overrides.size() > 0:
			GameState.debug_skip_gameplay = debug_skip_overrides.duplicate(true)
			print("Applied debug overrides from main inspector")
	elif debug_skip_overrides.size() > 0:
		GameState.debug_skip_gameplay = debug_skip_overrides.duplicate(true)
		print("Applied debug overrides from main inspector")

	# show final effective debug map for troubleshooting
	print("Effective GameState.debug_skip_gameplay:", GameState.debug_skip_gameplay)

	print("MAIN READY")
	start_menu = StartMenuScene.instantiate()
	add_child(start_menu)
	var start_root := start_menu.get_node_or_null("Root") as Control
	if start_root != null and ui_theme != null:
		start_root.theme = ui_theme
	start_menu.start_pressed.connect(_on_start_pressed)
