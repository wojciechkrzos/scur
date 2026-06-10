extends Node

const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

const MUSIC_PATHS := {
	"theme": "res://assets/audio/music/bullet_heaven_theme.ogg",
	"level_up": "res://assets/audio/music/bullet_heaven_level_up.ogg",
	"victory": "res://assets/audio/music/bullet_heaven_victory.ogg",
	"defeat": "res://assets/audio/music/bullet_heaven_defeat.ogg",
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
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = &"Music"
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
		return false
	var stream := load(path) as AudioStream
	if stream == null:
		return false
	if music_player.stream == stream and music_player.playing:
		return true
	music_player.stream = stream
	music_player.play()
	return true

func stop_music() -> void:
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
