extends Area2D

signal player_died
signal shot_spawned(shot: Node2D)
signal experience_changed(current_xp: int, current_level: int, xp_to_next: int)
signal leveled_up(new_level: int)

const BHShotScript = preload("res://bullet_heaven/scripts/BHShot.gd")
const BHAoEPulseScript = preload("res://bullet_heaven/scripts/BHAoEPulse.gd")
const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

enum FirePattern {
	AIMED_FAN,
	RADIAL_RING,
	AOE_PULSE,
	VERTICAL_JET,
	SPIRAL_STREAM,
}

const BASE_SPEED := 230.0
const BASE_MAX_LIVES := 3
const BASE_SHOOT_INTERVAL := 0.2

@export var speed: float = 230.0
@export var max_lives: int = 3
@export var pattern_switch_interval: float = 10.0

var lives: int = 3
var experience_points: int = 0
var level: int = 1
var xp_to_next_level: int = 5
var is_alive: bool = true
var is_invincible: bool = false
var fight_active: bool = true
var play_area: Rect2
var bullet_container: Node2D
var current_pattern: FirePattern = FirePattern.AIMED_FAN
var ring_phase: float = 0.0
var spiral_phase: float = 0.0
var anchor_position: Vector2 = Vector2.ZERO
var pattern_elapsed: float = 0.0

const INVINCIBILITY_DURATION := 1.2

@onready var shoot_timer = $ShootTimer
@onready var invincibility_timer = $InvincibilityTimer
@onready var sprite = $PlayerSprite

func setup(area: Rect2, bullet_cont: Node2D) -> void:
	play_area = area
	bullet_container = bullet_cont
	speed = BASE_SPEED
	max_lives = BASE_MAX_LIVES
	lives = max_lives
	experience_points = 0
	level = 1
	xp_to_next_level = 5
	is_alive = true
	is_invincible = false
	fight_active = true
	visible = true
	collision_layer = 2
	collision_mask = 1 | 4
	anchor_position = area.get_center()
	position = anchor_position
	current_pattern = FirePattern.AIMED_FAN
	pattern_elapsed = 0.0
	ring_phase = 0.0
	spiral_phase = 0.0
	shoot_timer.wait_time = BASE_SHOOT_INTERVAL
	_update_experience_ui()

	if not shoot_timer.timeout.is_connected(_shoot_burst):
		shoot_timer.timeout.connect(_shoot_burst)
	if not invincibility_timer.timeout.is_connected(_end_invincibility):
		invincibility_timer.timeout.connect(_end_invincibility)

	shoot_timer.start()

func _process(delta: float) -> void:
	if not fight_active or not is_alive:
		return
	position = anchor_position
	_update_pattern_timer(delta)

func _shoot_burst() -> void:
	if not fight_active or not is_alive:
		return

	if current_pattern == FirePattern.AIMED_FAN:
		_fire_aimed_fan()
	elif current_pattern == FirePattern.AOE_PULSE:
		_fire_aoe_pulse()
	elif current_pattern == FirePattern.VERTICAL_JET:
		_fire_vertical_jet()
	elif current_pattern == FirePattern.SPIRAL_STREAM:
		_fire_spiral_stream()
	else:
		_fire_radial_ring()

func _fire_aimed_fan() -> void:
	var base_angle := -PI * 0.5
	var offsets := [-0.28, -0.14, 0.0, 0.14, 0.28]
	for off in offsets:
		_spawn_shot(Vector2.from_angle(base_angle + off), 360.0)

func _fire_radial_ring() -> void:
	var count := 8
	for i in count:
		var angle := ring_phase + TAU * float(i) / float(count)
		_spawn_shot(Vector2.from_angle(angle), 320.0)
	ring_phase += 0.2

func _fire_aoe_pulse() -> void:
	var pulse = BHAoEPulseScript.new()
	pulse.anchor_ref = self
	pulse.damage = 1
	pulse.global_position = global_position
	pulse.add_to_group("bh_player_attack")
	shot_spawned.emit(pulse)

func _fire_vertical_jet() -> void:
	var offsets := [-8.0, 0.0, 8.0]
	for offset_x in offsets:
		var shot = BHShotScript.new()
		shot.position = position + Vector2(offset_x, 0.0)
		shot.direction = Vector2.UP
		shot.speed = 420.0
		shot.damage = 1
		shot.add_to_group("bh_player_bullet")
		shot_spawned.emit(shot)

func _fire_spiral_stream() -> void:
	var count := 5
	for i in count:
		var angle := spiral_phase + float(i) * 0.35
		var shot = BHShotScript.new()
		shot.position = position
		shot.direction = Vector2.from_angle(angle)
		shot.speed = 340.0
		shot.damage = 1
		shot.add_to_group("bh_player_bullet")
		shot_spawned.emit(shot)
	spiral_phase += 0.24

func _spawn_shot(direction: Vector2, shot_speed: float) -> void:
	var shot = BHShotScript.new()
	shot.position = position
	shot.direction = direction
	shot.speed = shot_speed
	shot.damage = 1
	shot.add_to_group("bh_player_bullet")
	shot_spawned.emit(shot)

func take_hit() -> void:
	if is_invincible or not is_alive:
		return
	lives -= 1
	if lives <= 0:
		is_alive = false
		visible = false
		player_died.emit()
		return
	_start_invincibility()

func _start_invincibility() -> void:
	is_invincible = true
	sprite.modulate.a = 0.4
	invincibility_timer.start(INVINCIBILITY_DURATION)

func _end_invincibility() -> void:
	is_invincible = false
	sprite.modulate.a = 1.0

func add_experience(amount: int) -> void:
	if amount <= 0:
		return

	experience_points += amount
	while experience_points >= xp_to_next_level:
		experience_points -= xp_to_next_level
		level += 1
		xp_to_next_level = 5 + (level - 1) * 3
		leveled_up.emit(level)

	_update_experience_ui()

func apply_powerup(powerup_id: int) -> void:
	match powerup_id:
		BHPowerups.PowerupId.WEAPON_1:
			_set_weapon_pattern(FirePattern.AOE_PULSE)
		BHPowerups.PowerupId.WEAPON_2:
			_set_weapon_pattern(FirePattern.VERTICAL_JET)
		BHPowerups.PowerupId.WEAPON_3:
			_set_weapon_pattern(FirePattern.SPIRAL_STREAM)
		BHPowerups.PowerupId.SPEEDUP:
			speed = min(speed + 30.0, 420.0)
		BHPowerups.PowerupId.SHIELD:
			max_lives += 1
			lives = min(lives + 1, max_lives)
		_:
			pass

	_update_experience_ui()

func _set_weapon_pattern(pattern: FirePattern) -> void:
	current_pattern = pattern
	pattern_elapsed = 0.0
	match current_pattern:
		FirePattern.AIMED_FAN:
			shoot_timer.wait_time = 0.2
		FirePattern.RADIAL_RING:
			shoot_timer.wait_time = 0.26
		FirePattern.AOE_PULSE:
			shoot_timer.wait_time = 0.45
		FirePattern.VERTICAL_JET:
			shoot_timer.wait_time = 0.12
		FirePattern.SPIRAL_STREAM:
			shoot_timer.wait_time = 0.16

func _update_experience_ui() -> void:
	experience_changed.emit(experience_points, level, xp_to_next_level)

func get_pattern_name() -> String:
	match current_pattern:
		FirePattern.AIMED_FAN:
			return "AIMED FAN"
		FirePattern.RADIAL_RING:
			return "RADIAL RING"
		FirePattern.AOE_PULSE:
			return "WEAPON 1"
		FirePattern.VERTICAL_JET:
			return "WEAPON 2"
		FirePattern.SPIRAL_STREAM:
			return "WEAPON 3"
		_:
			return "UNKNOWN"

func get_move_input() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1
	return dir.normalized() if dir != Vector2.ZERO else Vector2.ZERO

func _update_pattern_timer(delta: float) -> void:
	pattern_elapsed += delta
	if pattern_elapsed < pattern_switch_interval:
		return

	pattern_elapsed = 0.0
	if current_pattern == FirePattern.AIMED_FAN:
		current_pattern = FirePattern.RADIAL_RING
	else:
		current_pattern = FirePattern.AIMED_FAN
