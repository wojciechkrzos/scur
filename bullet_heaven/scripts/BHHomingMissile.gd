extends Area2D

var direction: Vector2 = Vector2.UP
var speed: float = 185.0
var turn_rate: float = 3.6
var damage: int = 3
var max_range: float = 1050.0
var anchor_ref: Node2D = null
var target_group: StringName = &"bh_enemy"

func get_damage() -> int:
	return damage

func _ready() -> void:
	collision_layer = 3
	collision_mask = 1
	add_to_group("bh_player_bullet")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	collision.shape = shape
	add_child(collision)

	var body := ColorRect.new()
	body.size = Vector2(14.0, 8.0)
	body.position = Vector2(-7.0, -4.0)
	body.color = Color(0.95, 0.9, 0.3, 1.0)
	add_child(body)

	var trail := ColorRect.new()
	trail.size = Vector2(6.0, 6.0)
	trail.position = Vector2(-12.0, -3.0)
	trail.color = Color(1.0, 0.45, 0.15, 0.9)
	add_child(trail)

func _process(delta: float) -> void:
	if anchor_ref != null and global_position.distance_to(anchor_ref.global_position) > max_range:
		queue_free()
		return

	var target := _get_nearest_target()
	if target != null:
		var to_target := (target.global_position - global_position).normalized()
		if to_target != Vector2.ZERO:
			direction = direction.slerp(to_target, clampf(turn_rate * delta, 0.0, 1.0)).normalized()

	rotation = direction.angle()
	position += direction * speed * delta

func _get_nearest_target() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance_sq := INF
	for node in get_tree().get_nodes_in_group(target_group):
		if not (node is Area2D):
			continue
		if not is_instance_valid(node):
			continue
		var enemy := node as Area2D
		if enemy.is_queued_for_deletion():
			continue
		var distance_sq := global_position.distance_squared_to(enemy.global_position)
		if distance_sq < nearest_distance_sq:
			nearest_distance_sq = distance_sq
			nearest = enemy
	return nearest
