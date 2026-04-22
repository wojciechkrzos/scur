extends CanvasLayer

@onready var lives_label = $LivesLabel
@onready var kills_label = $KillsLabel
@onready var timer_label = $TimerLabel
@onready var level_label = $LevelLabel
@onready var experience_label = $ExperienceLabel
@onready var pattern_label = $PatternLabel
@onready var result_label = $ResultLabel

var result_dimmer: ColorRect

func _ready() -> void:
	result_dimmer = ColorRect.new()
	result_dimmer.name = "ResultDimmer"
	result_dimmer.anchors_preset = Control.PRESET_FULL_RECT
	result_dimmer.anchor_right = 1.0
	result_dimmer.anchor_bottom = 1.0
	result_dimmer.grow_horizontal = Control.GROW_DIRECTION_BOTH
	result_dimmer.grow_vertical = Control.GROW_DIRECTION_BOTH
	result_dimmer.color = Color(0.0, 0.0, 0.0, 0.55)
	result_dimmer.visible = false
	add_child(result_dimmer)

	if result_label != null:
		result_label.anchors_preset = Control.PRESET_CENTER
		result_label.anchor_left = 0.5
		result_label.anchor_top = 0.5
		result_label.anchor_right = 0.5
		result_label.anchor_bottom = 0.5
		result_label.offset_left = -340.0
		result_label.offset_top = -70.0
		result_label.offset_right = 340.0
		result_label.offset_bottom = 70.0
		result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		result_label.add_theme_font_size_override("font_size", 52)
	move_child(result_dimmer, 0)

func setup(duration: float, lives: int) -> void:
	update_lives(lives)
	update_kills(0)
	update_timer(duration)
	update_level(1)
	update_experience(0, 5)
	update_pattern("IMPULS")
	result_label.visible = false
	if result_dimmer != null:
		result_dimmer.visible = false

func update_lives(n: int) -> void:
	lives_label.text = "Życia: " + "♥ ".repeat(max(n, 0))

func update_kills(k: int) -> void:
	kills_label.text = "Eliminacje: %04d" % k

func update_timer(t: float) -> void:
	var secs = max(t, 0.0)
	timer_label.text = "Czas: %05.1f" % secs
	if secs < 8.0:
		timer_label.modulate = Color(1.0, 0.4, 0.4)
	else:
		timer_label.modulate = Color(1.0, 1.0, 1.0)

func update_level(level: int) -> void:
	level_label.text = "Poziom: %02d" % level

func update_experience(current_xp: int, xp_to_next: int) -> void:
	experience_label.text = "PD: %02d / %02d" % [current_xp, xp_to_next]

func update_pattern(name_text: String) -> void:
	pattern_label.text = "Tryb: " + name_text

func show_result(result: String) -> void:
	result_label.visible = true
	if result_dimmer != null:
		result_dimmer.visible = true
	if result == "win":
		result_label.text = "✦ ZWYCIĘSTWO ✦"
		result_label.modulate = Color(0.5, 1.0, 0.5)
	else:
		result_label.text = "✦ DERATYZACJA ✦"
		result_label.modulate = Color(1.0, 0.4, 0.4)
