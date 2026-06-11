extends SceneTree

const BHEnemy = preload("res://bullet_heaven/scripts/BHEnemy.gd")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_animation(BHEnemy.EnemyKind.STANDARD, BHEnemy.AnimState.WALK, 8)
	await _test_animation(BHEnemy.EnemyKind.STANDARD, BHEnemy.AnimState.ATTACK, 8)
	await _test_animation(BHEnemy.EnemyKind.TANK, BHEnemy.AnimState.WALK, 4)
	await _test_animation(BHEnemy.EnemyKind.TANK, BHEnemy.AnimState.ATTACK, 8)

	if failures.is_empty():
		print("Enemy sprite frame tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _test_animation(kind: int, state: int, expected_count: int) -> void:
	var target := Node2D.new()
	root.add_child(target)
	var enemy = BHEnemy.new()
	enemy.setup(kind, target, Rect2(0, 0, 800, 600))
	root.add_child(enemy)
	await process_frame

	enemy.current_anim_state = state
	var frame_count: int = enemy._get_animation_frame_count()
	_expect(frame_count == expected_count, "Unexpected frame count for enemy %d state %d" % [kind, state])
	var row: int = enemy._get_animation_row(state)
	var frame_size: Vector2i = enemy._get_enemy_frame_size()
	var image: Image = enemy.enemy_sprite.texture.get_image()
	for frame in frame_count:
		_expect(_frame_has_visible_pixels(image, frame_size, frame, row), "Blank frame %d used by enemy %d state %d" % [frame, kind, state])

	enemy.free()
	target.free()
	await process_frame

func _frame_has_visible_pixels(image: Image, frame_size: Vector2i, column: int, row: int) -> bool:
	var start_x: int = column * frame_size.x
	var start_y: int = row * frame_size.y
	for y in range(start_y, start_y + frame_size.y):
		for x in range(start_x, start_x + frame_size.x):
			if image.get_pixel(x, y).a > 0.01:
				return true
	return false

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
