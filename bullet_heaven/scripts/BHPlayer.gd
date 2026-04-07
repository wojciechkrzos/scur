extends Area2D

signal player_died
signal shot_spawned(shot: Node2D)

const BHShotScript = preload("res://bullet_heaven/scripts/BHShot.gd")

enum FirePattern {
	AIMED_FAN,
	RADIAL_RING
}

@export var speed: float = 230.0
@export var max_lives: int = 3
@export var pattern_switch_interval: float = 10.0

var lives: int = 3
var is_alive: bool = true
var is_invincible: bool = false
var fight_active: bool = true
var play_area: Rect2
var bullet_container: Node2D
var current_pattern: FirePattern = FirePattern.AIMED_FAN
var ring_phase: float = 0.0
var anchor_position: Vector2 = Vector2.ZERO
var pattern_elapsed: float = 0.0

const INVINCIBILITY_DURATION := 1.2

@onready var shoot_timer = $ShootTimer
@onready var invincibility_timer = $InvincibilityTimer
@onready var sprite = $PlayerSprite

func setup(area: Rect2, bullet_cont: Node2D) -> void:
	play_area = area
	bullet_container = bullet_cont
	lives = max_lives
	is_alive = true
	is_invincible = false
	fight_active = true
	visible = true
	collision_layer = 2
	collision_mask = 1
	anchor_position = area.get_center()
	position = anchor_position
	current_pattern = FirePattern.AIMED_FAN
	pattern_elapsed = 0.0

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

func _spawn_shot(direction: Vector2, shot_speed: float) -> void:
	var shot = BHShotScript.new()
	shot.position = position
	shot.direction = direction
	shot.speed = shot_speed
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

func get_pattern_name() -> String:
	if current_pattern == FirePattern.AIMED_FAN:
		return "AIMED FAN"
	return "RADIAL RING"

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
