class_name BHHitboxDebug
extends RefCounted

static func is_enabled() -> bool:
	return GameState.is_hitbox_debug_enabled()

static func draw_collision_circle(
	canvas: CanvasItem,
	center: Vector2,
	radius: float,
	color: Color,
	segments: int = 48
) -> void:
	if radius <= 0.0:
		return
	canvas.draw_circle(center, radius, Color(color.r, color.g, color.b, color.a * 0.12))
	canvas.draw_arc(center, radius, 0.0, TAU, segments, color, 2.0)
	canvas.draw_line(center - Vector2(radius, 0.0), center + Vector2(radius, 0.0), color, 1.0)
	canvas.draw_line(center - Vector2(0.0, radius), center + Vector2(0.0, radius), color, 1.0)

static func draw_bounds_rect(
	canvas: CanvasItem,
	center: Vector2,
	size: Vector2,
	color: Color
) -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var half_size := size * 0.5
	canvas.draw_rect(Rect2(center - half_size, size), Color(color.r, color.g, color.b, color.a * 0.1), true)
	canvas.draw_rect(Rect2(center - half_size, size), color, false, 2.0)

static func draw_origin_marker(canvas: CanvasItem, center: Vector2, color: Color, size: float = 4.0) -> void:
	canvas.draw_circle(center, size, color)
	canvas.draw_line(center - Vector2(size * 2.0, 0.0), center + Vector2(size * 2.0, 0.0), color, 1.5)
	canvas.draw_line(center - Vector2(0.0, size * 2.0), center + Vector2(0.0, size * 2.0), color, 1.5)
