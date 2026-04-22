extends Area2D

signal died

enum EnemyKind {
	STANDARD,
	TANK,
	SWARM,
}

enum MovementMode {
	HOMING,
	LINE,
}

@export var enemy_kind: EnemyKind = EnemyKind.STANDARD
@export var speed: float = 85.0
@export var hp: int = 1
@export var xp_value: int = 1
@export var damage_flash_color: Color = Color(1.0, 0.95, 0.95, 1.0)
@export var damage_flash_duration: float = 0.08
@export_file("*.png", "*.webp") var standard_enemy_texture_path: String = "res://assets/bullet_heaven/ratfolk_goon.png"
@export_file("*.png", "*.webp") var tank_enemy_texture_path: String = "res://assets/bullet_heaven/ratfolk_brute.png"
@export var standard_frame_size: Vector2i = Vector2i(32, 32)
@export var tank_frame_size: Vector2i = Vector2i(32, 32)

var player_ref: Node2D
var play_area: Rect2 = Rect2()
var movement_mode: MovementMode = MovementMode.HOMING
var move_direction: Vector2 = Vector2.ZERO
var obstacle_container: Node2D
var is_dying: bool = false
var damage_flash_tween: Tween
var damage_flash_overlay: ColorRect

var body_color: Color = Color(0.9, 0.2, 0.2, 1.0)
var body_size: Vector2 = Vector2(16, 16)
var collision_radius: float = 8.0

func setup(kind: EnemyKind, player: Node2D, area: Rect2, direction: Vector2 = Vector2.ZERO, obstacles: Node2D = null) -> void:
	enemy_kind = kind
	player_ref = player
	play_area = area
	move_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO
	obstacle_container = obstacles
	_apply_kind_stats()

func _apply_kind_stats() -> void:
	match enemy_kind:
		EnemyKind.TANK:
			speed = 55.0
			hp = 6
			xp_value = randi_range(2, 5)
			movement_mode = MovementMode.HOMING
			body_color = Color(0.9, 0.55, 0.15, 1.0)
			body_size = Vector2(26, 26)
			collision_radius = 11.5
		EnemyKind.SWARM:
			speed = 210.0
			hp = 1
			xp_value = 1
			movement_mode = MovementMode.LINE
			body_color = Color(0.95, 0.9, 0.25, 1.0)
			body_size = Vector2(14, 14)
			collision_radius = 6.0
		_:
			speed = 85.0
			hp = 1
			xp_value = 1
			movement_mode = MovementMode.HOMING
			body_color = Color(0.9, 0.2, 0.2, 1.0)
			body_size = Vector2(16, 16)
			collision_radius = 8.0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 | 3
	add_to_group("bh_enemy")

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = collision_radius
	col.shape = shape
	add_child(col)

	var sprite_texture: Texture2D = _build_enemy_display_texture()
	if sprite_texture != null:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = sprite_texture
		sprite.centered = true
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var source_size: Vector2 = sprite_texture.get_size()
		if source_size.x > 0.0 and source_size.y > 0.0:
			var scale_ratio: float = minf(body_size.x / source_size.x, body_size.y / source_size.y)
			sprite.scale = Vector2(scale_ratio, scale_ratio)
		add_child(sprite)
	else:
		var vis = ColorRect.new()
		vis.size = body_size
		vis.position = -body_size * 0.5
		vis.color = body_color
		add_child(vis)

	damage_flash_overlay = ColorRect.new()
	damage_flash_overlay.size = body_size
	damage_flash_overlay.position = -body_size * 0.5
	damage_flash_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	damage_flash_overlay.z_index = 1000
	damage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(damage_flash_overlay)

func _process(delta: float) -> void:
	match movement_mode:
		MovementMode.HOMING:
			if player_ref == null:
				return
			var dir: Vector2 = (player_ref.global_position - global_position).normalized()
			var homing_step: Vector2 = dir * speed * delta
			var homing_target: Vector2 = global_position + homing_step
			if not _would_overlap_obstacle(homing_target):
				global_position = homing_target
			if global_position.distance_to(player_ref.global_position) > 1500.0:
				queue_free()
		MovementMode.LINE:
			var line_step: Vector2 = move_direction * speed * delta
			var line_target: Vector2 = global_position + line_step
			if not _would_overlap_obstacle(line_target):
				global_position = line_target
			if _is_outside_play_area(140.0):
				queue_free()

func _would_overlap_obstacle(target_position: Vector2) -> bool:
	if obstacle_container == null:
		return false

	for obstacle in obstacle_container.get_children():
		if obstacle.has_method("blocks_player_point"):
			if bool(obstacle.call("blocks_player_point", target_position, collision_radius, Vector2.ZERO)):
				return true
			continue
		if not obstacle.has_method("get_collision_radius"):
			continue
		var obstacle_radius: float = float(obstacle.call("get_collision_radius"))
		var obstacle_position: Vector2 = (obstacle as Node2D).global_position
		if target_position.distance_to(obstacle_position) < collision_radius + obstacle_radius:
			return true
	return false

func _is_outside_play_area(margin: float) -> bool:
	if play_area.size == Vector2.ZERO:
		return false
	return (
		global_position.x < play_area.position.x - margin
		or global_position.x > play_area.end.x + margin
		or global_position.y < play_area.position.y - margin
		or global_position.y > play_area.end.y + margin
	)

func take_damage(amount: int) -> void:
	if is_dying:
		return

	hp -= amount
	_play_damage_flash()
	if hp <= 0:
		_die_with_flash()

func _play_damage_flash() -> void:
	if damage_flash_tween != null:
		damage_flash_tween.kill()

	if damage_flash_overlay != null:
		damage_flash_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var flash_targets: Array[CanvasItem] = []
	var flash_colors: Array[Color] = []
	var restore_colors: Array[Color] = []
	_collect_flash_targets(self, flash_targets, flash_colors, restore_colors)
	if flash_targets.is_empty():
		return

	damage_flash_tween = create_tween()
	damage_flash_tween.set_parallel(true)
	for index in flash_targets.size():
		damage_flash_tween.tween_property(flash_targets[index], "modulate", flash_colors[index], damage_flash_duration * 0.5)
	if damage_flash_overlay != null:
		damage_flash_tween.tween_property(damage_flash_overlay, "modulate", Color(1.0, 1.0, 1.0, 0.85), damage_flash_duration * 0.5)
	damage_flash_tween.set_parallel(false)
	for index in flash_targets.size():
		damage_flash_tween.tween_property(flash_targets[index], "modulate", restore_colors[index], damage_flash_duration * 0.5)
	if damage_flash_overlay != null:
		damage_flash_tween.tween_property(damage_flash_overlay, "modulate", Color(1.0, 1.0, 1.0, 0.0), damage_flash_duration * 0.5)
	damage_flash_tween.finished.connect(_on_damage_flash_finished)

func _collect_flash_targets(node: Node, flash_targets: Array[CanvasItem], flash_colors: Array[Color], restore_colors: Array[Color]) -> void:
	if node is CanvasItem and not (node is CollisionShape2D or node is CollisionPolygon2D):
		var canvas_item := node as CanvasItem
		flash_targets.append(canvas_item)
		restore_colors.append(canvas_item.modulate)
		flash_colors.append(damage_flash_color)

	for child in node.get_children():
		_collect_flash_targets(child, flash_targets, flash_colors, restore_colors)

func _die_with_flash() -> void:
	if is_dying:
		return

	is_dying = true
	monitoring = false
	monitorable = false
	collision_layer = 0
	collision_mask = 0
	await get_tree().create_timer(damage_flash_duration).timeout
	died.emit()
	queue_free()

func _on_damage_flash_finished() -> void:
	damage_flash_tween = null

func _build_enemy_display_texture() -> Texture2D:
	var texture: Texture2D = _load_enemy_texture_for_kind()
	if texture == null:
		return null

	var frame_size: Vector2i = _get_enemy_frame_size()
	if frame_size.x <= 0 or frame_size.y <= 0:
		return texture

	var texture_size: Vector2 = texture.get_size()
	if texture_size.x < frame_size.x or texture_size.y < frame_size.y:
		return texture

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2.ZERO, Vector2(frame_size.x, frame_size.y))
	return atlas

func _get_enemy_frame_size() -> Vector2i:
	match enemy_kind:
		EnemyKind.TANK:
			return tank_frame_size
		EnemyKind.STANDARD:
			return standard_frame_size
		_:
			return Vector2i.ZERO

func _load_enemy_texture_for_kind() -> Texture2D:
	var path := ""
	match enemy_kind:
		EnemyKind.TANK:
			path = tank_enemy_texture_path
		EnemyKind.STANDARD:
			path = standard_enemy_texture_path
		_:
			return null

	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is Texture2D:
			return resource as Texture2D
	return null
