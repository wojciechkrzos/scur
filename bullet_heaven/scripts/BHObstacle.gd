extends Area2D

@export var obstacle_texture: Texture2D
@export var hframes: int = 1
@export var vframes: int = 1
@export var frame_count: int = 1
@export var animation_fps: float = 0.0
@export var visual_scale: float = 1.0
@export var collision_radius: float = 16.0
@export var use_alpha_collision: bool = false
@export_range(0.0, 1.0, 0.01) var alpha_threshold: float = 0.1

var _elapsed: float = 0.0
var _sprite: Sprite2D
var _flip_h: bool = false
var _collision_polygons: Array[PackedVector2Array] = []

func setup(texture: Texture2D, radius: float, scale_factor: float, frames_x: int = 1, frames_y: int = 1, anim_frames: int = 1, fps: float = 0.0, use_alpha_shape: bool = false, alpha_cutoff: float = 0.1) -> void:
	obstacle_texture = texture
	collision_radius = maxf(radius, 1.0)
	visual_scale = maxf(scale_factor, 0.1)
	hframes = maxi(frames_x, 1)
	vframes = maxi(frames_y, 1)
	frame_count = maxi(anim_frames, 1)
	animation_fps = maxf(fps, 0.0)
	use_alpha_collision = use_alpha_shape
	alpha_threshold = clampf(alpha_cutoff, 0.0, 1.0)

func get_collision_radius() -> float:
	return collision_radius

func set_visual_flip_h(enabled: bool) -> void:
	_flip_h = enabled
	if _sprite != null:
		_sprite.flip_h = _flip_h

func blocks_player_point(point_global: Vector2, point_radius: float, position_offset: Vector2 = Vector2.ZERO) -> bool:
	var obstacle_position: Vector2 = global_position + position_offset
	if use_alpha_collision and not _collision_polygons.is_empty():
		var local_point: Vector2 = point_global - obstacle_position
		for polygon in _collision_polygons:
			if polygon.is_empty():
				continue
			if Geometry2D.is_point_in_polygon(local_point, polygon):
				return true
			if point_radius > 0.0 and _distance_to_polygon(local_point, polygon) <= point_radius:
				return true
		return false

	return point_global.distance_to(obstacle_position) < collision_radius + point_radius

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	add_to_group("bh_obstacle")

	if use_alpha_collision:
		_build_alpha_collision_shapes()
	if _collision_polygons.is_empty():
		var shape := CircleShape2D.new()
		shape.radius = collision_radius
		var collision := CollisionShape2D.new()
		collision.shape = shape
		add_child(collision)

	_sprite = Sprite2D.new()
	_sprite.texture = obstacle_texture
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.hframes = hframes
	_sprite.vframes = vframes
	_sprite.scale = Vector2(visual_scale, visual_scale)
	_sprite.frame_coords = Vector2i(0, 0)
	_sprite.flip_h = _flip_h
	add_child(_sprite)

func _process(delta: float) -> void:
	if _sprite == null:
		return
	if frame_count <= 1 or animation_fps <= 0.0:
		return

	_elapsed += delta * animation_fps
	var capped_frame_count: int = mini(frame_count, _sprite.hframes * _sprite.vframes)
	if capped_frame_count <= 0:
		return
	var frame_index: int = int(floor(_elapsed)) % capped_frame_count
	var frame_x: int = frame_index % _sprite.hframes
	var frame_y: int = int(floor(float(frame_index) / float(_sprite.hframes)))
	_sprite.frame_coords = Vector2i(frame_x, frame_y)

func _build_alpha_collision_shapes() -> void:
	if obstacle_texture == null:
		return
	var image: Image = obstacle_texture.get_image()
	if image == null or image.is_empty():
		return

	var frame_width: int = int(floor(float(image.get_width()) / float(maxi(hframes, 1))))
	var frame_height: int = int(floor(float(image.get_height()) / float(maxi(vframes, 1))))
	if frame_width <= 0 or frame_height <= 0:
		return

	var frame_image := Image.create(frame_width, frame_height, false, Image.FORMAT_RGBA8)
	frame_image.fill(Color(0, 0, 0, 0))
	frame_image.blit_rect(image, Rect2i(0, 0, frame_width, frame_height), Vector2i.ZERO)

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(frame_image, alpha_threshold)
	var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2i(0, 0, frame_width, frame_height), 1.5)
	if polygons.is_empty():
		return

	var half_size := Vector2(float(frame_width), float(frame_height)) * 0.5
	for polygon in polygons:
		if polygon.is_empty():
			continue
		var local_polygon := PackedVector2Array()
		for point in polygon:
			local_polygon.append((point - half_size) * visual_scale)
		_collision_polygons.append(local_polygon)

		var collision_polygon := CollisionPolygon2D.new()
		collision_polygon.polygon = local_polygon
		add_child(collision_polygon)

func _distance_to_polygon(point: Vector2, polygon: PackedVector2Array) -> float:
	if polygon.size() == 0:
		return INF

	var min_distance: float = INF
	for index in polygon.size():
		var from_point: Vector2 = polygon[index]
		var to_point: Vector2 = polygon[(index + 1) % polygon.size()]
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, from_point, to_point)
		var distance: float = point.distance_to(closest)
		if distance < min_distance:
			min_distance = distance
	return min_distance
