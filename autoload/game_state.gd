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
