extends CanvasLayer

signal closed

@onready var ending_label: Label = $CenterContainer/Panel/VBoxContainer/EndingLabel
@onready var title_label: Label = $CenterContainer/Panel/VBoxContainer/TitleLabel
@onready var detail_label: Label = $CenterContainer/Panel/VBoxContainer/DetailLabel
@onready var button: Button = $CenterContainer/Panel/VBoxContainer/ContinueButton

func _ending_to_number(id: String) -> int:
	var map := {
		"aaa": 1,
		"aab": 2,
		"aba": 3,
		"abb": 4,
		"baa": 5,
		"bab": 6,
		"bba": 7,
		"bbb": 8,
	}
	return int(map.get(id, 0))

func _ready() -> void:
	_apply_styles()
	button.pressed.connect(func():
		closed.emit()
		queue_free()
	)

func show_result(ending_id: String, is_new: bool) -> void:
	visible = true
	var num := _ending_to_number(ending_id)
	title_label.text = "ZWYCIESTWO"
	if is_new:
		ending_label.text = "NOWE ZAKONCZENIE #%d" % num
	else:
		ending_label.text = "ZAKONCZENIE #%d" % num
	var detail_status := "Zapisano w archiwum endingow." if is_new else "To zakonczenie bylo juz odblokowane."
	detail_label.text = "Sciezka: %s\n%s" % [
		ending_id.to_upper(),
		detail_status,
	]

func _apply_styles() -> void:
	var panel := $CenterContainer/Panel as Panel
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.0, 0.008, 0.96)
	panel_style.border_color = Color(0.92, 0.02, 0.06, 1.0)
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(0)
	panel_style.shadow_color = Color(0.85, 0.0, 0.04, 0.35)
	panel_style.shadow_size = 26
	panel.add_theme_stylebox_override("panel", panel_style)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.0, 0.014, 1.0)
	normal.border_color = Color(0.78, 0.04, 0.08, 1.0)
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(0)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.32, 0.02, 0.04, 1.0)
	hover.border_color = Color(1.0, 0.92, 0.84, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_font_size_override("font_size", 24)
