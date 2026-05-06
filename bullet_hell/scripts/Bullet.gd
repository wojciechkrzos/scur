## Bullet.gd
## Pocisk bossa. Samoistnie się usuwa po wyjściu z planszy.
## Kierunek i prędkość ustawiane przez Boss.gd przez meta.

extends Area2D

var direction: Vector2 = Vector2.DOWN
var speed: float = 100.0
var play_area: Rect2
var _elapsed: float = 0.0
var _accelerate_after: float = 0.0
var _deceleration: float = 0.0
var _acceleration: float = 0.0
var _min_speed: float = 0.0
var _max_speed: float = 1000.0
var _homing_strength: float = 0.0
var _homing_delay: float = 0.0
var _target_ref: Node2D = null
var _homing_fixed_set: bool = false
var _homing_fixed_pos: Vector2 = Vector2()
var _homing_fixed_direction: Vector2 = Vector2()

func _ready() -> void:
	# Pobierz parametry ustawione przez Boss._create_bullet()
	if has_meta("direction"):
		direction = (get_meta("direction") as Vector2).normalized()
	if has_meta("speed"):
		speed = get_meta("speed")
	if has_meta("accelerate_after"):
		_accelerate_after = maxf(float(get_meta("accelerate_after")), 0.0)
	if has_meta("deceleration"):
		_deceleration = float(get_meta("deceleration"))
	if has_meta("acceleration"):
		_acceleration = float(get_meta("acceleration"))
	if has_meta("min_speed"):
		_min_speed = maxf(float(get_meta("min_speed")), 0.0)
	if has_meta("max_speed"):
		_max_speed = maxf(float(get_meta("max_speed")), _min_speed)
	if has_meta("homing_strength"):
		_homing_strength = maxf(float(get_meta("homing_strength")), 0.0)
	if has_meta("homing_delay"):
		_homing_delay = maxf(float(get_meta("homing_delay")), 0.0)
	if has_meta("target_ref"):
		_target_ref = get_meta("target_ref") as Node2D


func _process(delta: float) -> void:
	_elapsed += delta
	_update_speed(delta)
	_update_homing(delta)
	position += direction * speed * delta
	
	# Usuń pocisk gdy wyjdzie z planszy (z marginesem)
	if play_area != Rect2() and not play_area.grow(40).has_point(position):
		queue_free()

func _update_speed(delta: float) -> void:
	if _elapsed < _accelerate_after:
		if _deceleration != 0.0:
			speed = maxf(_min_speed, speed + _deceleration * delta)
		return

	if _acceleration != 0.0:
		speed = minf(_max_speed, speed + _acceleration * delta)

func _update_homing(_delta: float) -> void:
	# Fixed-target homing: capture the target position at homing start
	if _homing_strength <= 0.0:
		return
	if _elapsed < _homing_delay:
		return

	if not _homing_fixed_set:
		if _target_ref != null and is_instance_valid(_target_ref):
			_homing_fixed_pos = _target_ref.global_position
			# compute and lock the direction toward the captured point so bullet continues past the player
			_homing_fixed_direction = (_homing_fixed_pos - global_position)
			if _homing_fixed_direction == Vector2.ZERO:
				return
			_homing_fixed_direction = _homing_fixed_direction.normalized()
			direction = _homing_fixed_direction
			_homing_fixed_set = true
		else:
			return

	# Continue moving along the fixed direction (no continuous tracking)
	direction = _homing_fixed_direction
