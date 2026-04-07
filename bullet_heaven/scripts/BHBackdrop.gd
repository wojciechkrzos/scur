extends Node2D

var visible_rect: Rect2 = Rect2(0, 0, 800, 600)
var scroll_offset: Vector2 = Vector2.ZERO

func setup(view_rect: Rect2) -> void:
	visible_rect = view_rect
	queue_redraw()

func set_scroll_offset(new_offset: Vector2) -> void:
	scroll_offset = new_offset
	queue_redraw()

func _draw() -> void:
	draw_rect(visible_rect, Color(0.03, 0.05, 0.03, 1.0), true)

	var spacing := 64.0
	var grid_color := Color(0.16, 0.28, 0.16, 0.65)

	var x_start := visible_rect.position.x - fmod(scroll_offset.x, spacing) - spacing
	var x_end := visible_rect.end.x + spacing
	var x := x_start
	while x <= x_end:
		draw_line(Vector2(x, visible_rect.position.y), Vector2(x, visible_rect.end.y), grid_color, 1.0)
		x += spacing

	var y_start := visible_rect.position.y - fmod(scroll_offset.y, spacing) - spacing
	var y_end := visible_rect.end.y + spacing
	var y := y_start
	while y <= y_end:
		draw_line(Vector2(visible_rect.position.x, y), Vector2(visible_rect.end.x, y), grid_color, 1.0)
		y += spacing
