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

	var pulse := ColorRect.new()
	pulse.size = Vector2(108, 108)
	pulse.position = Vector2(-54, -54)
	pulse.color = Color(0.55, 0.9, 1.0, 0.18)
	add_child(pulse)

func _process(delta: float) -> void:
	if anchor_ref != null:
		global_position = anchor_ref.global_position
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
