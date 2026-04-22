extends Area2D

var damage: int = 2
var radius: float = 72.0
var lifetime: float = 0.22
var anchor_ref: Node2D = null

func get_damage() -> int:
	return damage

func _ready() -> void:
	collision_layer = 3
	collision_mask = 1
	add_to_group("bh_player_attack")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	add_child(collision)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.45, 0.15, 0.22))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.78, 0.22, 0.9), 2.0)

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
