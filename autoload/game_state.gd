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
var stage_choices := {
	1: "",
	2: "",
	3: ""
}
var bullet_heaven_run_state: Dictionary = {}
var debug_skip_gameplay: Dictionary = {}
var plot_choices: Dictionary = {}
var unlocked_endings: Dictionary = {}

func unlock_ending(id: String):
	unlocked_endings[id] = true

func has_ending(id: String) -> bool:
	return unlocked_endings.has(id)

func load_debug_config(path: String) -> void:
	if !FileAccess.file_exists(path):
		push_warning("Debug config not found: " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()

	var json := JSON.new()
	var err := json.parse(text)

	if err != OK:
		push_error("Cannot parse debug config")
		return

	debug_skip_gameplay = json.data

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

func set_stage_choice(stage: int, choice_id: String) -> void:
	stage_choices[stage] = choice_id

func get_stage_choice(stage: int) -> String:
	return stage_choices.get(stage, "")

func clear_stage_choice(stage: int) -> void:
	stage_choices[stage] = ""

# func set_plot_choice(choice_id: String, value: Variant = true) -> void:
# 	if choice_id.is_empty():
# 		return
# 	plot_choices[choice_id] = value
# 	if choice_id == "choice_stage1_a" or choice_id == "choice_stage1_b":
# 		set_stage_choice(1, choice_id)
# 	elif choice_id == "s2_save" or choice_id == "s2_understand":
# 		set_stage_choice(2, choice_id)

func set_plot_choice(choice_id: String) -> void:
	if choice_id.is_empty():
		return

	plot_choices[choice_id] = true

	if choice_id.begins_with("choice_stage1_"):
		set_stage_choice(1, choice_id)

	elif choice_id.begins_with("choice_stage2_"):
		set_stage_choice(2, choice_id)

	elif choice_id.begins_with("choice_stage3_"):
		set_stage_choice(3, choice_id)

func has_plot_choice(choice_id: String) -> bool:
	return plot_choices.has(choice_id)

func get_plot_choice(choice_id: String, default_value: Variant = null) -> Variant:
	if plot_choices.has(choice_id):
		return plot_choices[choice_id]
	return default_value

func clear_plot_choices() -> void:
	stage_choices[1] = ""
	stage_choices[2] = ""
	stage_choices[3] = ""
	plot_choices.clear()

func should_skip_gameplay(stage_key: String) -> bool:
	var result := bool(debug_skip_gameplay.get(stage_key, false))
	print("DEBUG SKIP:", stage_key, " => ", result)
	return result
