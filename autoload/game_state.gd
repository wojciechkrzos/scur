extends Node

signal state_changed(old_state, new_state)

enum State {
	MENU,
	BULLET_HEAVEN,
	BULLET_HELL,
	VISUAL_NOVEL,
	PAUSED,
	GAME_OVER
}

var current_state: State = State.MENU
var previous_state: State = State.MENU
var stage1_choice: String = ""
var stage2_choice: String = ""
var stage3_choice: String = ""
var bullet_heaven_run_state: Dictionary = {}
var debug_skip_gameplay: Dictionary = {
	"stage_1_bullet_heaven": false,
	"stage_1_bullet_hell": false,
	"stage_2_bullet_heaven": false,
	"stage_2_bullet_hell": false,
}
var plot_choices: Dictionary = {}

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	var old_state := current_state
	previous_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)

func enter_visual_novel() -> void:
	change_state(State.VISUAL_NOVEL)

func return_from_visual_novel() -> void:
	change_state(previous_state)

func is_combat_state() -> bool:
	return current_state == State.BULLET_HEAVEN or current_state == State.BULLET_HELL

func is_player_control_enabled() -> bool:
	return is_combat_state()

func is_visual_novel_state() -> bool:
	return current_state == State.VISUAL_NOVEL

func set_stage_choice(stage_index: int, choice_id: String) -> void:
	match stage_index:
		1:
			stage1_choice = choice_id
		2:
			stage2_choice = choice_id
		3:
			stage3_choice = choice_id
		_:
			return

func get_stage_choice(stage_index: int, default_value: String = "") -> String:
	match stage_index:
		1:
			return stage1_choice if not stage1_choice.is_empty() else default_value
		2:
			return stage2_choice if not stage2_choice.is_empty() else default_value
		3:
			return stage3_choice if not stage3_choice.is_empty() else default_value
		_:
			return default_value

func clear_stage_choice(stage_index: int) -> void:
	match stage_index:
		1:
			stage1_choice = ""
		2:
			stage2_choice = ""
		3:
			stage3_choice = ""
		_:
			return

func set_plot_choice(choice_id: String, value: Variant = true) -> void:
	if choice_id.is_empty():
		return
	plot_choices[choice_id] = value
	if choice_id == "choice_fight" or choice_id == "choice_join":
		set_stage_choice(1, choice_id)
	elif choice_id == "s2_save" or choice_id == "s2_understand":
		set_stage_choice(2, choice_id)

func has_plot_choice(choice_id: String) -> bool:
	return plot_choices.has(choice_id)

func get_plot_choice(choice_id: String, default_value: Variant = null) -> Variant:
	if plot_choices.has(choice_id):
		return plot_choices[choice_id]
	return default_value

func clear_plot_choices() -> void:
	stage1_choice = ""
	stage2_choice = ""
	stage3_choice = ""
	plot_choices.clear()

func should_skip_gameplay(stage_key: String) -> bool:
	return bool(debug_skip_gameplay.get(stage_key, false))
