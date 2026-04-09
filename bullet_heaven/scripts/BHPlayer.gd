extends Area2D

signal player_died
signal shot_spawned(shot: Node2D)
signal experience_changed(current_xp: int, current_level: int, xp_to_next: int)
signal leveled_up(new_level: int)

const BHShotScript = preload("res://bullet_heaven/scripts/BHShot.gd")
const BHAoEPulseScript = preload("res://bullet_heaven/scripts/BHAoEPulse.gd")
const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

const BASE_SPEED := 230.0
const BASE_MAX_LIVES := 3
const BASE_SHOOT_INTERVAL := 0.8
const MAX_PLAYER_SPEED := 420.0

@export var speed: float = 230.0
@export var max_lives: int = 3

var lives: int = 3
var experience_points: int = 0
var level: int = 1
var xp_to_next_level: int = 5
var is_alive: bool = true
var is_invincible: bool = false
var fight_active: bool = true
var play_area: Rect2
var bullet_container: Node2D
var active_weapons: Array[int] = []
var spiral_phase: float = 0.0
var anchor_position: Vector2 = Vector2.ZERO

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
	active_weapons = [BHPowerups.WeaponId.AOE_PULSE]
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

func _shoot_burst() -> void:
	if not fight_active or not is_alive:
		return

	for weapon_id in active_weapons:
		_fire_weapon(weapon_id)

func _fire_weapon(weapon_id: int) -> void:
	var weapon_data := BHPowerups.get_weapon_definition(weapon_id)
	if weapon_data.is_empty():
		return

	match String(weapon_data.get("fire_mode", "")):
		"aoe_pulse":
			_fire_aoe_pulse(weapon_data)
		"vertical_jet":
			_fire_vertical_jet(weapon_data)
		"spiral_stream":
			_fire_spiral_stream(weapon_data)
		_:
			pass

func _fire_aoe_pulse(weapon_data: Dictionary) -> void:
	var pulse = BHAoEPulseScript.new()
	pulse.anchor_ref = self
	pulse.damage = int(weapon_data.get("damage", 1))
	pulse.lifetime = float(weapon_data.get("lifetime", pulse.lifetime))
	pulse.position = position
	pulse.add_to_group("bh_player_attack")
	shot_spawned.emit(pulse)

func _fire_vertical_jet(weapon_data: Dictionary) -> void:
	var offsets: Array = weapon_data.get("offsets", [0.0])
	for raw_offset in offsets:
		_spawn_bullet(
			position + Vector2(float(raw_offset), 0.0),
			Vector2.UP,
			float(weapon_data.get("shot_speed", 250.0)),
			int(weapon_data.get("damage", 1))
		)

func _fire_spiral_stream(weapon_data: Dictionary) -> void:
	var shot_count := int(weapon_data.get("shot_count", 4))
	var angle_step := float(weapon_data.get("angle_step", 0.45))
	var phase_step := float(weapon_data.get("phase_step", 0.35))
	for i in shot_count:
		var angle := spiral_phase + float(i) * angle_step
		_spawn_bullet(
			position,
			Vector2.from_angle(angle),
			float(weapon_data.get("shot_speed", 250.0)),
			int(weapon_data.get("damage", 1))
		)
	spiral_phase += phase_step

func _spawn_bullet(shot_position: Vector2, direction: Vector2, shot_speed: float, damage: int) -> void:
	var shot = BHShotScript.new()
	shot.position = shot_position
	shot.direction = direction
	shot.speed = shot_speed
	shot.damage = damage
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
	var powerup_data := BHPowerups.get_powerup_data(powerup_id)
	if powerup_data.is_empty():
		return

	match String(powerup_data.get("kind", "")):
		"weapon":
			_activate_weapon(int(powerup_data.get("weapon_id", -1)))
		"speed":
			speed = min(speed + float(powerup_data.get("value", 0.0)), MAX_PLAYER_SPEED)
		"shield":
			var extra_lives := int(powerup_data.get("value", 1))
			max_lives += extra_lives
			lives = min(lives + extra_lives, max_lives)
		_:
			pass

	_update_experience_ui()

func get_owned_weapon_ids() -> Array[int]:
	return active_weapons.duplicate()

func _activate_weapon(weapon_id: int) -> void:
	if weapon_id == -1:
		return
	if not active_weapons.has(weapon_id):
		active_weapons.append(weapon_id)

func _update_experience_ui() -> void:
	experience_changed.emit(experience_points, level, xp_to_next_level)

func get_pattern_name() -> String:
	if active_weapons.is_empty():
		return "NONE"

	var names: Array[String] = []
	for weapon_id in active_weapons:
		names.append(BHPowerups.get_weapon_name(weapon_id))
	return ", ".join(names)

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

