extends Node

const SETTINGS_PATH := "user://audio_settings.cfg"
const UI_CLICK_PATH := "res://assets/audio/sfx/ui_click.wav"
const PLAYER_HIT_PATH := "res://assets/audio/sfx/player_hit.wav"

var _ui_player: AudioStreamPlayer
var _hit_player: AudioStreamPlayer
var _hooked_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_player = _make_player("UIClickPlayer", UI_CLICK_PATH, 8)
	_hit_player = _make_player("PlayerHitPlayer", PLAYER_HIT_PATH, 4)
	get_tree().node_added.connect(_on_node_added)
	_load_settings()
	call_deferred("_hook_existing_buttons")


func play_ui_click() -> void:
	if _ui_player != null:
		_ui_player.play()


func play_player_hit() -> void:
	if _hit_player != null:
		_hit_player.play()


func set_music_volume(value: float) -> void:
	_set_bus_volume(&"Music", value)
	_save_settings()


func set_sfx_volume(value: float) -> void:
	_set_bus_volume(&"SFX", value)
	_save_settings()


func get_music_volume() -> float:
	return _get_bus_volume(&"Music")


func get_sfx_volume() -> float:
	return _get_bus_volume(&"SFX")


func _make_player(player_name: String, path: String, polyphony: int) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = &"SFX"
	player.max_polyphony = polyphony
	if ResourceLoader.exists(path):
		player.stream = load(path) as AudioStream
	add_child(player)
	return player


func _on_node_added(node: Node) -> void:
	if node is Button:
		call_deferred("_hook_button", node)


func _hook_existing_buttons() -> void:
	_hook_buttons_recursive(get_tree().root)


func _hook_buttons_recursive(node: Node) -> void:
	if node is Button:
		_hook_button(node)
	for child in node.get_children():
		_hook_buttons_recursive(child)


func _hook_button(button: Button) -> void:
	if not is_instance_valid(button):
		return
	var instance_id := button.get_instance_id()
	if _hooked_buttons.has(instance_id):
		return
	_hooked_buttons[instance_id] = true
	button.pressed.connect(play_ui_click)
	button.tree_exited.connect(_forget_button.bind(instance_id), CONNECT_ONE_SHOT)


func _forget_button(instance_id: int) -> void:
	_hooked_buttons.erase(instance_id)


func _set_bus_volume(bus_name: StringName, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var normalized := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, normalized <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(normalized, 0.001)))


func _get_bus_volume(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0 or AudioServer.is_bus_mute(bus_index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_index)), 0.0, 1.0)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	_set_bus_volume(&"Music", float(config.get_value("audio", "music", get_music_volume())))
	_set_bus_volume(&"SFX", float(config.get_value("audio", "sfx", get_sfx_volume())))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", get_music_volume())
	config.set_value("audio", "sfx", get_sfx_volume())
	config.save(SETTINGS_PATH)
