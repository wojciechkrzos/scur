extends Node2D

signal fight_ended(result: String)

const BHEnemyScript = preload("res://bullet_heaven/scripts/BHEnemy.gd")
const BHExperienceOrbScript = preload("res://bullet_heaven/scripts/BHExperienceOrb.gd")
const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")
const BHObstacleScript = preload("res://bullet_heaven/scripts/BHObstacle.gd")

@export var stage_duration: float = 35.0
@export var base_spawn_interval: float = 0.6
@export var spawn_interval_floor: float = 0.2
@export var wave_step_seconds: float = 7.0
@export var world_scroll_speed: float = 520.0
@export var world_size_px: Vector2 = Vector2(1920.0, 1080.0)
@export var border_visibility_padding_px: Vector2 = Vector2(500.0, 500.0)
@export var initial_world_offset_px: Vector2 = Vector2(0.0, -180.0)
@export_file("*.webp", "*.png") var fountain_texture_path: String = "res://assets/bullet_heaven/fountain.png"
@export_file("*.png", "*.webp") var pigeon_texture_path: String = "res://assets/bullet_heaven/pigeon_eat.png"
@export var fountain_hframes: int = 4
@export var fountain_vframes: int = 1
@export var fountain_frame_count: int = 4
@export var fountain_fps: float = 8.0
@export var fountain_visual_scale: float = 1.0
@export var fountain_collision_radius: float = 120.0
@export var xp_pickup_radius: float = 34.0

const TANK_SPAWN_CHANCE := 0.2
const SWARM_EVENT_INTERVAL := 12.0
const SWARM_EVENT_ENEMY_COUNT := 9
const SWARM_EDGE_MARGIN := 18.0

var fight_active: bool = false
var time_remaining: float = 0.0
var kills: int = 0
var wave_level: int = 1
var current_spawn_interval: float = 0.6
var play_area_rect: Rect2 = Rect2(0, 0, 800, 600)
var world_offset: Vector2 = Vector2.ZERO
var world_scroll_limits: Vector2 = Vector2.ZERO
var player_collision_radius: float = 7.0
var swarm_event_elapsed: float = 0.0
var pending_level_ups: int = 0
var current_powerup_choices: Array[int] = []
var level_up_dimmer: ColorRect

@onready var backdrop = $Backdrop
@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var pickup_container = $PickupContainer
@onready var bullet_container = $BulletContainer
@onready var obstacle_container = $ObstacleContainer
@onready var spawn_timer = $SpawnTimer
@onready var hud = $HUD
@onready var level_up_layer = $LevelUpLayer
@onready var level_up_panel = $LevelUpLayer/LevelUpPanel
@onready var level_up_title = $LevelUpLayer/LevelUpPanel/LevelUpVBox/LevelUpTitle
@onready var level_up_subtitle = $LevelUpLayer/LevelUpPanel/LevelUpVBox/LevelUpSubtitle
@onready var level_up_hint = $LevelUpLayer/LevelUpPanel/LevelUpVBox/LevelUpHint
@onready var choice_button_1 = $LevelUpLayer/LevelUpPanel/LevelUpVBox/ChoiceRow/ChoiceButton1
@onready var choice_button_2 = $LevelUpLayer/LevelUpPanel/LevelUpVBox/ChoiceRow/ChoiceButton2
@onready var choice_button_3 = $LevelUpLayer/LevelUpPanel/LevelUpVBox/ChoiceRow/ChoiceButton3

func get_stage_type() -> String:
	return "heaven"

func start_fight() -> void:
	play_area_rect = get_viewport_rect()
	_update_world_scroll_limits()
	fight_active = true
	time_remaining = stage_duration
	kills = 0
	wave_level = 1
	current_spawn_interval = base_spawn_interval
	swarm_event_elapsed = 0.0
	world_offset = _clamp_world_offset(initial_world_offset_px)
	if player.has_node("PlayerCollision"):
		var player_shape_node := player.get_node("PlayerCollision") as CollisionShape2D
		if player_shape_node != null and player_shape_node.shape is CircleShape2D:
			player_collision_radius = (player_shape_node.shape as CircleShape2D).radius

	player.setup(play_area_rect, bullet_container)
	hud.setup(stage_duration, player.max_lives)
	hud.update_pattern(player.get_pattern_name())
	backdrop.setup(play_area_rect, world_size_px)
	backdrop.set_scroll_offset(world_offset)
	enemy_container.visible = true
	enemy_container.position = world_offset
	pickup_container.position = world_offset
	bullet_container.position = world_offset
	obstacle_container.position = world_offset
	pending_level_ups = 0
	current_powerup_choices.clear()
	_hide_level_up_ui()

	for child in enemy_container.get_children():
		child.queue_free()
	for child in pickup_container.get_children():
		child.queue_free()
	for child in bullet_container.get_children():
		child.queue_free()
	for child in obstacle_container.get_children():
		child.queue_free()
	_spawn_stage_obstacles()
	_ensure_player_spawn_clearance()

	spawn_timer.wait_time = current_spawn_interval
	if not spawn_timer.timeout.is_connected(_spawn_enemy):
		spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _ready() -> void:
	player.player_died.connect(_on_player_died)
	player.shot_spawned.connect(_on_player_shot_spawned)
	player.experience_changed.connect(_on_player_experience_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	player.area_entered.connect(_on_player_area_entered)
	choice_button_1.pressed.connect(_on_choice_button_1_pressed)
	choice_button_2.pressed.connect(_on_choice_button_2_pressed)
	choice_button_3.pressed.connect(_on_choice_button_3_pressed)
	level_up_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	level_up_panel.visible = false
	_setup_level_up_ui_styles()
	start_fight()

func _process(delta: float) -> void:
	if not fight_active:
		return

	_scroll_world(delta)
	_update_swarm_event(delta)

	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_end_fight("win")
		return

	var target_wave = 1 + int((stage_duration - time_remaining) / wave_step_seconds)
	if target_wave > wave_level:
		wave_level = target_wave
		current_spawn_interval = max(spawn_interval_floor, base_spawn_interval - 0.07 * float(wave_level - 1))
		spawn_timer.wait_time = current_spawn_interval

	hud.update_timer(time_remaining)
	hud.update_lives(player.lives)
	hud.update_kills(kills)
	hud.update_pattern(player.get_pattern_name())
	_collect_nearby_xp_orbs()

func _spawn_enemy() -> void:
	if not fight_active:
		return

	var kind := BHEnemyScript.EnemyKind.STANDARD
	if randf() < TANK_SPAWN_CHANCE:
		kind = BHEnemyScript.EnemyKind.TANK
	_spawn_enemy_of_kind(kind, _random_edge_position(play_area_rect))

func _spawn_enemy_of_kind(kind: int, spawn_position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	var enemy = BHEnemyScript.new()
	enemy.setup(kind, player, play_area_rect, direction, obstacle_container)
	enemy.global_position = spawn_position
	enemy.area_entered.connect(_on_enemy_area_entered.bind(enemy))
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy_container.add_child(enemy)

func _update_swarm_event(delta: float) -> void:
	swarm_event_elapsed += delta
	if swarm_event_elapsed < SWARM_EVENT_INTERVAL:
		return

	swarm_event_elapsed = 0.0
	_spawn_swarm_event()

func _spawn_swarm_event() -> void:
	if not fight_active:
		return

	var side: int = randi() % 4
	var spawn_positions := _build_swarm_spawn_positions(side, SWARM_EVENT_ENEMY_COUNT)
	for spawn_position in spawn_positions:
		var direction: Vector2 = (player.global_position - spawn_position).normalized()
		if direction == Vector2.ZERO:
			direction = _fallback_swarm_direction(side)
		_spawn_enemy_of_kind(BHEnemyScript.EnemyKind.SWARM, spawn_position, direction)

func _build_swarm_spawn_positions(side: int, count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if count <= 0:
		return positions

	if side == 0 or side == 1:
		var x: float = play_area_rect.position.x - SWARM_EDGE_MARGIN if side == 0 else play_area_rect.end.x + SWARM_EDGE_MARGIN
		var available_height: float = max(play_area_rect.size.y - SWARM_EDGE_MARGIN * 2.0, 1.0)
		var step: float = 0.0 if count == 1 else available_height / float(count - 1)
		for i in count:
			var y: float = play_area_rect.position.y + SWARM_EDGE_MARGIN + step * float(i)
			positions.append(Vector2(x, y))
	else:
		var y: float = play_area_rect.position.y - SWARM_EDGE_MARGIN if side == 2 else play_area_rect.end.y + SWARM_EDGE_MARGIN
		var available_width: float = max(play_area_rect.size.x - SWARM_EDGE_MARGIN * 2.0, 1.0)
		var step: float = 0.0 if count == 1 else available_width / float(count - 1)
		for i in count:
			var x: float = play_area_rect.position.x + SWARM_EDGE_MARGIN + step * float(i)
			positions.append(Vector2(x, y))

	return positions

func _fallback_swarm_direction(side: int) -> Vector2:
	match side:
		0:
			return Vector2.RIGHT
		1:
			return Vector2.LEFT
		2:
			return Vector2.DOWN
		_:
			return Vector2.UP

func _random_edge_position(rect: Rect2) -> Vector2:
	var side := randi() % 4
	match side:
		0:
			return Vector2(randf_range(rect.position.x, rect.end.x), rect.position.y - 10)
		1:
			return Vector2(randf_range(rect.position.x, rect.end.x), rect.end.y + 10)
		2:
			return Vector2(rect.position.x - 10, randf_range(rect.position.y, rect.end.y))
		_:
			return Vector2(rect.end.x + 10, randf_range(rect.position.y, rect.end.y))

func _on_player_shot_spawned(shot: Node2D) -> void:
	bullet_container.add_child(shot)
	shot.global_position = shot.position
	shot.anchor_ref = player

func _on_player_experience_changed(current_xp: int, current_level: int, xp_to_next: int) -> void:
	hud.update_level(current_level)
	hud.update_experience(current_xp, xp_to_next)
	hud.update_pattern(player.get_pattern_name())

func _on_player_leveled_up(new_level: int) -> void:
	pending_level_ups += 1
	if get_tree().paused:
		return
	_open_level_up_ui(new_level)

func _on_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("bh_xp_pellet"):
		if area.has_method("get_xp_amount"):
			player.add_experience(area.get_xp_amount())
		area.queue_free()

func _on_enemy_area_entered(area: Area2D, enemy: Area2D) -> void:
	if not fight_active:
		return
	if area == player and player.is_alive:
		enemy.take_damage(999)
		player.take_hit()
		return
	if area.is_in_group("bh_player_bullet") or area.is_in_group("bh_player_attack"):
		var damage := 1
		if area.has_method("get_damage"):
			damage = area.get_damage()
		enemy.take_damage(damage)
		if area.is_in_group("bh_player_bullet"):
			area.queue_free()

func _on_enemy_died(enemy: Area2D) -> void:
	kills += 1
	_spawn_xp_pellet(enemy.global_position, enemy.xp_value)

func _on_player_died() -> void:
	_end_fight("lose")

func _end_fight(result: String) -> void:
	if not fight_active:
		return
	fight_active = false
	spawn_timer.stop()
	player.fight_active = false

	for enemy in enemy_container.get_children():
		enemy.queue_free()
	for bullet in bullet_container.get_children():
		bullet.queue_free()

	hud.show_result(result)
	await get_tree().create_timer(2.0).timeout
	fight_ended.emit(result)

func _spawn_xp_pellet(spawn_position: Vector2, xp_amount: int) -> void:
	var orb = BHExperienceOrbScript.new()
	orb.xp_amount = max(xp_amount, 1)
	orb.add_to_group("bh_xp_pellet")
	orb.position = pickup_container.to_local(spawn_position)
	pickup_container.call_deferred("add_child", orb)

func _open_level_up_ui(current_level: int) -> void:
	if current_powerup_choices.is_empty():
		current_powerup_choices = BHPowerups.get_random_choices(3, player.get_owned_weapon_ids())

	level_up_title.text = "Wybór Ulepszenia"
	level_up_subtitle.text = "Poziom %02d  •  wybierz 1 z 3 kart" % current_level
	level_up_hint.text = "Rozgrywka zatrzymana do momentu wyboru"

	var buttons := [choice_button_1, choice_button_2, choice_button_3]
	for index in buttons.size():
		var button: Button = buttons[index]
		if index < current_powerup_choices.size():
			var powerup_id := current_powerup_choices[index]
			button.visible = true
			button.disabled = false
			button.text = _format_powerup_card_text(powerup_id)
			_apply_choice_button_style(button, powerup_id)
			button.set_meta("powerup_id", powerup_id)
		else:
			button.visible = false

	level_up_panel.visible = true
	if level_up_dimmer != null:
		level_up_dimmer.visible = true
	get_tree().paused = true

func _hide_level_up_ui() -> void:
	level_up_panel.visible = false
	if level_up_dimmer != null:
		level_up_dimmer.visible = false
	current_powerup_choices.clear()

func _apply_powerup_from_button(button: Button) -> void:
	if not button.has_meta("powerup_id"):
		return

	var powerup_id: int = int(button.get_meta("powerup_id"))
	player.apply_powerup(powerup_id)
	pending_level_ups = max(pending_level_ups - 1, 0)
	current_powerup_choices.clear()
	get_tree().paused = false
	_hide_level_up_ui()
	if pending_level_ups > 0:
		call_deferred("_resume_level_up_sequence")

func _setup_level_up_ui_styles() -> void:
	if level_up_dimmer == null:
		level_up_dimmer = ColorRect.new()
		level_up_dimmer.name = "LevelUpDimmer"
		level_up_dimmer.anchors_preset = Control.PRESET_FULL_RECT
		level_up_dimmer.anchor_right = 1.0
		level_up_dimmer.anchor_bottom = 1.0
		level_up_dimmer.grow_horizontal = Control.GROW_DIRECTION_BOTH
		level_up_dimmer.grow_vertical = Control.GROW_DIRECTION_BOTH
		level_up_dimmer.color = Color(0.03, 0.02, 0.06, 0.72)
		level_up_dimmer.visible = false
		level_up_layer.add_child(level_up_dimmer)
		level_up_layer.move_child(level_up_dimmer, 0)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.1, 0.14, 0.98)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.45, 0.75, 1.0, 0.95)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	level_up_panel.add_theme_stylebox_override("panel", panel_style)

	level_up_title.add_theme_font_size_override("font_size", 42)
	level_up_subtitle.add_theme_font_size_override("font_size", 20)
	level_up_hint.add_theme_font_size_override("font_size", 18)
	level_up_hint.modulate = Color(0.86, 0.91, 1.0, 0.92)

func _format_powerup_card_text(powerup_id: int) -> String:
	var name := BHPowerups.get_powerup_name(powerup_id)
	var desc := BHPowerups.get_powerup_description(powerup_id)
	var data := BHPowerups.get_powerup_data(powerup_id)
	var kind := String(data.get("kind", ""))
	var kind_label := "TECH"
	match kind:
		"weapon":
			kind_label = "BROŃ"
		"speed":
			kind_label = "MOBILNOŚĆ"
		"shield":
			kind_label = "OBRONA"
	return "%s\n%s\n\n%s" % [name.to_upper(), kind_label, desc]

func _apply_choice_button_style(button: Button, powerup_id: int) -> void:
	button.custom_minimum_size = Vector2(188.0, 190.0)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 19)

	var data := BHPowerups.get_powerup_data(powerup_id)
	var kind := String(data.get("kind", ""))
	var border_color := Color(0.55, 0.7, 1.0, 1.0)
	var fill_color := Color(0.13, 0.17, 0.24, 1.0)
	match kind:
		"weapon":
			border_color = Color(0.98, 0.68, 0.28, 1.0)
			fill_color = Color(0.2, 0.14, 0.1, 1.0)
		"speed":
			border_color = Color(0.33, 0.9, 0.62, 1.0)
			fill_color = Color(0.07, 0.2, 0.16, 1.0)
		"shield":
			border_color = Color(0.42, 0.78, 1.0, 1.0)
			fill_color = Color(0.08, 0.13, 0.2, 1.0)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = fill_color
	normal_style.border_color = border_color
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_left = 10
	normal_style.corner_radius_bottom_right = 10

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = fill_color.lightened(0.12)

	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = fill_color.darkened(0.14)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", Color(0.97, 0.98, 1.0, 1.0))

func _resume_level_up_sequence() -> void:
	if pending_level_ups <= 0:
		return
	get_tree().paused = false
	current_powerup_choices = BHPowerups.get_random_choices(3, player.get_owned_weapon_ids())
	_open_level_up_ui(player.level)

func _on_choice_button_1_pressed() -> void:
	_apply_powerup_from_button(choice_button_1)

func _on_choice_button_2_pressed() -> void:
	_apply_powerup_from_button(choice_button_2)

func _on_choice_button_3_pressed() -> void:
	_apply_powerup_from_button(choice_button_3)

func _scroll_world(delta: float) -> void:
	var move_input: Vector2 = player.get_move_input()
	if move_input == Vector2.ZERO:
		return

	var desired_delta := -move_input * world_scroll_speed * delta
	var clamped_target := _clamp_world_offset(world_offset + desired_delta)
	var clamped_delta := clamped_target - world_offset
	var applied_delta := Vector2.ZERO
	var try_x := Vector2(clamped_delta.x, 0.0)
	if not _would_player_overlap_obstacle(try_x):
		applied_delta.x = try_x.x
	var try_y := Vector2(applied_delta.x, clamped_delta.y)
	if not _would_player_overlap_obstacle(try_y):
		applied_delta.y = clamped_delta.y
	if applied_delta == Vector2.ZERO:
		return

	world_offset += applied_delta
	enemy_container.position += applied_delta
	pickup_container.position += applied_delta
	bullet_container.position += applied_delta
	obstacle_container.position += applied_delta
	backdrop.set_scroll_offset(world_offset)

func _clamp_world_offset(offset: Vector2) -> Vector2:
	return Vector2(
		clampf(offset.x, -world_scroll_limits.x, world_scroll_limits.x),
		clampf(offset.y, -world_scroll_limits.y, world_scroll_limits.y)
	)

func _would_player_overlap_obstacle(offset_delta: Vector2) -> bool:
	if obstacle_container == null:
		return false

	var player_position: Vector2 = player.global_position
	for obstacle in obstacle_container.get_children():
		if obstacle.has_method("blocks_player_point"):
			if bool(obstacle.call("blocks_player_point", player_position, player_collision_radius, offset_delta)):
				return true
			continue
		if not obstacle.has_method("get_collision_radius"):
			continue
		var obstacle_radius: float = float(obstacle.call("get_collision_radius"))
		var obstacle_position: Vector2 = (obstacle as Node2D).global_position + offset_delta
		if player_position.distance_to(obstacle_position) < player_collision_radius + obstacle_radius:
			return true
	return false

func _ensure_player_spawn_clearance() -> void:
	if obstacle_container == null:
		return
	if not _would_player_overlap_obstacle(Vector2.ZERO):
		return

	# Prefer moving the world up on screen so the player starts below the fountain.
	var step_candidates: Array[Vector2] = [
		Vector2(0.0, -12.0),
		Vector2(-12.0, 0.0),
		Vector2(12.0, 0.0),
		Vector2(0.0, 12.0),
	]

	for _attempt in 80:
		var current_overlap_count: int = _count_player_obstacle_overlaps(Vector2.ZERO)
		if current_overlap_count <= 0:
			return

		var best_delta: Vector2 = Vector2.ZERO
		var best_overlap_count: int = current_overlap_count
		for step in step_candidates:
			var candidate_offset: Vector2 = _clamp_world_offset(world_offset + step)
			var candidate_delta: Vector2 = candidate_offset - world_offset
			if candidate_delta == Vector2.ZERO:
				continue
			var candidate_overlap_count: int = _count_player_obstacle_overlaps(candidate_delta)
			if candidate_overlap_count < best_overlap_count:
				best_overlap_count = candidate_overlap_count
				best_delta = candidate_delta

		# If no improving step exists, force preferred upward nudge to avoid permanent stuck spawn.
		if best_delta == Vector2.ZERO:
			var forced_offset: Vector2 = _clamp_world_offset(world_offset + step_candidates[0])
			best_delta = forced_offset - world_offset
		if best_delta == Vector2.ZERO:
			break

		_apply_world_delta(best_delta)

func _count_player_obstacle_overlaps(offset_delta: Vector2) -> int:
	if obstacle_container == null:
		return 0

	var overlap_count: int = 0
	var player_position: Vector2 = player.global_position
	for obstacle in obstacle_container.get_children():
		if obstacle.has_method("blocks_player_point"):
			if bool(obstacle.call("blocks_player_point", player_position, player_collision_radius, offset_delta)):
				overlap_count += 1
			continue
		if not obstacle.has_method("get_collision_radius"):
			continue
		var obstacle_radius: float = float(obstacle.call("get_collision_radius"))
		var obstacle_position: Vector2 = (obstacle as Node2D).global_position + offset_delta
		if player_position.distance_to(obstacle_position) < player_collision_radius + obstacle_radius:
			overlap_count += 1
	return overlap_count

func _apply_world_delta(applied_delta: Vector2) -> void:
	if applied_delta == Vector2.ZERO:
		return
	world_offset += applied_delta
	enemy_container.position += applied_delta
	pickup_container.position += applied_delta
	bullet_container.position += applied_delta
	obstacle_container.position += applied_delta
	backdrop.set_scroll_offset(world_offset)

func _spawn_stage_obstacles() -> void:
	var world_center := play_area_rect.get_center()
	var world_top_left := world_center - world_size_px * 0.5
	var fountain_texture: Texture2D = _load_texture(fountain_texture_path)
	var pigeon_texture: Texture2D = _load_texture(pigeon_texture_path)

	if fountain_texture != null:
		var fountain = BHObstacleScript.new()
		fountain.setup(
			fountain_texture,
			fountain_collision_radius,
			fountain_visual_scale,
			maxi(fountain_hframes, 1),
			maxi(fountain_vframes, 1),
			maxi(fountain_frame_count, 1),
			maxf(fountain_fps, 0.0),
			true,
			0.08
		)
		fountain.position = world_center
		obstacle_container.add_child(fountain)

	if pigeon_texture != null:
		var pigeon_top_left = BHObstacleScript.new()
		pigeon_top_left.setup(pigeon_texture, 24.0, 2.0, 4, 1, 4, 8.0)
		pigeon_top_left.position = world_top_left + Vector2(world_size_px.x * 0.25, world_size_px.y * 0.25)
		obstacle_container.add_child(pigeon_top_left)

		var pigeon_bottom_right = BHObstacleScript.new()
		pigeon_bottom_right.setup(pigeon_texture, 24.0, 2.0, 4, 1, 4, 8.0)
		pigeon_bottom_right.set_visual_flip_h(true)
		pigeon_bottom_right.position = world_top_left + Vector2(world_size_px.x * 0.75, world_size_px.y * 0.75)
		obstacle_container.add_child(pigeon_bottom_right)

		var pigeon_left_mid = BHObstacleScript.new()
		pigeon_left_mid.setup(pigeon_texture, 24.0, 2.0, 4, 1, 4, 8.0)
		pigeon_left_mid.position = world_top_left + Vector2(world_size_px.x * 0.18, world_size_px.y * 0.56)
		obstacle_container.add_child(pigeon_left_mid)

		var pigeon_right_mid = BHObstacleScript.new()
		pigeon_right_mid.setup(pigeon_texture, 24.0, 2.0, 4, 1, 4, 8.0)
		pigeon_right_mid.set_visual_flip_h(true)
		pigeon_right_mid.position = world_top_left + Vector2(world_size_px.x * 0.82, world_size_px.y * 0.44)
		obstacle_container.add_child(pigeon_right_mid)

func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is Texture2D:
			return resource as Texture2D

	var absolute_path: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(absolute_path):
		var image := Image.load_from_file(absolute_path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	push_warning("Could not load texture for obstacle: %s" % path)
	return null

func _update_world_scroll_limits() -> void:
	var half_world := world_size_px * 0.5
	world_scroll_limits = Vector2(
		max(half_world.x, 0.0),
		max(half_world.y, 0.0)
	)

func _collect_nearby_xp_orbs() -> void:
	if pickup_container == null:
		return
	var player_position: Vector2 = player.global_position
	for orb in pickup_container.get_children():
		if not (orb is Area2D):
			continue
		if not orb.is_in_group("bh_xp_pellet"):
			continue
		var orb_position: Vector2 = (orb as Node2D).global_position
		if player_position.distance_to(orb_position) > xp_pickup_radius:
			continue
		if orb.has_method("get_xp_amount"):
			player.add_experience(orb.get_xp_amount())
		orb.queue_free()
