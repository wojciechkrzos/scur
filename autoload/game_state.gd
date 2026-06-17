extends Node

signal state_changed(old_state, new_state)

const SCORE_PATH := "user://score_log.cfg"

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
var score_log := {
	"best_total_score": 0,
	"best_enemies_killed": 0,
	"best_minutes_played": 0.0,
	"best_xp_gained": 0,
	"runs_played": 0,
}

func _ready() -> void:
	load_score_log()

func load_score_log() -> void:
	var config := ConfigFile.new()
	if config.load(SCORE_PATH) != OK:
		return
	score_log["best_total_score"] = int(config.get_value("scores", "best_total_score", score_log["best_total_score"]))
	score_log["best_enemies_killed"] = int(config.get_value("scores", "best_enemies_killed", score_log["best_enemies_killed"]))
	score_log["best_minutes_played"] = float(config.get_value("scores", "best_minutes_played", score_log["best_minutes_played"]))
	score_log["best_xp_gained"] = int(config.get_value("scores", "best_xp_gained", score_log["best_xp_gained"]))
	score_log["runs_played"] = int(config.get_value("scores", "runs_played", score_log["runs_played"]))

func record_run_score(enemies_killed: int, minutes_played: float, xp_gained: int, bonus_score: int = 0) -> void:
	var total_score := enemies_killed * 100 + int(round(minutes_played * 60.0)) * 5 + xp_gained * 25 + bonus_score
	score_log["best_total_score"] = maxi(int(score_log.get("best_total_score", 0)), total_score)
	score_log["best_enemies_killed"] = maxi(int(score_log.get("best_enemies_killed", 0)), maxi(enemies_killed, 0))
	score_log["best_minutes_played"] = maxf(float(score_log.get("best_minutes_played", 0.0)), maxf(minutes_played, 0.0))
	score_log["best_xp_gained"] = maxi(int(score_log.get("best_xp_gained", 0)), maxi(xp_gained, 0))
	score_log["runs_played"] = int(score_log.get("runs_played", 0)) + 1
	_save_score_log()

func get_score_log() -> Dictionary:
	return score_log.duplicate(true)

func _save_score_log() -> void:
	var config := ConfigFile.new()
	for key in score_log.keys():
		config.set_value("scores", String(key), score_log[key])
	config.save(SCORE_PATH)

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
