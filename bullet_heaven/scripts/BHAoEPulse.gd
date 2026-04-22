extends Area2D

var damage: int = 1
var lifetime: float = 0.32
var anchor_ref: Node2D = null

func get_damage() -> int:
	return damage

func _ready() -> void:
	collision_layer = 3
	collision_mask = 1

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 54.0
	collision.shape = shape
	add_child(collision)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 54.0, Color(0.55, 0.9, 1.0, 0.2))
	draw_arc(Vector2.ZERO, 54.0, 0.0, TAU, 44, Color(0.72, 0.96, 1.0, 0.9), 2.0)

func _process(delta: float) -> void:
	if anchor_ref != null:
		global_position = anchor_ref.global_position
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
