extends CanvasLayer

signal start_pressed

@onready var main_panel: Control = $Root/MenuPanel/PanelMargin/MainVBox
@onready var options_panel: Control = $Root/MenuPanel/PanelMargin/OptionsVBox
@onready var credits_panel: Control = $Root/MenuPanel/PanelMargin/CreditsVBox
@onready var start_button: Button = $Root/MenuPanel/PanelMargin/MainVBox/StartButton
@onready var options_button: Button = $Root/MenuPanel/PanelMargin/MainVBox/OptionsButton
@onready var credits_button: Button = $Root/MenuPanel/PanelMargin/MainVBox/CreditsButton
@onready var exit_button: Button = $Root/MenuPanel/PanelMargin/MainVBox/ExitButton
@onready var options_back_button: Button = $Root/MenuPanel/PanelMargin/OptionsVBox/BackButton
@onready var credits_back_button: Button = $Root/MenuPanel/PanelMargin/CreditsVBox/BackButton
@onready var music_slider: HSlider = $Root/MenuPanel/PanelMargin/OptionsVBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Root/MenuPanel/PanelMargin/OptionsVBox/SFXRow/SFXSlider
@onready var music_value: Label = $Root/MenuPanel/PanelMargin/OptionsVBox/MusicRow/MusicValue
@onready var sfx_value: Label = $Root/MenuPanel/PanelMargin/OptionsVBox/SFXRow/SFXValue


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_show_options)
	credits_button.pressed.connect(_show_credits)
	exit_button.pressed.connect(_on_exit_pressed)
	options_back_button.pressed.connect(_show_main_panel)
	credits_back_button.pressed.connect(_show_main_panel)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	_apply_pixel_styles()
	_sync_audio_sliders()
	_show_main_panel()


func _on_start_pressed() -> void:
	start_pressed.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _show_options() -> void:
	main_panel.visible = false
	credits_panel.visible = false
	options_panel.visible = true
	_sync_audio_sliders()
	options_back_button.grab_focus()


func _show_credits() -> void:
	main_panel.visible = false
	options_panel.visible = false
	credits_panel.visible = true
	credits_back_button.grab_focus()


func _show_main_panel() -> void:
	main_panel.visible = true
	options_panel.visible = false
	credits_panel.visible = false
	start_button.grab_focus()


func _sync_audio_sliders() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		music_slider.set_value_no_signal(audio_manager.get_music_volume() * 100.0)
		sfx_slider.set_value_no_signal(audio_manager.get_sfx_volume() * 100.0)
	_update_volume_labels()


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
	if options_panel.visible or credits_panel.visible:
		_show_main_panel()
		get_viewport().set_input_as_handled()


func _apply_pixel_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.02, 0.045, 0.94)
	panel_style.border_color = Color(0.76, 0.3, 0.24, 1.0)
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(0)
	panel_style.shadow_color = Color(0.55, 0.05, 0.08, 0.45)
	panel_style.shadow_size = 18
	$Root/MenuPanel.add_theme_stylebox_override("panel", panel_style)

	for button in [start_button, options_button, credits_button, exit_button, options_back_button, credits_back_button]:
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
