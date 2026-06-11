extends SceneTree

const BHAudio = preload("res://bullet_heaven/scripts/BHAudio.gd")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var audio = BHAudio.new()
	root.add_child(audio)
	await process_frame

	_expect(AudioServer.get_bus_index(&"Music") >= 0, "Music bus should exist")
	_expect(AudioServer.get_bus_index(&"SFX") >= 0, "SFX bus should exist")
	for cue_name in BHAudio.SFX_PATHS.keys():
		var path: String = BHAudio.SFX_PATHS[cue_name]
		_expect(ResourceLoader.exists(path), "Missing sound effect: %s" % path)
		var stream := load(path) as AudioStream
		_expect(stream != null and stream.get_length() > 0.0, "Invalid sound effect: %s" % path)
		_expect(audio.play_sfx(cue_name), "Audio manager could not play: %s" % cue_name)

	var music_path: String = BHAudio.MUSIC_PATHS["theme"]
	_expect(ResourceLoader.exists(music_path), "Missing Bullet Heaven theme: %s" % music_path)
	_expect(audio.play_music("theme"), "Audio manager could not play the Bullet Heaven theme")
	_expect(audio.music_player.playing, "Bullet Heaven theme should be playing")
	var music_stream := audio.music_player.stream as AudioStreamOggVorbis
	_expect(music_stream != null and music_stream.loop, "Bullet Heaven theme should loop")
	audio.stop_music()
	audio.stop_all_sfx()
	await create_timer(1.0).timeout
	audio.free()
	audio = null
	await create_timer(0.1).timeout

	if failures.is_empty():
		print("Bullet Heaven audio tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
