## HUD.gd
## Interfejs gracza: życia, score, timer, HP bossa, wynik walki.

extends CanvasLayer

@onready var lives_label = $LivesLabel
@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel
@onready var boss_hp_bar = $BossHPBar
@onready var win_label = $WinLabel

var _score_flash_timer: float = 0.0

func setup(win_condition: int, time_limit: float, boss_max_hp: float) -> void:
	boss_hp_bar.max_value = boss_max_hp
	boss_hp_bar.value = boss_max_hp
	
	if win_condition == 0:  # SURVIVE
		timer_label.modulate = Color(0.4, 1.0, 0.4)
	else:  # DAMAGE
		timer_label.modulate = Color(1.0, 0.6, 0.2)
	
	update_lives(3)


func _process(delta: float) -> void:
	if _score_flash_timer > 0:
		_score_flash_timer -= delta
		score_label.modulate = Color(1, 1, 0.3) if fmod(_score_flash_timer * 10, 1) > 0.5 else Color(1,1,1)
	else:
		score_label.modulate = Color(1, 1, 1)


func update_lives(n: int) -> void:
	lives_label.text = "Lives: " + "♥ ".repeat(max(n, 0))


func update_score(s: int) -> void:
	score_label.text = "Score: %07d" % s


func update_timer(t: float) -> void:
	var secs: float = max(t, 0.0)
	timer_label.text = "Time: %05.1f" % secs
	# Czerwony gdy mało czasu
	if secs < 10.0:
		timer_label.modulate = Color(1.0, 0.3, 0.3)

func hide_timer() -> void:
	timer_label.visible = false

func update_boss_hp(hp: float, max_hp: float) -> void:
	boss_hp_bar.value = hp


func flash_score() -> void:
	_score_flash_timer = 0.3


func show_result(result: String) -> void:
	win_label.visible = true
	if result == "win":
		win_label.text = "✦ CLEAR ✦"
		win_label.modulate = Color(0.4, 1.0, 0.4)
	else:
		win_label.text = "✦ DERATYZACJA ✦"
		win_label.modulate = Color(1.0, 0.3, 0.3)
	win_label.scale = Vector2(2, 2)
