extends Node

signal finished

var main_ref: Node
var flow: Array = []
var index: int = 0
var active := false
var last_choice_id: String = ""
var stage3_heaven_state: Dictionary = {}


func start(main_node: Node) -> void:
	main_ref = main_node
	last_choice_id = ""

	GameState.clear_stage_choice(3)
	stage3_heaven_state = GameState.bullet_heaven_run_state.duplicate(true)

	flow = [
		{"type": "vn", "id": "stage3_intro"},
		{"type": "heaven"},
		{"type": "vn", "id": "stage3_pre_boss"},
		{"type": "boss", "which": "C"},
		{"type": "vn", "id": "stage3_post_boss"},
	]

	index = 0
	active = true
	_run_next()


func _run_next() -> void:
	if index >= flow.size():
		finished.emit()
		return

	var step = flow[index]
	index += 1

	match step.type:
		"vn":
			main_ref.start_vn(step.id, last_choice_id)

		"heaven":
			main_ref.start_bullet_heaven("stage3", stage3_heaven_state, "stage_3_bullet_heaven")

		"boss":
			main_ref.start_boss_test(step.which, "stage_3_bullet_hell")


func notify_vn_finished(result) -> void:
	if typeof(result) == TYPE_DICTIONARY and result.has("choice"):
		last_choice_id = str(result.get("choice", ""))

		if not last_choice_id.is_empty():
			GameState.set_stage_choice(3, last_choice_id)
			GameState.set_plot_choice(last_choice_id)

	_run_next()


func notify_heaven_finished(result) -> void:
	if result == "lose":
		index -= 1
	_run_next()


func notify_boss_finished(result) -> void:
	if result == "lose":
		index -= 1
	_run_next()