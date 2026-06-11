extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var stage = scene.instantiate()
	stage.configure_stage("stage2")
	root.add_child(stage)
	await process_frame
	stage.spawn_timer.stop()

	_expect(stage._get_swarm_source_direction(0) == Vector2.LEFT, "Left swarm should point left")
	_expect(stage._get_swarm_source_direction(1) == Vector2.RIGHT, "Right swarm should point right")
	_expect(stage._get_swarm_source_direction(2) == Vector2.UP, "Top swarm should point up")
	_expect(stage._get_swarm_source_direction(3) == Vector2.DOWN, "Bottom swarm should point down")

	stage.swarm_event_elapsed = stage.swarm_event_interval
	stage._update_swarm_event(0.0)
	_expect(stage.pending_swarm_side >= 0, "Swarm side should be selected before spawning")
	_expect(stage.swarm_warning_indicator.active, "Warning indicator should activate before spawning")
	_expect(stage.enemy_container.get_child_count() == 0, "Swarm should wait during warning window")

	stage._update_swarm_event(stage.swarm_warning_duration)
	_expect(stage.pending_swarm_side == -1, "Pending swarm should clear after spawning")
	_expect(not stage.swarm_warning_indicator.active, "Warning indicator should hide after spawning")
	_expect(stage.enemy_container.get_child_count() == stage.swarm_enemy_count, "Stage 2 swarm should spawn nine enemies")

	stage.audio_controller.stop_all_sfx()
	await create_timer(1.0).timeout
	stage.queue_free()
	await process_frame
	if failures.is_empty():
		print("Bullet Heaven swarm tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
