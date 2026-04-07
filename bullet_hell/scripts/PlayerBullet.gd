## PlayerBullet.gd
## Pocisk gracza. Leci w górę, usuwa się po wyjściu z planszy.

extends Area2D

var direction: Vector2 = Vector2.UP
var speed: float = 450.0
var damage: float = 1.0
var play_area: Rect2

func _process(delta: float) -> void:
	position += direction * speed * delta
	
	if play_area != Rect2() and not play_area.grow(20).has_point(position):
		queue_free()
