extends Area2D

var xp_amount: int = 1

func get_xp_amount() -> int:
	return xp_amount

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	collision.shape = shape
	add_child(collision)

	var orb := ColorRect.new()
	orb.size = Vector2(10, 10)
	orb.position = Vector2(-5, -5)
	orb.color = Color(0.3, 0.7, 1.0, 1.0)
	add_child(orb)
