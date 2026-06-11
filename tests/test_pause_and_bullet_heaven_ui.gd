extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_pause_menu_exit_paths()
	await _test_bullet_heaven_ui_and_audio()

	if failures.is_empty():
		print("Pause and Bullet Heaven UI tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _test_pause_menu_exit_paths() -> void:
	var main_scene: PackedScene = load("res://Main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	main.start_menu.visible = false
	var pause_menu = main.pause_menu

	var escape_event := InputEventAction.new()
	escape_event.action = &"ui_cancel"
	escape_event.pressed = true
	main._unhandled_input(escape_event)
	_expect(paused and pause_menu.visible, "First ESC should open the pause menu")
	pause_menu._unhandled_input(escape_event)
	_expect(not paused and not pause_menu.visible, "Second ESC should close the pause menu")

	main._open_pause()
	pause_menu._on_resume()
	_expect(not paused and not pause_menu.visible, "Continue button should close the pause menu")
	main.free()
	await process_frame

func _test_bullet_heaven_ui_and_audio() -> void:
	var scene: PackedScene = load("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var stage = scene.instantiate()
	root.add_child(stage)
	await process_frame

	var level_up_panel = stage.get_node("LevelUpLayer/LevelUpPanel")
	_expect(level_up_panel is PanelContainer, "Level-up choices should have a panel background")
	var panel_style := level_up_panel.get_theme_stylebox("panel") as StyleBoxFlat
	_expect(panel_style != null and panel_style.bg_color.a >= 0.9, "Level-up background should be opaque")
	var sfx_bus_index: int = AudioServer.get_bus_index(&"SFX")
	_expect(sfx_bus_index >= 0, "SFX bus should exist")
	if sfx_bus_index >= 0:
		_expect(AudioServer.get_bus_volume_db(sfx_bus_index) <= -14.0, "SFX bus should be substantially quieter")

	stage.audio_controller.stop_all_sfx()
	stage.free()
	await process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
