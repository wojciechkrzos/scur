extends Node

const SETTINGS_PATH := "user://audio_settings.cfg"
const UI_CLICK_PATH := "res://assets/audio/sfx/ui_click.wav"
const PLAYER_HIT_PATH := "res://assets/audio/sfx/player_hit.wav"
const DEFAULT_MUSIC_VOLUME := 0.75
const DEFAULT_SFX_VOLUME := 0.5
const MIN_LOADED_MUSIC_VOLUME := 0.05
const MUSIC_GAIN_DB := 0.0
const PROCEDURAL_MIX_RATE := 22050.0
const PROCEDURAL_BULLET_HELL_NOTES := [43.65, 43.65, 51.91, 38.89, 43.65, 58.27, 51.91, 38.89]
const PROCEDURAL_BULLET_HELL_LEAD := [0, 3, 7, 10, 12, 10, 7, 3, 0, -2, 3, 7, 10, 7, 3, -2]
const PROCEDURAL_VN_CHORDS := [
	[55.0, 65.41, 82.41, 110.0],
	[51.91, 61.74, 77.78, 103.83],
	[48.99, 58.27, 73.42, 98.0],
	[43.65, 55.0, 65.41, 87.31],
]

var _music_player: AudioStreamPlayer
var _music_tween: Tween
var _procedural_playback: AudioStreamGeneratorPlayback
var _procedural_cue: String = ""
var _procedural_time: float = 0.0
var _ui_player: AudioStreamPlayer
var _hit_player: AudioStreamPlayer
var _hooked_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = _make_music_player()
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


func play_music_path(path: String, loop: bool = true, target_volume_db: float = 0.0, fade_seconds: float = 0.0) -> bool:
	_ensure_music_player()
	if path.is_empty() or not ResourceLoader.exists(path):
		return false
	var audible_target_db := target_volume_db + MUSIC_GAIN_DB
	var stream := load(path) as AudioStream
	if stream == null:
		return false
	_stop_procedural_music()
	_configure_music_loop(stream, loop)
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if _music_player.stream == stream and _music_player.playing:
		_music_player.volume_db = audible_target_db
		return true
	_music_player.stream = stream
	if fade_seconds > 0.0:
		_music_player.volume_db = -24.0
	else:
		_music_player.volume_db = audible_target_db
	_music_player.play()
	if fade_seconds > 0.0:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", audible_target_db, fade_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return true


func play_procedural_music(cue_name: String, target_volume_db: float = 0.0, fade_seconds: float = 0.0) -> bool:
	_ensure_music_player()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = PROCEDURAL_MIX_RATE
	stream.buffer_length = 0.5
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_player.stream = stream
	if fade_seconds > 0.0:
		_music_player.volume_db = -24.0
	else:
		_music_player.volume_db = target_volume_db + MUSIC_GAIN_DB
	_music_player.play()
	_procedural_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if _procedural_playback == null:
		_stop_procedural_music()
		return false
	_procedural_cue = cue_name
	_procedural_time = 0.0
	if fade_seconds > 0.0:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", target_volume_db + MUSIC_GAIN_DB, fade_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_fill_procedural_buffer()
	return true


func stop_music(fade_seconds: float = 0.0) -> void:
	if _music_player == null or not _music_player.playing:
		return
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if fade_seconds <= 0.0:
		_stop_procedural_music()
		_music_player.stop()
		return
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -24.0, fade_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_music_tween.tween_callback(_music_player.stop)
	_music_tween.tween_callback(_stop_procedural_music)


func get_music_player() -> AudioStreamPlayer:
	_ensure_music_player()
	return _music_player


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


func _make_music_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = "GlobalMusicPlayer"
	player.bus = &"Music"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player


func _ensure_music_player() -> void:
	if _music_player != null and is_instance_valid(_music_player):
		return
	_music_player = _make_music_player()


func _configure_music_loop(stream: AudioStream, loop: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED


func _process(_delta: float) -> void:
	_fill_procedural_buffer()


func _fill_procedural_buffer() -> void:
	if _procedural_playback == null or _procedural_cue.is_empty():
		return
	var frames_available := _procedural_playback.get_frames_available()
	for _frame in frames_available:
		var sample := _sample_procedural_music(_procedural_time)
		_procedural_playback.push_frame(Vector2(sample, sample))
		_procedural_time += 1.0 / PROCEDURAL_MIX_RATE


func _sample_procedural_music(t: float) -> float:
	if _procedural_cue == "bullet_hell":
		return _sample_bullet_hell_music(t)
	return _sample_vn_music(t)


func _sample_bullet_hell_music(t: float) -> float:
	var beat := fmod(t * 150.0 / 60.0, 1.0)
	var step := int(floor(t * 150.0 / 60.0)) % 16
	var note_index := int(step / 2) % PROCEDURAL_BULLET_HELL_NOTES.size()
	var bass_note := float(PROCEDURAL_BULLET_HELL_NOTES[note_index])
	var gate := 1.0 if beat < 0.48 else 0.18
	var kick := exp(-beat * 34.0) * sin(TAU * (54.0 + 90.0 * exp(-beat * 20.0)) * t)
	var bass := 0.25 * _square_wave(bass_note, t) + 0.14 * _saw_wave(bass_note * 2.0, t)
	var lead_step := int(PROCEDURAL_BULLET_HELL_LEAD[step])
	var lead_freq := 174.61 * pow(2.0, float(lead_step) / 12.0)
	var lead := 0.12 * _saw_wave(lead_freq, t) * gate
	var hat_phase := fmod(t * 300.0 / 60.0, 1.0)
	var hat := 0.0
	if hat_phase < 0.055:
		hat = _noise(t) * exp(-hat_phase * 58.0) * 0.08
	var drone := 0.08 * sin(TAU * 21.83 * t) + 0.05 * sin(TAU * 65.41 * t + 0.6)
	return clampf(0.36 * kick + bass * gate + lead + hat + drone, -0.72, 0.72)


func _sample_vn_music(t: float) -> float:
	var chord_index := int(floor(t / 4.5)) % PROCEDURAL_VN_CHORDS.size()
	var chord: Array = PROCEDURAL_VN_CHORDS[chord_index]
	var pad := 0.0
	for index in chord.size():
		var freq := float(chord[index])
		pad += sin(TAU * freq * t + float(index) * 0.7) * (0.08 / float(index + 1))
		pad += sin(TAU * freq * 2.005 * t + float(index)) * (0.03 / float(index + 1))
	var pulse_phase := fmod(t * 62.0 / 60.0, 1.0)
	var pulse := exp(-pulse_phase * 7.0) * sin(TAU * 110.0 * t) * 0.045
	var shimmer := sin(TAU * 523.25 * t) * (0.018 + 0.015 * sin(TAU * 0.08 * t))
	return clampf(pad + pulse + shimmer, -0.55, 0.55)


func _square_wave(freq: float, t: float) -> float:
	return 1.0 if sin(TAU * freq * t) >= 0.0 else -1.0


func _saw_wave(freq: float, t: float) -> float:
	return 2.0 * fmod(freq * t, 1.0) - 1.0


func _noise(t: float) -> float:
	return sin(TAU * 127.1 * t) * sin(TAU * 311.7 * t + 0.31)


func _stop_procedural_music() -> void:
	_procedural_playback = null
	_procedural_cue = ""


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
		_set_bus_volume(&"Music", DEFAULT_MUSIC_VOLUME)
		_set_bus_volume(&"SFX", DEFAULT_SFX_VOLUME)
		return
	var music_volume := float(config.get_value("audio", "music", DEFAULT_MUSIC_VOLUME))
	if music_volume < MIN_LOADED_MUSIC_VOLUME:
		music_volume = DEFAULT_MUSIC_VOLUME
	_set_bus_volume(&"Music", music_volume)
	_set_bus_volume(&"SFX", float(config.get_value("audio", "sfx", DEFAULT_SFX_VOLUME)))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", get_music_volume())
	config.set_value("audio", "sfx", get_sfx_volume())
	config.save(SETTINGS_PATH)
