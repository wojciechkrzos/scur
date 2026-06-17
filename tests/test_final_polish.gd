extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_pause_options_and_return()
	await _test_start_menu_sections()
	await _test_heaven_damage_and_stage2_art()
	await _test_bullet_hell_polish()
	await _test_visual_novel_music()
	if failures.is_empty():
		print("Final polish tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _test_pause_options_and_return() -> void:
	var dynamic_button := Button.new()
	root.add_child(dynamic_button)
	await process_frame
	await process_frame
	dynamic_button.pressed.emit()
	var global_audio = root.get_node_or_null("AudioManager")
	_expect(global_audio != null and global_audio._ui_player.playing, "Dynamically created buttons should play the global click sound")
	dynamic_button.free()
	var main_scene: PackedScene = load("res://Main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	main.start_menu.visible = false
	main._open_pause()
	var pause_menu = main.pause_menu
	pause_menu._show_options()
	_expect(pause_menu.options_panel.visible and not pause_menu.menu_panel.visible, "Options should replace the pause main panel")
	var escape := InputEventAction.new()
	escape.action = &"ui_cancel"
	escape.pressed = true
	pause_menu._unhandled_input(escape)
	_expect(pause_menu.menu_panel.visible and pause_menu.visible, "Escape from options should return to pause")
	pause_menu._on_main_menu()
	await process_frame
	_expect(not paused and main.start_menu.visible, "Main menu action should unpause and show start menu")
	main.free()
	await process_frame

func _test_start_menu_sections() -> void:
	var scene: PackedScene = load("res://ui/StartMenu.tscn")
	var menu = scene.instantiate()
	root.add_child(menu)
	await process_frame
	_expect(menu.main_panel.visible, "Main menu should open on the primary actions")
	_expect(menu.exit_button.text == "WYJDŹ", "Main menu should expose an exit action")
	menu._show_options()
	_expect(menu.options_panel.visible and not menu.main_panel.visible, "Main menu options should open audio controls")
	menu._show_credits()
	_expect(menu.credits_panel.visible and menu.credits_panel.get_node("Wojciech").text == "Wojciech Krzos", "Credits should list Wojciech Krzos")
	_expect(menu.credits_panel.get_node("Natalia").text == "Natalia Malinowska" and menu.credits_panel.get_node("Year").text == "2026", "Credits should list Natalia Malinowska and 2026")
	menu.free()
	await process_frame

func _test_heaven_damage_and_stage2_art() -> void:
	var scene: PackedScene = load("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var stage = scene.instantiate()
	stage.configure_stage("stage2")
	root.add_child(stage)
	await process_frame
	_expect(stage.obstacle_container.get_child_count() == 5, "Stage 2 should create five obstacles")
	for obstacle in stage.obstacle_container.get_children():
		_expect(obstacle.obstacle_texture != null and obstacle.hframes == 4 and obstacle.frame_count == 4, "Stage 2 obstacles should use animated pigeon art")
	stage.player.take_hit()
	_expect(stage.hud.damage_border.visible, "Taking damage should show the red screen border")
	stage.hud.show_result("win")
	_expect(stage.hud.result_label.anchor_right == 1.0 and stage.hud.result_label.anchor_bottom == 1.0, "Heaven result should be centered against the full viewport")
	stage.free()
	await process_frame

func _test_bullet_hell_polish() -> void:
	var scene: PackedScene = load("res://bullet_hell/scenes/BossFight.tscn")
	var fight = scene.instantiate()
	root.add_child(fight)
	await process_frame
	fight.start_fight(fight.BOSS_A)
	fight._finish_objective_intro()
	_expect(fight.get_node_or_null("HellBackdrop") != null, "Bullet Hell should add its animated backdrop")
	_expect(fight.player.focus_indicator.get_script() != null, "Bullet Hell focus indicator should use the ring renderer")
	fight.player.take_hit()
	_expect(fight.hud.damage_border.visible, "Bullet Hell damage should show the red screen border")
	fight.free()
	paused = false
	await process_frame

func _test_visual_novel_music() -> void:
	var scene: PackedScene = load("res://vn/dialogue_box.tscn")
	var dialogue = scene.instantiate()
	root.add_child(dialogue)
	await process_frame
	dialogue.start_dialogue([{"speaker": "Test", "text": "Ciemność.", "end_dialogue": true}])
	_expect(dialogue.music_player != null and dialogue.music_player.playing, "VN music should start with dialogue")
	dialogue._end_dialogue()
	await create_timer(0.85).timeout
	_expect(not dialogue.music_player.playing, "VN music should fade out when dialogue ends")
	dialogue.free()
	await process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
