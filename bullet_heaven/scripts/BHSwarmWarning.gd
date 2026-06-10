extends Node2D

var target_ref: Node2D
var source_direction: Vector2 = Vector2.UP
var warning_duration: float = 1.25
var elapsed: float = 0.0
var active: bool = false

func _ready() -> void:
	z_index = 2000
	visible = false
	set_process(false)

func show_warning(target: Node2D, direction: Vector2, duration: float) -> void:
	target_ref = target
	source_direction = direction.normalized()
	if source_direction == Vector2.ZERO:
		source_direction = Vector2.UP
	warning_duration = maxf(duration, 0.1)
	elapsed = 0.0
	active = true
	visible = true
	set_process(true)
	_update_position()
	queue_redraw()

func hide_warning() -> void:
	active = false
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	_update_position()
	queue_redraw()

func _update_position() -> void:
	if target_ref != null and is_instance_valid(target_ref):
		global_position = target_ref.global_position

func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 12.0)
	var ring_radius: float = 48.0 + pulse * 6.0
	var warning_color := Color(1.0, 0.12, 0.08, 0.72 + pulse * 0.25)
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 48, warning_color, 4.0)

	var arrow_center: Vector2 = source_direction * (ring_radius + 24.0)
	var perpendicular := Vector2(-source_direction.y, source_direction.x)
	var arrow_points := PackedVector2Array([
		arrow_center + source_direction * 14.0,
		arrow_center - source_direction * 10.0 + perpendicular * 11.0,
		arrow_center - source_direction * 10.0 - perpendicular * 11.0,
	])
	draw_colored_polygon(arrow_points, warning_color)
	draw_line(source_direction * ring_radius, arrow_center - source_direction * 9.0, warning_color, 4.0)

	var remaining_ratio: float = clampf(1.0 - elapsed / warning_duration, 0.0, 1.0)
	draw_arc(Vector2.ZERO, ring_radius + 8.0, -PI * 0.5, -PI * 0.5 + TAU * remaining_ratio, 48, Color(1.0, 0.75, 0.2, 0.9), 3.0)
