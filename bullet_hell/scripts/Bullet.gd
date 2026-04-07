## Bullet.gd
## Pocisk bossa. Samoistnie się usuwa po wyjściu z planszy.
## Kierunek i prędkość ustawiane przez Boss.gd przez meta.

extends Area2D

var direction: Vector2 = Vector2.DOWN
var speed: float = 100.0
var play_area: Rect2

func _ready() -> void:
	# Pobierz parametry ustawione przez Boss._create_bullet()
	if has_meta("direction"):
		direction = get_meta("direction")
	if has_meta("speed"):
		speed = get_meta("speed")


func _process(delta: float) -> void:
	position += direction * speed * delta
	
	# Usuń pocisk gdy wyjdzie z planszy (z marginesem)
	if play_area != Rect2() and not play_area.grow(40).has_point(position):
		queue_free()
