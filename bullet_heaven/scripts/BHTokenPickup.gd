extends Area2D

enum TokenType {
	REROLL,
	SKIP,
}

var token_type: TokenType = TokenType.REROLL

func get_token_type() -> int:
	return int(token_type)

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	add_to_group("bh_token_pickup")

	var radius := 7.0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	add_child(collision)

	var outer := ColorRect.new()
	outer.size = Vector2(radius * 2.0, radius * 2.0)
	outer.position = Vector2(-radius, -radius)
	outer.color = _get_primary_color()
	add_child(outer)

	var core := ColorRect.new()
	core.size = Vector2(6.0, 6.0)
	core.position = Vector2(-3.0, -3.0)
	core.color = Color(1.0, 1.0, 1.0, 0.95)
	add_child(core)

func _get_primary_color() -> Color:
	if token_type == TokenType.SKIP:
		return Color(0.35, 0.75, 1.0, 1.0)
	return Color(1.0, 0.75, 0.28, 1.0)
