extends Node

signal finished

var main_ref: Node
var ending_id: String = ""
var finished_once := false


func start(main_node: Node) -> void:
	main_ref = main_node

	_run_ending()


func _run_ending() -> void:
	ending_id = _calculate_ending()

	main_ref.start_vn("endings", ending_id)

	await main_ref.dialogue_box.dialogue_finished

	_finalize_run(ending_id)


func _calculate_ending() -> String:
	var s1 = GameState.get_stage_choice(1)
	var s2 = GameState.get_stage_choice(2)
	var s3 = GameState.get_stage_choice(3)

	var e1 = "a" if s1 == "choice_stage1_a" else "b"
	var e2 = "a" if s2 == "choice_stage2_a" else "b"
	var e3 = "a" if s3 == "choice_stage3_a" else "b"

	return e1 + e2 + e3


func _finalize_run(id: String) -> void:
	if finished_once:
		return
	finished_once = true

	var first_time: bool = !GameState.has_ending(ending_id)

	GameState.unlock_ending(ending_id)

	main_ref.show_victory_screen(ending_id, first_time)

	await main_ref.victory_closed

	_reset_game_state()

	main_ref.return_to_menu()
	finished.emit()
	

func _reset_game_state():
	GameState.clear_plot_choices()
	GameState.bullet_heaven_run_state.clear()

	GameState.clear_stage_choice(1)
	GameState.clear_stage_choice(2)
	GameState.clear_stage_choice(3)

	if main_ref.campaign_runner:
		main_ref.campaign_runner.queue_free()
		main_ref.campaign_runner = null

	get_tree().paused = false

# func notify_vn_finished(_result = null) -> void:
# 	_finalize_run(ending_id)
