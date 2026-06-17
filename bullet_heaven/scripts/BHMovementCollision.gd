class_name BHMovementCollision
extends RefCounted

const MOVEMENT_RADIUS_SCALE := 0.86
const SLIDE_ITERATIONS := 4

static func resolve_world_scroll_delta(
	obstacle_container: Node2D,
	player_position: Vector2,
	radius: float,
	desired_delta: Vector2
) -> Vector2:
	return _resolve_delta(
		obstacle_container,
		player_position,
		radius,
		desired_delta,
		true
	)

static func resolve_position_delta(
	obstacle_container: Node2D,
	position: Vector2,
	radius: float,
	desired_delta: Vector2,
	use_simple_obstacles: bool = false
) -> Vector2:
	return _resolve_delta(
		obstacle_container,
		position,
		radius,
		desired_delta,
		false,
		use_simple_obstacles
	)

static func resolve_position(
	obstacle_container: Node2D,
	position: Vector2,
	desired_delta: Vector2,
	radius: float,
	use_simple_obstacles: bool = false
) -> Vector2:
	return position + resolve_position_delta(obstacle_container, position, radius, desired_delta, use_simple_obstacles)

static func _resolve_delta(
	obstacle_container: Node2D,
	position: Vector2,
	radius: float,
	desired_delta: Vector2,
	world_scroll_mode: bool,
	use_simple_obstacles: bool = false
) -> Vector2:
	if desired_delta == Vector2.ZERO or obstacle_container == null:
		return Vector2.ZERO

	var move_radius: float = maxf(radius * MOVEMENT_RADIUS_SCALE, 1.0)
	var remaining: Vector2 = desired_delta
	var accumulated := Vector2.ZERO

	for _iteration in SLIDE_ITERATIONS:
		if remaining.length_squared() <= 0.0001:
			break
		if not _collides(obstacle_container, position, move_radius, remaining, world_scroll_mode, accumulated, use_simple_obstacles):
			return accumulated + remaining

		var step := _resolve_single_step(
			obstacle_container,
			position,
			move_radius,
			remaining,
			world_scroll_mode,
			accumulated,
			use_simple_obstacles
		)
		if step.length_squared() <= 0.0001:
			remaining *= 0.5
			continue
		accumulated += step
		remaining -= step

	return accumulated

static func _resolve_single_step(
	obstacle_container: Node2D,
	position: Vector2,
	radius: float,
	desired_delta: Vector2,
	world_scroll_mode: bool,
	prior_delta: Vector2,
	use_simple_obstacles: bool = false
) -> Vector2:
	if not _collides(obstacle_container, position, radius, desired_delta, world_scroll_mode, prior_delta, use_simple_obstacles):
		return desired_delta

	var delta_x := Vector2(desired_delta.x, 0.0)
	if not _collides(obstacle_container, position, radius, delta_x, world_scroll_mode, prior_delta, use_simple_obstacles):
		var delta_xy := delta_x + Vector2(0.0, desired_delta.y)
		if not _collides(obstacle_container, position, radius, delta_xy, world_scroll_mode, prior_delta, use_simple_obstacles):
			return delta_xy
		return delta_x

	var delta_y := Vector2(0.0, desired_delta.y)
	if not _collides(obstacle_container, position, radius, delta_y, world_scroll_mode, prior_delta, use_simple_obstacles):
		return delta_y

	var obstacle_offset: Vector2 = (prior_delta + desired_delta) if world_scroll_mode else Vector2.ZERO
	var check_position: Vector2 = position if world_scroll_mode else position + prior_delta
	var normal := _aggregate_push_normal(
		obstacle_container,
		check_position,
		radius,
		obstacle_offset + prior_delta if world_scroll_mode else prior_delta,
		desired_delta,
		use_simple_obstacles
	)
	if normal.length_squared() > 0.0001:
		var slide_delta := desired_delta - normal * desired_delta.dot(normal)
		if slide_delta.length_squared() > 0.0001:
			if not _collides(obstacle_container, position, radius, slide_delta, world_scroll_mode, prior_delta, use_simple_obstacles):
				return slide_delta
			var slide_x := Vector2(slide_delta.x, 0.0)
			if not _collides(obstacle_container, position, radius, slide_x, world_scroll_mode, prior_delta, use_simple_obstacles):
				return slide_x
			var slide_y := Vector2(0.0, slide_delta.y)
			if not _collides(obstacle_container, position, radius, slide_y, world_scroll_mode, prior_delta, use_simple_obstacles):
				return slide_y

	return Vector2.ZERO

static func _collides(
	obstacle_container: Node2D,
	position: Vector2,
	radius: float,
	test_delta: Vector2,
	world_scroll_mode: bool,
	prior_delta: Vector2 = Vector2.ZERO,
	use_simple_obstacles: bool = false
) -> bool:
	var total_delta: Vector2 = prior_delta + test_delta
	var check_position: Vector2 = position if world_scroll_mode else position + total_delta
	var obstacle_offset: Vector2 = total_delta if world_scroll_mode else Vector2.ZERO
	for obstacle in obstacle_container.get_children():
		if use_simple_obstacles and obstacle.has_method("blocks_entity_point"):
			if bool(obstacle.call("blocks_entity_point", check_position, radius, obstacle_offset)):
				return true
			continue
		if obstacle.has_method("blocks_player_point"):
			if bool(obstacle.call("blocks_player_point", check_position, radius, obstacle_offset)):
				return true
			continue
		if not obstacle.has_method("get_collision_radius"):
			continue
		var obstacle_radius: float = float(obstacle.call("get_collision_radius"))
		var obstacle_position: Vector2 = (obstacle as Node2D).global_position + obstacle_offset
		if check_position.distance_to(obstacle_position) < radius + obstacle_radius:
			return true
	return false

static func _aggregate_push_normal(
	obstacle_container: Node2D,
	position: Vector2,
	radius: float,
	obstacle_position_offset: Vector2,
	movement: Vector2,
	use_simple_obstacles: bool = false
) -> Vector2:
	var combined := Vector2.ZERO
	for obstacle in obstacle_container.get_children():
		if use_simple_obstacles and obstacle.has_method("blocks_entity_point"):
			if not bool(obstacle.call("blocks_entity_point", position, radius, obstacle_position_offset)):
				continue
			var obstacle_position: Vector2 = (obstacle as Node2D).global_position + obstacle_position_offset
			var away: Vector2 = position - obstacle_position
			if away.length_squared() < 0.001:
				away = -movement.normalized() if movement.length_squared() > 0.001 else Vector2.UP
			else:
				away = away.normalized()
			combined += away
			continue
		if obstacle.has_method("get_push_normal"):
			var push_normal: Vector2 = obstacle.call(
				"get_push_normal",
				position,
				radius,
				obstacle_position_offset,
				movement
			)
			if push_normal.length_squared() > 0.0001:
				combined += push_normal
				continue
		if not obstacle.has_method("get_collision_radius"):
			continue
		var obstacle_radius: float = float(obstacle.call("get_collision_radius"))
		var obstacle_position: Vector2 = (obstacle as Node2D).global_position + obstacle_position_offset
		var away: Vector2 = position - obstacle_position
		var overlap: float = radius + obstacle_radius - away.length()
		if overlap <= 0.0:
			continue
		if away.length_squared() < 0.001:
			away = -movement.normalized() if movement.length_squared() > 0.001 else Vector2.UP
		else:
			away = away.normalized()
		combined += away * overlap
	if combined.length_squared() <= 0.0001:
		return Vector2.ZERO
	return combined.normalized()
