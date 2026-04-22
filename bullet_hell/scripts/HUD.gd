## HUD.gd
## Interfejs gracza: życia, score, timer, HP bossa, wynik walki.

extends CanvasLayer

@onready var lives_label = $LivesLabel
@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel
@onready var boss_hp_bar = $BossHPBar
@onready var win_label = $WinLabel

var result_dimmer: ColorRect

var _score_flash_timer: float = 0.0

func setup(win_condition: int, _time_limit: float, boss_max_hp: float) -> void:
	if result_dimmer == null:
		result_dimmer = ColorRect.new()
		result_dimmer.anchors_preset = Control.PRESET_FULL_RECT
		result_dimmer.anchor_right = 1.0
		result_dimmer.anchor_bottom = 1.0
		result_dimmer.grow_horizontal = Control.GROW_DIRECTION_BOTH
		result_dimmer.grow_vertical = Control.GROW_DIRECTION_BOTH
		result_dimmer.color = Color(0.0, 0.0, 0.0, 0.58)
		result_dimmer.visible = false
		add_child(result_dimmer)
		move_child(result_dimmer, 0)

	win_label.anchors_preset = Control.PRESET_CENTER
	win_label.anchor_left = 0.5
	win_label.anchor_top = 0.5
	win_label.anchor_right = 0.5
	win_label.anchor_bottom = 0.5
	win_label.offset_left = -340.0
	win_label.offset_top = -70.0
	win_label.offset_right = 340.0
	win_label.offset_bottom = 70.0
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 52)
	win_label.visible = false
	result_dimmer.visible = false
	
	#TODO zmienic ten layout z "na sztywno" na np margin container, vbox container i top/bottom row hbox container
	lives_label.offset_top = 40
	score_label.offset_top = 60
	
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
	lives_label.text = "Życia: " + "♥ ".repeat(max(n, 0))


func update_score(s: int) -> void:
	score_label.text = "Wynik: %07d" % s


func update_timer(t: float) -> void:
	var secs: float = max(t, 0.0)
	timer_label.text = "Czas: %05.1f" % secs
	# Czerwony gdy mało czasu
	if secs < 10.0:
		timer_label.modulate = Color(1.0, 0.3, 0.3)

func hide_timer() -> void:
	timer_label.visible = false

func update_boss_hp(hp: float, _max_hp: float) -> void:
	boss_hp_bar.value = hp


func flash_score() -> void:
	_score_flash_timer = 0.3


func show_result(result: String) -> void:
	win_label.visible = true
	if result_dimmer != null:
		result_dimmer.visible = true
	if result == "win":
		win_label.text = "✦ ZWYCIĘSTWO ✦"
		win_label.modulate = Color(0.4, 1.0, 0.4)
	else:
		win_label.text = "✦ DERATYZACJA ✦"
		win_label.modulate = Color(1.0, 0.3, 0.3)
