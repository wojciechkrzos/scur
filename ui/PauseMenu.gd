extends CanvasLayer

signal resume_pressed
signal main_menu_pressed

@onready var menu_panel: Control = $CenterPanel/PanelMargin/MenuVBox
@onready var options_panel: Control = $CenterPanel/PanelMargin/OptionsVBox
@onready var tutorial_label: Label = $CenterPanel/PanelMargin/MenuVBox/InfoGrid/TutorialLabel
@onready var objective_label: Label = $CenterPanel/PanelMargin/MenuVBox/InfoGrid/ObjectiveLabel
@onready var continue_button: Button = $CenterPanel/PanelMargin/MenuVBox/ContinueButton
@onready var options_button: Button = $CenterPanel/PanelMargin/MenuVBox/OptionsButton
@onready var main_menu_button: Button = $CenterPanel/PanelMargin/MenuVBox/MainMenuButton
@onready var options_back_button: Button = $CenterPanel/PanelMargin/OptionsVBox/BackButton
@onready var music_slider: HSlider = $CenterPanel/PanelMargin/OptionsVBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterPanel/PanelMargin/OptionsVBox/SFXRow/SFXSlider
@onready var music_value: Label = $CenterPanel/PanelMargin/OptionsVBox/MusicRow/MusicValue
@onready var sfx_value: Label = $CenterPanel/PanelMargin/OptionsVBox/SFXRow/SFXValue

var _showing_options := false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_resume)
	options_button.pressed.connect(_show_options)
	main_menu_button.pressed.connect(_on_main_menu)
	options_back_button.pressed.connect(_show_main_panel)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	_apply_pixel_styles()


func show_menu(tutorial_text: String, objective_text: String) -> void:
	tutorial_label.text = "STEROWANIE\n" + tutorial_text
	objective_label.text = "AKTUALNY CEL\n" + objective_text
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		music_slider.set_value_no_signal(audio_manager.get_music_volume() * 100.0)
		sfx_slider.set_value_no_signal(audio_manager.get_sfx_volume() * 100.0)
	_update_volume_labels()
	_show_main_panel()
	visible = true
	get_tree().paused = true
	continue_button.grab_focus()


func _on_resume() -> void:
	visible = false
	get_tree().paused = false
	resume_pressed.emit()


func _on_main_menu() -> void:
	visible = false
	get_tree().paused = false
	main_menu_pressed.emit()


func _show_options() -> void:
	_showing_options = true
	menu_panel.visible = false
	options_panel.visible = true
	options_back_button.grab_focus()


func _show_main_panel() -> void:
	_showing_options = false
	menu_panel.visible = true
	options_panel.visible = false
	if visible:
		continue_button.grab_focus()


func _on_music_changed(value: float) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.set_music_volume(value / 100.0)
	_update_volume_labels()


func _on_sfx_changed(value: float) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.set_sfx_volume(value / 100.0)
	_update_volume_labels()


func _update_volume_labels() -> void:
	music_value.text = "%d%%" % roundi(music_slider.value)
	sfx_value.text = "%d%%" % roundi(sfx_slider.value)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel"):
		return
	if _showing_options:
		_show_main_panel()
	else:
		_on_resume()
	get_viewport().set_input_as_handled()


func _apply_pixel_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.02, 0.045, 0.97)
	panel_style.border_color = Color(0.76, 0.3, 0.24, 1.0)
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(0)
	panel_style.shadow_color = Color(0.55, 0.05, 0.08, 0.4)
	panel_style.shadow_size = 16
	$CenterPanel.add_theme_stylebox_override("panel", panel_style)

	for button in [continue_button, options_button, main_menu_button, options_back_button]:
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.10, 0.075, 0.15, 1.0)
		normal.border_color = Color(0.52, 0.26, 0.3, 1.0)
		normal.set_border_width_all(3)
		normal.set_corner_radius_all(0)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.32, 0.10, 0.15, 1.0)
		hover.border_color = Color(1.0, 0.62, 0.32, 1.0)
		var pressed := hover.duplicate() as StyleBoxFlat
		pressed.bg_color = Color(0.48, 0.12, 0.16, 1.0)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("focus", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_font_size_override("font_size", 25)
