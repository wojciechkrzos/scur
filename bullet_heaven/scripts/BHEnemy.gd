extends Area2D

signal died

@export var speed: float = 85.0

var hp: int = 1
var player_ref: Node2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 | 3

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	add_child(col)

	var vis = ColorRect.new()
	vis.size = Vector2(16, 16)
	vis.position = Vector2(-8, -8)
	vis.color = Color(0.9, 0.2, 0.2, 1.0)
	add_child(vis)

func _process(delta: float) -> void:
	if player_ref == null:
		return
	var dir = (player_ref.global_position - global_position).normalized()
	global_position += dir * speed * delta

	if global_position.distance_to(player_ref.global_position) > 1500.0:
		queue_free()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		died.emit()
		queue_free()
