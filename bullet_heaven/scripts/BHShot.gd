extends Area2D

var direction: Vector2 = Vector2.UP
var speed: float = 320.0
var damage: int = 1
var anchor_ref: Node2D = null

func get_damage() -> int:
	return damage

func _ready() -> void:
	collision_layer = 3
	collision_mask = 1

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 3.0
	col.shape = shape
	add_child(col)

	var vis = ColorRect.new()
	vis.size = Vector2(6, 6)
	vis.position = Vector2(-3, -3)
	vis.color = Color(0.7, 1.0, 0.6, 1.0)
	add_child(vis)

func _process(delta: float) -> void:
	position += direction * speed * delta
	if anchor_ref != null and global_position.distance_to(anchor_ref.global_position) > 1100.0:
		queue_free()
