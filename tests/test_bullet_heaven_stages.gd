extends SceneTree

const BHEnemy = preload("res://bullet_heaven/scripts/BHEnemy.gd")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://bullet_heaven/scenes/BulletHeaven.tscn")
	var stage = scene.instantiate()

	stage.configure_stage("stage1")
	_expect(stage.stage_duration == 45.0, "Stage 1 should last 45 seconds")
	_expect(not stage.swarm_enabled, "Stage 1 should not spawn assault waves")
	_expect(stage.hunter_spawn_chance == 0.0 and stage.elite_spawn_chance == 0.0, "Stage 1 should only use goons and brutes")

	stage.configure_stage("stage2")
	_expect(stage.stage_duration == 60.0, "Stage 2 should last 60 seconds")
	_expect(stage.swarm_enabled, "Stage 2 should introduce assault waves")
	_expect(stage.enemy_speed_multiplier > 1.0, "Stage 2 enemies should be faster")
	_expect(stage.base_spawn_interval < 0.6, "Stage 2 should spawn enemies more frequently")

	stage.configure_stage("stage3")
	_expect(stage.stage_duration == 180.0, "Stage 3 should last three minutes")
	stage.wave_level = 12
	_expect(stage._get_regular_spawn_batch_size() == 3, "Late Stage 3 should spawn three regular enemies per tick")
	_expect(stage.hunter_spawn_chance > 0.0 and stage.elite_spawn_chance > 0.0, "Stage 3 should add hunters and enforcers")
	root.add_child(stage)
	await process_frame
	stage.spawn_timer.stop()
	stage._spawn_enemy_of_kind(BHEnemy.EnemyKind.HUNTER, Vector2(-20.0, 100.0))
	stage._spawn_enemy_of_kind(BHEnemy.EnemyKind.ELITE, Vector2(820.0, 100.0))
	await process_frame
	_expect(stage.enemy_container.get_child_count() == 2, "Stage 3 enemy variants should construct inside the live scene")

	var hunter = BHEnemy.new()
	hunter.setup(BHEnemy.EnemyKind.HUNTER, null, Rect2(), Vector2.ZERO, null, 1.0, 1.0)
	_expect(hunter.acceleration_per_second > 0.0 and hunter.hp == 3, "Hunters should accelerate and survive multiple hits")
	var elite = BHEnemy.new()
	elite.setup(BHEnemy.EnemyKind.ELITE, null, Rect2(), Vector2.ZERO, null, 1.0, 1.0)
	_expect(elite.hp == 14 and elite.xp_value == 7, "Enforcers should be durable high-value targets")

	hunter.free()
	elite.free()
	stage.audio_controller.stop_all_sfx()
	stage.queue_free()
	await process_frame
	if failures.is_empty():
		print("Bullet Heaven stage variation tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
