extends Node2D

var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	rotation = elapsed * 1.8
	queue_redraw()

func _draw() -> void:
	var pulse := 0.75 + sin(elapsed * 6.0) * 0.18
	draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 32, Color(0.1, 0.95, 1.0, pulse), 2.0)
	draw_arc(Vector2.ZERO, 8.0, 0.0, TAU, 24, Color(1.0, 0.25, 0.72, 0.95), 2.0)
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var direction := Vector2.from_angle(angle)
		draw_line(direction * 15.0, direction * 20.0, Color(1.0, 0.82, 0.24, pulse), 2.0)
