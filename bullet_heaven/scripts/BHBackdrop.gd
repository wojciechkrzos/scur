extends Node2D

var visible_rect: Rect2 = Rect2(0, 0, 800, 600)
var scroll_offset: Vector2 = Vector2.ZERO
var world_size: Vector2 = Vector2.ZERO
var world_border_color: Color = Color(0.82, 0.89, 0.94, 0.92)
var world_border_thickness: float = 3.0
@export var background_texture: Texture2D = preload("res://assets/bullet_heaven/background.png")
@export var floor_texture: Texture2D = preload("res://assets/bullet_heaven/floor.png")
@export var show_debug_grid: bool = false

func setup(view_rect: Rect2, world_size_px: Vector2 = Vector2.ZERO) -> void:
	visible_rect = view_rect
	world_size = world_size_px
	queue_redraw()

func set_scroll_offset(new_offset: Vector2) -> void:
	scroll_offset = new_offset
	queue_redraw()

func _draw() -> void:
	draw_rect(visible_rect, Color(0.03, 0.05, 0.03, 1.0), true)

	if world_size != Vector2.ZERO and background_texture != null:
		var texture_size: Vector2 = background_texture.get_size()
		var world_top_left := visible_rect.get_center() - world_size * 0.5 + scroll_offset
		var texture_padding := (texture_size - world_size) * 0.5
		var texture_rect := Rect2(world_top_left - texture_padding, texture_size)
		draw_texture_rect(background_texture, texture_rect, false)

	if show_debug_grid:
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

	if world_size != Vector2.ZERO:
		var world_top_left := visible_rect.get_center() - world_size * 0.5 + scroll_offset
		var world_rect := Rect2(world_top_left, world_size)
		draw_rect(world_rect, world_border_color, false, world_border_thickness)
