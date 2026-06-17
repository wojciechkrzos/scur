## HUD.gd
## Nowoczesny, czysty interfejs bez pozycjonowania na sztywno.

extends CanvasLayer

@onready var lives_label = $UIMainContainer/Sidebar/LivesLabel
@onready var score_label = $UIMainContainer/Sidebar/ScoreLabel
@onready var timer_label = $UIMainContainer/TopRow/TimerLabel
@onready var boss_hp_label = $UIMainContainer/TopRow/BossHPContainer/BossHPLabel
@onready var boss_hp_bar = $UIMainContainer/TopRow/BossHPContainer/BossHPBar
@onready var win_label = $WinLabel

var result_dimmer: ColorRect
var damage_border: Panel
var _score_flash_timer: float = 0.0

func setup(win_condition: int, _time_limit: float, boss_max_hp: float) -> void:
	if damage_border == null:
		_setup_damage_border()
	if result_dimmer == null:
		result_dimmer = ColorRect.new()
		result_dimmer.anchors_preset = Control.PRESET_FULL_RECT
		result_dimmer.color = Color(0.01, 0.01, 0.03, 0.75)
		result_dimmer.visible = false
		add_child(result_dimmer)
		move_child(result_dimmer, 0)

	win_label.anchors_preset = Control.PRESET_CENTER
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 44)
	win_label.add_theme_color_override("font_outline_color", Color.BLACK)
	win_label.add_theme_constant_override("outline_size", 10)
	win_label.visible = false
	result_dimmer.visible = false
	
	# Stylizacja paska zdrowia bossa na agresywny, neonowy róż
	boss_hp_bar.max_value = boss_max_hp
	boss_hp_bar.value = boss_max_hp
	boss_hp_bar.show_percentage = false
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.08, 0.08, 0.12, 0.8)
	sb_bg.corner_radius_top_left = 3
	sb_bg.corner_radius_bottom_left = 3
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.95, 0.0, 0.35)
	sb_fill.corner_radius_top_left = 3
	sb_fill.corner_radius_bottom_left = 3
	
	boss_hp_bar.add_theme_stylebox_override("background", sb_bg)
	boss_hp_bar.add_theme_stylebox_override("fill", sb_fill)
	
	boss_hp_label.visible = win_condition != 0
	boss_hp_bar.visible = win_condition != 0
	
	# Nadanie klimatycznych wielkości czcionek i obramowania tekstu
	_apply_text_style(timer_label, 36)
	_apply_text_style(lives_label, 22)
	_apply_text_style(score_label, 22)
	_apply_text_style(boss_hp_label, 16)
	
	if win_condition == 0: # SURVIVE
		timer_label.modulate = Color(0.3, 0.9, 0.4)
	else: # DAMAGE
		timer_label.modulate = Color(1.0, 0.6, 0.1)
	
	update_lives(3)

func _apply_text_style(label: Label, size: int) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 6)

func _process(delta: float) -> void:
	if _score_flash_timer > 0:
		_score_flash_timer -= delta
		score_label.modulate = Color(1, 0.9, 0.2) if fmod(_score_flash_timer * 12, 1) > 0.5 else Color(1,1,1)
	else:
		score_label.modulate = Color(1, 1, 1)

func update_lives(n: int) -> void:
	lives_label.text = "ŻYCIA: " + "♥ ".repeat(max(n, 0))
	lives_label.modulate = Color(1.0, 0.3, 0.45) if n > 0 else Color(0.5, 0.5, 0.5)

func update_score(s: int) -> void:
	score_label.text = "WYNIK: %07d" % s

func update_timer(t: float) -> void:
	var secs: float = max(t, 0.0)
	timer_label.text = "%04.1f" % secs
	if secs < 10.0:
		timer_label.modulate = Color(1.0, 0.2, 0.2)

func hide_timer() -> void:
	timer_label.visible = false

func update_boss_hp(hp: float, _max_hp: float) -> void:
	boss_hp_bar.value = hp

func set_boss_hp_visible(enabled: bool) -> void:
	boss_hp_label.visible = enabled
	boss_hp_bar.visible = enabled

func flash_score() -> void:
	_score_flash_timer = 0.3

func play_damage_feedback() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.play_player_hit()
	if damage_border == null:
		_setup_damage_border()
	damage_border.visible = true
	damage_border.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(damage_border, "modulate:a", 0.0, 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): damage_border.visible = false)

func _setup_damage_border() -> void:
	damage_border = Panel.new()
	damage_border.name = "DamageBorder"
	damage_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.0, 0.04, 0.1)
	style.border_color = Color(1.0, 0.02, 0.08, 0.95)
	style.set_border_width_all(22)
	style.shadow_color = Color(1.0, 0.0, 0.05, 0.7)
	style.shadow_size = 30
	damage_border.add_theme_stylebox_override("panel", style)
	damage_border.visible = false
	add_child(damage_border)

func show_result(result: String) -> void:
	win_label.visible = true
	if result_dimmer != null:
		result_dimmer.visible = true
	if result == "win":
		win_label.text = "✦ ZWYCIĘSTWO ✦"
		win_label.modulate = Color(0.3, 1.0, 0.5)
	else:
		win_label.text = "✦ DERATYZACJA ✦"
		win_label.modulate = Color(1.0, 0.2, 0.2)
