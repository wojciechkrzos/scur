extends Node

const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

const MUSIC_PATHS := {
	"theme": "res://assets/audio/music/bullet_heaven_theme.ogg",
	"bullet_hell": "res://assets/audio/music/bullet_hell_dark_adrenaline.wav",
	"level_up": "res://assets/audio/music/bullet_heaven_level_up.ogg",
	"victory": "res://assets/audio/music/bullet_heaven_victory.ogg",
	"defeat": "res://assets/audio/music/bullet_heaven_defeat.ogg",
}

const MUSIC_VOLUME_DB := {
	"theme": 0.0,
	"bullet_hell": 3.0,
	"level_up": 0.0,
	"victory": 0.0,
	"defeat": 0.0,
}

const SFX_PATHS := {
	"weapon_impulse": "res://assets/audio/sfx/weapon_impulse.wav",
	"weapon_vertical_jet": "res://assets/audio/sfx/weapon_vertical_jet.wav",
	"weapon_spiral": "res://assets/audio/sfx/weapon_spiral.wav",
	"weapon_homing_missile": "res://assets/audio/sfx/weapon_homing_missile.wav",
	"weapon_molotov_throw": "res://assets/audio/sfx/weapon_molotov_throw.wav",
	"weapon_molotov_explosion": "res://assets/audio/sfx/weapon_molotov_explosion.wav",
	"weapon_fan_burst": "res://assets/audio/sfx/weapon_fan_burst.wav",
	"swarm_warning": "res://assets/audio/sfx/swarm_warning.wav",
	"swarm_spawn": "res://assets/audio/sfx/swarm_spawn.wav",
}

const WEAPON_SFX := {
	BHPowerups.WeaponId.AOE_PULSE: "weapon_impulse",
	BHPowerups.WeaponId.VERTICAL_JET: "weapon_vertical_jet",
	BHPowerups.WeaponId.SPIRAL_STREAM: "weapon_spiral",
	BHPowerups.WeaponId.HOMING_MISSILE: "weapon_homing_missile",
	BHPowerups.WeaponId.MOLOTOV_BOMB: "weapon_molotov_throw",
	BHPowerups.WeaponId.FAN_BURST: "weapon_fan_burst",
}

var music_player: AudioStreamPlayer
var sfx_players: Dictionary[String, AudioStreamPlayer] = {}

func _ready() -> void:
	_ensure_music_player()

func _ensure_music_player() -> void:
	if music_player != null and is_instance_valid(music_player):
		return
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = &"Music"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)

func play_weapon(weapon_id: int) -> void:
	var cue_name: String = String(WEAPON_SFX.get(weapon_id, ""))
	if not cue_name.is_empty():
		play_sfx(cue_name)

func play_sfx(cue_name: String) -> bool:
	var player := _get_sfx_player(cue_name)
	if player == null:
		return false
	player.play()
	return true

func play_music(cue_name: String) -> bool:
	var path: String = String(MUSIC_PATHS.get(cue_name, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		if cue_name == "bullet_hell":
			return play_music("theme")
		return false
	var should_loop := cue_name == "theme" or cue_name == "bullet_hell"
	var cue_volume_db := float(MUSIC_VOLUME_DB.get(cue_name, 0.0))
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("play_music_path"):
		if cue_name == "bullet_hell" and audio_manager.has_method("play_procedural_music"):
			if bool(audio_manager.play_procedural_music("bullet_hell", cue_volume_db, 0.0)):
				if audio_manager.has_method("get_music_player"):
					music_player = audio_manager.get_music_player()
				return true
		if bool(audio_manager.play_music_path(path, should_loop, cue_volume_db, 0.0)):
			if audio_manager.has_method("get_music_player"):
				music_player = audio_manager.get_music_player()
			return true
	_ensure_music_player()
	var stream := load(path) as AudioStream
	if stream == null:
		return false
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = should_loop
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED
	if music_player.stream == stream and music_player.playing:
		music_player.volume_db = cue_volume_db
		return true
	music_player.stream = stream
	music_player.volume_db = cue_volume_db
	music_player.play()
	return true

func stop_music() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("stop_music"):
		audio_manager.stop_music()
		return
	if music_player != null:
		music_player.stop()

func stop_all_sfx() -> void:
	for player in sfx_players.values():
		player.stop()

func _get_sfx_player(cue_name: String) -> AudioStreamPlayer:
	if sfx_players.has(cue_name):
		return sfx_players[cue_name]

	var path: String = String(SFX_PATHS.get(cue_name, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var stream := load(path) as AudioStream
	if stream == null:
		return null

	var player := AudioStreamPlayer.new()
	player.name = "SFX_%s" % cue_name
	player.bus = &"SFX"
	player.max_polyphony = 8
	player.stream = stream
	add_child(player)
	sfx_players[cue_name] = player
	return player
