extends Area2D

var damage: int = 2
var radius: float = 72.0
var lifetime: float = 0.22
var anchor_ref: Node2D = null
var glow_phase: float = 0.0

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
	var outer_alpha := 0.16 + 0.12 * (0.5 + 0.5 * sin(glow_phase))
	var inner_alpha := 0.22 + 0.14 * (0.5 + 0.5 * cos(glow_phase * 1.2))
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.45, 0.15, outer_alpha))
	draw_circle(Vector2.ZERO, radius * 0.6, Color(1.0, 0.76, 0.28, inner_alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.78, 0.22, 0.95), 2.0)

func _process(delta: float) -> void:
	glow_phase += delta * 6.5
	queue_redraw()
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
