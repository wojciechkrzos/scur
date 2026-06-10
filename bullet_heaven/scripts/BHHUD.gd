extends CanvasLayer

const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

@onready var status_panel: PanelContainer = $StatusPanel
@onready var lives_label: Label = $StatusPanel/StatusMargin/StatusVBox/LivesLabel
@onready var kills_label: Label = $StatusPanel/StatusMargin/StatusVBox/KillsLabel
@onready var level_label: Label = $StatusPanel/StatusMargin/StatusVBox/LevelLabel
@onready var timer_panel: PanelContainer = $TimerPanel
@onready var timer_label: Label = $TimerPanel/TimerMargin/TimerVBox/TimerLabel
@onready var wave_label: Label = $TimerPanel/TimerMargin/TimerVBox/WaveLabel
@onready var experience_panel: PanelContainer = $ExperiencePanel
@onready var experience_label: Label = $ExperiencePanel/ExperienceMargin/ExperienceVBox/ExperienceLabel
@onready var experience_bar: ProgressBar = $ExperiencePanel/ExperienceMargin/ExperienceVBox/ExperienceBar
@onready var weapon_panel: PanelContainer = $WeaponPanel
@onready var weapon_list: VBoxContainer = $WeaponPanel/WeaponMargin/WeaponVBox/WeaponList
@onready var result_label: Label = $ResultLabel

var result_dimmer: ColorRect

func _ready() -> void:
	_setup_styles()
	result_dimmer = ColorRect.new()
	result_dimmer.name = "ResultDimmer"
	result_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_dimmer.color = Color(0.0, 0.0, 0.0, 0.62)
	result_dimmer.visible = false
	add_child(result_dimmer)
	move_child(result_dimmer, 0)

func setup(duration: float, lives: int) -> void:
	update_lives(lives)
	update_kills(0)
	update_timer(duration)
	update_wave(1)
	update_level(1)
	update_experience(0, 5)
	result_label.visible = false
	if result_dimmer != null:
		result_dimmer.visible = false

func update_lives(count: int) -> void:
	lives_label.text = "ŻYCIA  " + "♥ ".repeat(maxi(count, 0))

func update_kills(count: int) -> void:
	kills_label.text = "ELIMINACJE  %04d" % count

func update_timer(time_left: float) -> void:
	var seconds: float = maxf(time_left, 0.0)
	timer_label.text = "%05.1f" % seconds
	timer_label.modulate = Color(1.0, 0.38, 0.38) if seconds < 8.0 else Color(0.96, 0.98, 1.0)

func update_wave(wave: int) -> void:
	wave_label.text = "FALA %02d" % wave

func update_level(level: int) -> void:
	level_label.text = "POZIOM  %02d" % level

func update_experience(current_xp: int, xp_to_next: int) -> void:
	experience_label.text = "PD  %02d / %02d" % [current_xp, xp_to_next]
	experience_bar.max_value = maxf(float(xp_to_next), 1.0)
	experience_bar.value = clampf(float(current_xp), 0.0, experience_bar.max_value)

func update_pattern(_name_text: String) -> void:
	pass

func update_weapon_inventory(inventory: Dictionary) -> void:
	for child in weapon_list.get_children():
		child.queue_free()

	var weapon_ids: Array[int] = []
	for weapon_id in inventory.keys():
		if int(inventory[weapon_id]) > 0:
			weapon_ids.append(int(weapon_id))
	weapon_ids.sort()

	for weapon_id in weapon_ids:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(250.0, 38.0)
		row.add_theme_constant_override("separation", 10)
		var marker := ColorRect.new()
		marker.custom_minimum_size = Vector2(8.0, 30.0)
		marker.color = _get_weapon_color(weapon_id)
		row.add_child(marker)
		var name_label := Label.new()
		name_label.text = BHPowerups.get_weapon_name(weapon_id)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.add_theme_font_size_override("font_size", 17)
		row.add_child(name_label)
		var level_label_node := Label.new()
		level_label_node.text = "POZ. %d" % int(inventory[weapon_id])
		level_label_node.modulate = Color(1.0, 0.74, 0.32)
		level_label_node.add_theme_font_size_override("font_size", 17)
		row.add_child(level_label_node)
		weapon_list.add_child(row)

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

func _setup_styles() -> void:
	status_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.28, 0.82, 0.68)))
	timer_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(1.0, 0.66, 0.25)))
	weapon_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.58, 0.68, 1.0)))
	experience_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.42, 0.78, 1.0)))
	var progress_background := StyleBoxFlat.new()
	progress_background.bg_color = Color(0.04, 0.06, 0.09, 0.92)
	progress_background.set_corner_radius_all(5)
	var progress_fill := progress_background.duplicate() as StyleBoxFlat
	progress_fill.bg_color = Color(0.28, 0.78, 1.0, 1.0)
	experience_bar.add_theme_stylebox_override("background", progress_background)
	experience_bar.add_theme_stylebox_override("fill", progress_fill)

func _make_panel_style(border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.045, 0.07, 0.9)
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	return style

func _get_weapon_color(weapon_id: int) -> Color:
	var colors: Array[Color] = [
		Color(0.35, 0.9, 1.0),
		Color(0.42, 1.0, 0.55),
		Color(0.78, 0.52, 1.0),
		Color(1.0, 0.86, 0.28),
		Color(1.0, 0.38, 0.18),
		Color(0.94, 0.92, 0.82),
	]
	return colors[clampi(weapon_id, 0, colors.size() - 1)]
