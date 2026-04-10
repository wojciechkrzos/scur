extends Node2D

@export var debug_mode: String = "stage1"  # "loop", "heaven", "vn", "boss", "stage1"

#debug stage 1 na jutrzejszy pokaz
const Stage1Flow = preload("res://Stage1Flow.gd")
var stage1_runner: Node = null

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
			return preload("res://data/dialogues/stage1_post_boss.gd").new().get_lines(choice_id)
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
	dialogue_box.start_dialogue(data)
	dialogue_box.dialogue_finished.connect(_on_vn_finished)
	
func _on_vn_finished(result):
	# print("VN finished, choice:", result.get("choice", ""))

	# start_boss_test("B")
	print("VN finished")

	if stage1_runner:
		stage1_runner.notify_vn_finished(result)
	else:
		start_boss_test("B")


#METODY DO BULLET HEAVEN
func _on_heaven_finished(result):
	print("Heaven ended:", result)

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if stage1_runner:
		stage1_runner.notify_heaven_finished(result)
	else:
		start_vn("test")


func start_bullet_heaven() -> void:
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	var heaven_scene = preload("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var heaven = heaven_scene.instantiate()
	add_child(heaven)
	current_stage = heaven
	heaven.fight_ended.connect(_on_heaven_finished)


#METODY DO BOSSA

func _on_boss_finished(result):
	print("Boss ended:", result)

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	if stage1_runner:
		stage1_runner.notify_boss_finished(result)
	
func start_boss_test(which: String = "A"):
	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

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
	stage1_runner.start(self)

func _ready() -> void:
	pause_menu.resume_pressed.connect(_close_pause)
	set_process_input(true)
	set_process_unhandled_input(true)

	print("MAIN READY")

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
			start_boss_test("B")
