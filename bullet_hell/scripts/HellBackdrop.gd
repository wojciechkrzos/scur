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
	draw_rect(play_area, Color(0.012, 0.008, 0.01, 1.0), true)
	draw_rect(play_area.grow(-10.0), Color(0.055, 0.0, 0.008, 0.26), false, 1.0)
	for star in stars:
		var pulse := 0.42 + 0.34 * sin(elapsed * 1.7 + float(star.phase))
		var red_pulse := 0.34 + 0.24 * sin(elapsed * 2.1 + float(star.phase))
		draw_circle(star.position, float(star.radius), Color(1.0, 0.96, 0.9, pulse * 0.42))
		draw_circle(star.position + Vector2(1.5, 0.0), float(star.radius) * 0.8, Color(0.92, 0.0, 0.08, red_pulse))
	for y in range(int(play_area.position.y), int(play_area.end.y), 8):
		draw_line(Vector2(play_area.position.x, y), Vector2(play_area.end.x, y), Color(0.85, 0.0, 0.08, 0.035), 1.0)
	for x in range(int(play_area.position.x), int(play_area.end.x), 24):
		var wobble := sin(elapsed * 1.4 + float(x) * 0.03) * 7.0
		draw_line(Vector2(x + wobble, play_area.position.y), Vector2(x - wobble, play_area.end.y), Color(1.0, 0.98, 0.92, 0.025), 1.0)
	var edge_color := Color(0.0, 0.0, 0.0, 0.48)
	draw_rect(Rect2(play_area.position, Vector2(play_area.size.x, 24.0)), edge_color, true)
	draw_rect(Rect2(Vector2(play_area.position.x, play_area.end.y - 24.0), Vector2(play_area.size.x, 24.0)), edge_color, true)
