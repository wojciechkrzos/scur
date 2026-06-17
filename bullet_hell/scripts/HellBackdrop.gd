extends Node2D

var play_area := Rect2()
var stars: Array[Dictionary] = []
var elapsed := 0.0

func setup(area: Rect2) -> void:
	play_area = area
	stars.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7331
	for index in 72:
		stars.append({
			"position": Vector2(
				rng.randf_range(area.position.x + 8.0, area.end.x - 8.0),
				rng.randf_range(area.position.y + 8.0, area.end.y - 8.0)
			),
			"radius": rng.randf_range(0.7, 1.8),
			"phase": rng.randf_range(0.0, TAU),
		})
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	if play_area.size == Vector2.ZERO:
		return
	draw_rect(play_area, Color(0.018, 0.018, 0.052, 1.0), true)
	for star in stars:
		var pulse := 0.42 + 0.34 * sin(elapsed * 1.7 + float(star.phase))
		draw_circle(star.position, float(star.radius), Color(0.34, 0.72, 1.0, pulse))
	for y in range(int(play_area.position.y), int(play_area.end.y), 8):
		draw_line(Vector2(play_area.position.x, y), Vector2(play_area.end.x, y), Color(0.2, 0.35, 0.58, 0.035), 1.0)
	var edge_color := Color(0.0, 0.0, 0.03, 0.28)
	draw_rect(Rect2(play_area.position, Vector2(play_area.size.x, 24.0)), edge_color, true)
	draw_rect(Rect2(Vector2(play_area.position.x, play_area.end.y - 24.0), Vector2(play_area.size.x, 24.0)), edge_color, true)
