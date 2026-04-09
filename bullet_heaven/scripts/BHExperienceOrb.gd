extends Area2D

var xp_amount: int = 1

func get_xp_amount() -> int:
	return xp_amount

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
