extends Node

signal finished

var main_ref: Node = null

var flow: Array = []
var index: int = 0
var active := false
var last_choice_id: String = ""
var stage2_heaven_state: Dictionary = {}


func start(main_node: Node) -> void:
	main_ref = main_node
	last_choice_id = ""
	GameState.clear_stage_choice(2)
	GameState.clear_stage_choice(3)
	stage2_heaven_state = GameState.bullet_heaven_run_state.duplicate(true)

	flow = [
		{"type": "vn", "id": "stage2_intro"},
		{"type": "heaven"},
		{"type": "vn", "id": "stage2_pre_boss"},
		{"type": "boss", "which": "B"},
		{"type": "vn", "id": "stage2_post_boss"},
	]

	index = 0
	active = true

	_run_next()


func _run_next() -> void:
	if not active:
		return

	if index >= flow.size():
		active = false
		finished.emit()
		return

	var step = flow[index]
	index += 1

	match step.type:
		"vn":
			_run_vn(step.id)
		"heaven":
			_run_heaven()
		"boss":
			_run_boss(step.which)


func _run_vn(id: String) -> void:
	main_ref.start_vn(id, last_choice_id)


func _run_heaven() -> void:
	main_ref.start_bullet_heaven("stage2", stage2_heaven_state, "stage_2_bullet_heaven")


func _run_boss(which: String) -> void:
	main_ref.start_boss_test(which, "stage_2_bullet_hell")


func notify_vn_finished(_result = null) -> void:
	if typeof(_result) == TYPE_DICTIONARY and _result.has("choice"):
		last_choice_id = str(_result.get("choice", ""))
		if not last_choice_id.is_empty():
			GameState.set_stage_choice(2, last_choice_id)
			GameState.set_plot_choice(last_choice_id)
	_run_next()


func _run_same_step() -> void:
	active = true

	var step = flow[index - 1]
	match step.type:
		"heaven":
			_run_heaven()
		"boss":
			_run_boss(step.which)


func notify_heaven_finished(result: String = "win") -> void:
	_cleanup_stage()

	if result == "lose":
		_run_same_step()
		return

	_run_next()


func notify_boss_finished(result: String = "win") -> void:
	_cleanup_stage()

	if result == "lose":
		_run_same_step()
		return

	_run_next()


func _cleanup_stage() -> void:
	if main_ref and is_instance_valid(main_ref.current_stage):
		main_ref.current_stage.queue_free()
		main_ref.current_stage = null
