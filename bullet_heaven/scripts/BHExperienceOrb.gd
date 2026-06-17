extends Area2D

const MAGNET_RADIUS := 140.0
const COLLECT_RADIUS := 28.0
const MAGNET_ACCELERATION := 1200.0
const MAX_MAGNET_SPEED := 1100.0
const MAX_ORB_LIFETIME := 45.0

var xp_amount: int = 1
var player_ref: Node2D = null
var magnet_velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0

func get_xp_amount() -> int:
	return xp_amount

func setup_magnet(player: Node2D) -> void:
	player_ref = player

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var clamped_xp: int = clampi(xp_amount, 1, 5)
	var radius: float = 5.0 + float(clamped_xp - 1) * 1.5
	var diameter: float = radius * 2.0

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	add_child(collision)

	var orb := ColorRect.new()
	orb.size = Vector2(diameter, diameter)
	orb.position = Vector2(-radius, -radius)
	orb.color = Color(0.72, 0.38, 1.0, 1.0)
	add_child(orb)

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= MAX_ORB_LIFETIME:
		queue_free()
		return
	if get_tree().paused:
		return
	if player_ref == null or not is_instance_valid(player_ref):
		return

	var to_player: Vector2 = player_ref.global_position - global_position
	var distance: float = to_player.length()
	if distance <= COLLECT_RADIUS:
		return
	if distance > MAGNET_RADIUS:
		magnet_velocity = magnet_velocity.lerp(Vector2.ZERO, minf(10.0 * delta, 1.0))
		return

	var direction: Vector2 = to_player / distance
	var pull_strength: float = pow(
		1.0 - (distance - COLLECT_RADIUS) / maxf(MAGNET_RADIUS - COLLECT_RADIUS, 1.0),
		0.55
	)
	magnet_velocity += direction * MAGNET_ACCELERATION * pull_strength * delta
	if magnet_velocity.length() > MAX_MAGNET_SPEED:
		magnet_velocity = magnet_velocity.normalized() * MAX_MAGNET_SPEED
	global_position += magnet_velocity * delta
