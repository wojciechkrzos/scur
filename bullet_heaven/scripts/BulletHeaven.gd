extends Node2D

signal fight_ended(result: String)
signal swarm_warning_started
signal swarm_spawned

const BHEnemyScript = preload("res://bullet_heaven/scripts/BHEnemy.gd")
const BHExperienceOrbScript = preload("res://bullet_heaven/scripts/BHExperienceOrb.gd")
const BHTokenPickupScript = preload("res://bullet_heaven/scripts/BHTokenPickup.gd")
const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")
const BHObstacleScript = preload("res://bullet_heaven/scripts/BHObstacle.gd")
const BHSwarmWarningScript = preload("res://bullet_heaven/scripts/BHSwarmWarning.gd")
const BHAudioScript = preload("res://bullet_heaven/scripts/BHAudio.gd")

@export var stage_duration: float = 45.0
@export var base_spawn_interval: float = 0.72
@export var spawn_interval_floor: float = 0.48
@export var wave_step_seconds: float = 12.0
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

const SWARM_EDGE_MARGIN := 18.0
const TOKEN_DROP_CHANCE := 0.005

const STAGE_CONFIGS := {
	"stage1": {
		"duration": 45.0, "spawn_interval": 0.72, "spawn_floor": 0.48,
		"wave_seconds": 12.0, "spawn_decay": 0.035, "tank_chance": 0.20,
		"enemy_speed": 1.0, "swarm_enabled": false,
	},
	"stage2": {
		"duration": 60.0, "spawn_interval": 0.48, "spawn_floor": 0.24,
		"wave_seconds": 10.0, "spawn_decay": 0.04, "tank_chance": 0.25,
		"enemy_speed": 1.15, "swarm_enabled": true, "swarm_interval": 12.0,
		"swarm_count": 9, "swarm_warning": 1.25,
	},
	"stage3": {
		"duration": 180.0, "spawn_interval": 0.40, "spawn_floor": 0.14,
		"wave_seconds": 8.0, "spawn_decay": 0.018, "tank_chance": 0.20,
		"hunter_chance": 0.25, "elite_chance": 0.08, "enemy_speed": 1.25,
		"swarm_enabled": true, "swarm_interval": 8.0, "swarm_count": 14,
		"swarm_warning": 0.9,
	},
}

var fight_active: bool = false
var time_remaining: float = 0.0
var kills: int = 0
var run_xp_gained: int = 0
var wave_level: int = 1
var current_spawn_interval: float = 0.6
var play_area_rect: Rect2 = Rect2(0, 0, 800, 600)
var world_offset: Vector2 = Vector2.ZERO
var world_scroll_limits: Vector2 = Vector2.ZERO
var player_collision_radius: float = 7.0
var swarm_event_elapsed: float = 0.0
var swarm_warning_remaining: float = 0.0
var pending_swarm_side: int = -1
var pending_level_ups: int = 0
var current_powerup_choices: Array[int] = []
var stage_profile: String = "stage1"
var initial_run_state: Dictionary = {}
var level_up_dimmer: ColorRect
var swarm_warning_indicator
var audio_controller
var spawn_interval_decay: float = 0.035
var tank_spawn_chance: float = 0.2
var hunter_spawn_chance: float = 0.0
var elite_spawn_chance: float = 0.0
var enemy_speed_multiplier: float = 1.0
var swarm_enabled: bool = false
var swarm_event_interval: float = 12.0
var swarm_enemy_count: int = 9
var swarm_warning_duration: float = 1.25

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
@onready var level_up_tokens_label = $LevelUpLayer/LevelUpPanel/LevelUpVBox/TokenRow/TokenLabel
@onready var reroll_button = $LevelUpLayer/LevelUpPanel/LevelUpVBox/TokenRow/RerollButton
@onready var skip_button = $LevelUpLayer/LevelUpPanel/LevelUpVBox/TokenRow/SkipButton

func get_stage_type() -> String:
	return "heaven"

func configure_stage(profile: String, run_state: Dictionary = {}) -> void:
	stage_profile = profile
	initial_run_state = run_state.duplicate(true)
	_apply_stage_profile()

func _apply_stage_profile() -> void:
	var config: Dictionary = STAGE_CONFIGS.get(stage_profile, STAGE_CONFIGS["stage1"])
	stage_duration = float(config.get("duration", 45.0))
	base_spawn_interval = float(config.get("spawn_interval", 0.72))
	spawn_interval_floor = float(config.get("spawn_floor", 0.48))
	wave_step_seconds = float(config.get("wave_seconds", 12.0))
	spawn_interval_decay = float(config.get("spawn_decay", 0.035))
	tank_spawn_chance = float(config.get("tank_chance", 0.2))
	hunter_spawn_chance = float(config.get("hunter_chance", 0.0))
	elite_spawn_chance = float(config.get("elite_chance", 0.0))
	enemy_speed_multiplier = float(config.get("enemy_speed", 1.0))
	swarm_enabled = bool(config.get("swarm_enabled", false))
	swarm_event_interval = float(config.get("swarm_interval", 12.0))
	swarm_enemy_count = int(config.get("swarm_count", 9))
	swarm_warning_duration = float(config.get("swarm_warning", 1.25))

func start_fight() -> void:
	play_area_rect = get_viewport_rect()
	_update_world_scroll_limits()
	fight_active = true
	time_remaining = stage_duration
	kills = 0
	run_xp_gained = 0
	wave_level = 1
	current_spawn_interval = base_spawn_interval
	swarm_event_elapsed = 0.0
	swarm_warning_remaining = 0.0
	pending_swarm_side = -1
	if swarm_warning_indicator != null:
		swarm_warning_indicator.hide_warning()
	world_offset = _clamp_world_offset(initial_world_offset_px)
	if player.has_node("PlayerCollision"):
		var player_shape_node := player.get_node("PlayerCollision") as CollisionShape2D
		if player_shape_node != null and player_shape_node.shape is CircleShape2D:
			player_collision_radius = (player_shape_node.shape as CircleShape2D).radius

	player.setup(play_area_rect, bullet_container)
	_apply_initial_run_state()
	hud.setup(stage_duration, player.max_lives, stage_profile)
	hud.update_pattern(player.get_pattern_name())
	hud.update_weapon_inventory(player.get_weapon_inventory())
	backdrop.setup(play_area_rect, world_size_px)
	if backdrop.has_method("set_stage"):
		backdrop.set_stage(stage_profile)
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
	player.player_hit.connect(_on_player_hit)
	player.shot_spawned.connect(_on_player_shot_spawned)
	player.experience_changed.connect(_on_player_experience_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	player.weapon_inventory_changed.connect(_on_player_weapon_inventory_changed)
	player.area_entered.connect(_on_player_area_entered)
	choice_button_1.pressed.connect(_on_choice_button_1_pressed)
	choice_button_2.pressed.connect(_on_choice_button_2_pressed)
	choice_button_3.pressed.connect(_on_choice_button_3_pressed)
	reroll_button.pressed.connect(_on_reroll_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)
	level_up_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	level_up_panel.visible = false
	_setup_level_up_ui_styles()
	_setup_swarm_warning_indicator()
	_setup_audio()
	start_fight()

func _process(delta: float) -> void:
	if not fight_active:
		return

	_scroll_world(delta)
	if swarm_enabled:
		_update_swarm_event(delta)

	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_end_fight("win")
		return

	var target_wave = 1 + int((stage_duration - time_remaining) / wave_step_seconds)
	if target_wave > wave_level:
		wave_level = target_wave
		current_spawn_interval = max(spawn_interval_floor, base_spawn_interval - spawn_interval_decay * float(wave_level - 1))
		spawn_timer.wait_time = current_spawn_interval

	hud.update_timer(time_remaining)
	hud.update_lives(player.lives)
	hud.update_kills(kills)
	hud.update_pattern(player.get_pattern_name())
	hud.update_wave(wave_level)
	_collect_nearby_xp_orbs()

func _spawn_enemy() -> void:
	if not fight_active:
		return

	var batch_size := _get_regular_spawn_batch_size()
	for _index in batch_size:
		_spawn_enemy_of_kind(_choose_regular_enemy_kind(), _random_edge_position(play_area_rect))

func _get_regular_spawn_batch_size() -> int:
	if stage_profile != "stage3":
		return 1
	if wave_level >= 12:
		return 3
	if wave_level >= 5:
		return 2
	return 1

func _choose_regular_enemy_kind() -> int:
	var roll := randf()
	var scaled_elite_chance := elite_spawn_chance
	if stage_profile == "stage3":
		scaled_elite_chance += minf(float(wave_level - 1) * 0.004, 0.08)
	if roll < scaled_elite_chance:
		return BHEnemyScript.EnemyKind.ELITE
	if roll < scaled_elite_chance + hunter_spawn_chance:
		return BHEnemyScript.EnemyKind.HUNTER
	if roll < scaled_elite_chance + hunter_spawn_chance + tank_spawn_chance:
		return BHEnemyScript.EnemyKind.TANK
	return BHEnemyScript.EnemyKind.STANDARD

func _spawn_enemy_of_kind(kind: int, spawn_position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	var enemy = BHEnemyScript.new()
	var speed_scale := enemy_speed_multiplier
	var health_scale := 1.0
	if stage_profile == "stage3":
		speed_scale *= 1.0 + minf(float(wave_level - 1) * 0.008, 0.18)
		health_scale += minf(float(wave_level - 1) * 0.035, 0.7)
	enemy.setup(kind, player, play_area_rect, direction, obstacle_container, speed_scale, health_scale)
	enemy.global_position = spawn_position
	enemy.area_entered.connect(_on_enemy_area_entered.bind(enemy))
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy_container.add_child(enemy)

func _update_swarm_event(delta: float) -> void:
	if pending_swarm_side >= 0:
		swarm_warning_remaining -= delta
		if swarm_warning_remaining <= 0.0:
			var side_to_spawn: int = pending_swarm_side
			pending_swarm_side = -1
			if swarm_warning_indicator != null:
				swarm_warning_indicator.hide_warning()
			_spawn_swarm_event(side_to_spawn)
		return

	swarm_event_elapsed += delta
	var current_swarm_interval := swarm_event_interval
	if stage_profile == "stage3":
		current_swarm_interval = maxf(5.5, swarm_event_interval - float(wave_level - 1) * 0.12)
	if swarm_event_elapsed < current_swarm_interval:
		return

	swarm_event_elapsed = 0.0
	pending_swarm_side = randi() % 4
	swarm_warning_remaining = swarm_warning_duration
	if swarm_warning_indicator != null:
		swarm_warning_indicator.show_warning(player, _get_swarm_source_direction(pending_swarm_side), swarm_warning_duration)
	swarm_warning_started.emit()

func _spawn_swarm_event(side: int) -> void:
	if not fight_active:
		return

	var count := swarm_enemy_count
	if stage_profile == "stage3":
		count = mini(swarm_enemy_count + int(wave_level / 4), 22)
	var spawn_positions := _build_swarm_spawn_positions(side, count)
	for spawn_position in spawn_positions:
		var direction: Vector2 = (player.global_position - spawn_position).normalized()
		if direction == Vector2.ZERO:
				direction = _fallback_swarm_direction(side)
		_spawn_enemy_of_kind(BHEnemyScript.EnemyKind.SWARM, spawn_position, direction)
	if stage_profile == "stage3":
		for _index in 2:
			_spawn_enemy_of_kind(BHEnemyScript.EnemyKind.HUNTER, _random_edge_position(play_area_rect))
	swarm_spawned.emit()

func _get_swarm_source_direction(side: int) -> Vector2:
	match side:
		0:
			return Vector2.LEFT
		1:
			return Vector2.RIGHT
		2:
			return Vector2.UP
		_:
			return Vector2.DOWN

func _setup_swarm_warning_indicator() -> void:
	if swarm_warning_indicator != null:
		return
	swarm_warning_indicator = BHSwarmWarningScript.new()
	swarm_warning_indicator.name = "SwarmWarningIndicator"
	add_child(swarm_warning_indicator)

func _setup_audio() -> void:
	if audio_controller != null:
		return
	audio_controller = BHAudioScript.new()
	audio_controller.name = "BulletHeavenAudio"
	add_child(audio_controller)
	player.weapon_fired.connect(audio_controller.play_weapon)
	swarm_warning_started.connect(_on_swarm_warning_audio)
	swarm_spawned.connect(_on_swarm_spawn_audio)
	audio_controller.play_music("theme")

func _on_swarm_warning_audio() -> void:
	if audio_controller != null:
		audio_controller.play_sfx("swarm_warning")

func _on_swarm_spawn_audio() -> void:
	if audio_controller != null:
		audio_controller.play_sfx("swarm_spawn")

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
	if shot.has_signal("explosion_created"):
		shot.explosion_created.connect(_on_molotov_explosion_created)

func _on_molotov_explosion_created() -> void:
	if audio_controller != null:
		audio_controller.play_sfx("weapon_molotov_explosion")

func _on_player_experience_changed(current_xp: int, current_level: int, xp_to_next: int) -> void:
	hud.update_level(current_level)
	hud.update_experience(current_xp, xp_to_next)
	hud.update_pattern(player.get_pattern_name())

func _on_player_weapon_inventory_changed(inventory: Dictionary) -> void:
	hud.update_weapon_inventory(inventory)

func _on_player_leveled_up(new_level: int) -> void:
	pending_level_ups += 1
	if get_tree().paused:
		return
	_open_level_up_ui(new_level)

func _on_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("bh_xp_pellet"):
		if area.has_method("get_xp_amount"):
			var xp_amount: int = int(area.get_xp_amount())
			run_xp_gained += xp_amount
			player.add_experience(xp_amount)
		area.queue_free()
		return

	if area.is_in_group("bh_token_pickup"):
		if area.has_method("get_token_type"):
			var token_type: int = int(area.get_token_type())
			if token_type == BHTokenPickupScript.TokenType.SKIP:
				player.add_skip_tokens(1)
			else:
				player.add_reroll_tokens(1)
		_update_token_ui()
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
	_try_spawn_levelup_token(enemy.global_position)

func _on_player_died() -> void:
	_end_fight("lose")

func _on_player_hit(_remaining_lives: int) -> void:
	hud.play_damage_feedback()

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
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_run_score"):
		var minutes_played := maxf(stage_duration - time_remaining, 0.0) / 60.0
		game_state.record_run_score(kills, minutes_played, run_xp_gained)
	if audio_controller != null:
		audio_controller.play_music("victory" if result == "win" else "defeat")
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
		current_powerup_choices = BHPowerups.get_random_choices(3, player.get_weapon_inventory())

	level_up_title.text = "WYBIERZ NARZĘDZIE ZAGŁADY"
	level_up_subtitle.text = "Poziom %02d  •  wybierz 1 z 3 kart" % current_level
	level_up_hint.text = "Rozgrywka zatrzymana do momentu wyboru"

	var buttons := [choice_button_1, choice_button_2, choice_button_3]
	for index in buttons.size():
		var button: Button = buttons[index]
		if index < current_powerup_choices.size():
			var powerup_id := current_powerup_choices[index]
			button.visible = true
			button.disabled = false
			_apply_choice_button_style(button, powerup_id)
			button.set_meta("powerup_id", powerup_id)
		else:
			button.visible = false
	_update_token_ui()

	level_up_panel.visible = true
	get_tree().paused = true

func _hide_level_up_ui() -> void:
	level_up_panel.visible = false
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
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.018, 0.008, 0.012, 0.985)
	panel_style.set_border_width_all(4)
	panel_style.border_color = Color(0.58, 0.06, 0.09, 1.0)
	panel_style.set_corner_radius_all(0)
	panel_style.content_margin_left = 34.0
	panel_style.content_margin_top = 26.0
	panel_style.content_margin_right = 34.0
	panel_style.content_margin_bottom = 24.0
	panel_style.shadow_color = Color(0.62, 0.0, 0.04, 0.42)
	panel_style.shadow_size = 22
	level_up_panel.add_theme_stylebox_override("panel", panel_style)

	level_up_title.text = "WYBIERZ NARZĘDZIE ZAGŁADY"
	level_up_title.add_theme_font_size_override("font_size", 40)
	level_up_title.add_theme_color_override("font_color", Color(0.96, 0.72, 0.48, 1.0))
	level_up_title.add_theme_color_override("font_outline_color", Color(0.18, 0.0, 0.01, 1.0))
	level_up_title.add_theme_constant_override("outline_size", 8)
	level_up_subtitle.add_theme_font_size_override("font_size", 20)
	level_up_subtitle.add_theme_color_override("font_color", Color(0.82, 0.54, 0.52, 1.0))
	level_up_hint.add_theme_font_size_override("font_size", 18)
	level_up_hint.modulate = Color(0.62, 0.48, 0.5, 0.92)
	level_up_tokens_label.add_theme_font_size_override("font_size", 19)
	level_up_tokens_label.modulate = Color(0.9, 0.75, 0.66, 1.0)

	var utility_style := StyleBoxFlat.new()
	utility_style.bg_color = Color(0.08, 0.025, 0.035, 1.0)
	utility_style.border_color = Color(0.48, 0.1, 0.13, 1.0)
	utility_style.set_border_width_all(2)
	utility_style.set_corner_radius_all(0)
	reroll_button.add_theme_stylebox_override("normal", utility_style)
	skip_button.add_theme_stylebox_override("normal", utility_style)
	var utility_hover := utility_style.duplicate() as StyleBoxFlat
	utility_hover.bg_color = Color(0.3, 0.055, 0.075, 1.0)
	utility_hover.border_color = Color(0.95, 0.34, 0.28, 1.0)
	reroll_button.add_theme_stylebox_override("hover", utility_hover)
	skip_button.add_theme_stylebox_override("hover", utility_hover)
	reroll_button.add_theme_stylebox_override("focus", utility_hover)
	skip_button.add_theme_stylebox_override("focus", utility_hover)
	reroll_button.add_theme_color_override("font_color", Color(1.0, 0.72, 0.38, 1.0))
	skip_button.add_theme_color_override("font_color", Color(0.92, 0.48, 0.44, 1.0))

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
	if kind == "weapon":
		var weapon_id: int = int(data.get("weapon_id", -1))
		var current_level: int = player.get_weapon_level(weapon_id)
		var level_text := "NOWA BROŃ" if current_level == 0 else "POZIOM %d → %d" % [current_level, current_level + 1]
		var upgrade_text := BHPowerups.get_upgrade_summary(weapon_id, current_level)
		return "%s\n%s  •  %s\n\n%s\n\n%s" % [name.to_upper(), kind_label, level_text, desc, upgrade_text]
	return "%s\n%s\n\n%s" % [name.to_upper(), kind_label, desc]

func _apply_choice_button_style(button: Button, powerup_id: int) -> void:
	button.custom_minimum_size = Vector2(270.0, 310.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_stretch_ratio = 1.0
	button.text = ""
	button.icon = null
	button.autowrap_mode = TextServer.AUTOWRAP_OFF
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.add_theme_font_size_override("font_size", 18)
	button.clip_text = false
	button.focus_mode = Control.FOCUS_ALL
	_populate_choice_button_content(button, powerup_id)

	var data := BHPowerups.get_powerup_data(powerup_id)
	var kind := String(data.get("kind", ""))
	var border_color := Color(0.58, 0.12, 0.14, 1.0)
	var fill_color := Color(0.055, 0.018, 0.025, 1.0)
	match kind:
		"weapon":
			border_color = Color(0.9, 0.23, 0.19, 1.0)
			fill_color = Color(0.12, 0.025, 0.03, 1.0)
		"speed":
			border_color = Color(0.72, 0.18, 0.24, 1.0)
			fill_color = Color(0.085, 0.02, 0.04, 1.0)
		"shield":
			border_color = Color(0.95, 0.48, 0.28, 1.0)
			fill_color = Color(0.11, 0.035, 0.025, 1.0)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = fill_color
	normal_style.border_color = border_color
	normal_style.set_border_width_all(3)
	normal_style.set_corner_radius_all(0)
	normal_style.shadow_color = Color(0.7, 0.0, 0.04, 0.25)
	normal_style.shadow_size = 8

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.25, 0.035, 0.045, 1.0)
	hover_style.border_color = Color(1.0, 0.42, 0.25, 1.0)
	hover_style.set_border_width_all(4)

	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = fill_color.darkened(0.14)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("focus", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", Color(0.97, 0.98, 1.0, 1.0))

func _populate_choice_button_content(button: Button, powerup_id: int) -> void:
	var content := button.get_node_or_null("CardContent") as VBoxContainer
	if content == null:
		content = VBoxContainer.new()
		content.name = "CardContent"
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.offset_left = 18.0
		content.offset_top = 18.0
		content.offset_right = -18.0
		content.offset_bottom = -18.0
		content.add_theme_constant_override("separation", 10)
		button.add_child(content)

	var icon := content.get_node_or_null("Icon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "Icon"
		icon.custom_minimum_size = Vector2(88.0, 88.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)

	var title := content.get_node_or_null("Title") as Label
	if title == null:
		title = Label.new()
		title.name = "Title"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.add_theme_font_size_override("font_size", 20)
		title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.58, 1.0))
		title.add_theme_color_override("font_outline_color", Color(0.18, 0.0, 0.01, 1.0))
		title.add_theme_constant_override("outline_size", 5)
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(title)

	var details := content.get_node_or_null("Details") as Label
	if details == null:
		details = Label.new()
		details.name = "Details"
		details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		details.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		details.add_theme_font_size_override("font_size", 15)
		details.modulate = Color(0.86, 0.72, 0.7, 0.96)
		details.size_flags_vertical = Control.SIZE_EXPAND_FILL
		details.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(details)

	icon.texture = BHPowerups.get_powerup_icon(powerup_id)
	title.text = BHPowerups.get_powerup_name(powerup_id).to_upper()
	details.text = _format_powerup_card_details(powerup_id)

func _format_powerup_card_details(powerup_id: int) -> String:
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

	if kind == "weapon":
		var weapon_id: int = int(data.get("weapon_id", -1))
		var current_level: int = player.get_weapon_level(weapon_id)
		var level_text := "NOWA BROŃ" if current_level == 0 else "POZIOM %d → %d" % [current_level, current_level + 1]
		var upgrade_text := BHPowerups.get_upgrade_summary(weapon_id, current_level)
		return "%s  •  %s\n\n%s\n\n%s" % [kind_label, level_text, desc, upgrade_text]

	return "%s\n\n%s" % [kind_label, desc]

func _update_token_ui() -> void:
	if level_up_tokens_label == null:
		return

	var rerolls: int = player.get_reroll_tokens()
	var skips: int = player.get_skip_tokens()
	level_up_tokens_label.text = "Tokeny: Reroll %d  •  Skip %d" % [rerolls, skips]
	if reroll_button != null:
		reroll_button.disabled = rerolls <= 0
	if skip_button != null:
		skip_button.disabled = skips <= 0

func _on_reroll_button_pressed() -> void:
	if not level_up_panel.visible:
		return
	if not player.consume_reroll_token():
		_update_token_ui()
		return

	current_powerup_choices = BHPowerups.get_random_choices(3, player.get_weapon_inventory())
	_open_level_up_ui(player.level)

func _on_skip_button_pressed() -> void:
	if not level_up_panel.visible:
		return
	if not player.consume_skip_token():
		_update_token_ui()
		return

	pending_level_ups = max(pending_level_ups - 1, 0)
	current_powerup_choices.clear()
	get_tree().paused = false
	_hide_level_up_ui()
	if pending_level_ups > 0:
		call_deferred("_resume_level_up_sequence")

func _try_spawn_levelup_token(spawn_position: Vector2) -> void:
	if randf() > TOKEN_DROP_CHANCE:
		return

	var token := BHTokenPickupScript.new()
	token.token_type = BHTokenPickupScript.TokenType.REROLL
	if randf() < 0.5:
		token.token_type = BHTokenPickupScript.TokenType.SKIP
	token.position = pickup_container.to_local(spawn_position)
	pickup_container.call_deferred("add_child", token)

func _resume_level_up_sequence() -> void:
	if pending_level_ups <= 0:
		return
	get_tree().paused = false
	current_powerup_choices = BHPowerups.get_random_choices(3, player.get_weapon_inventory())
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
	if stage_profile == "stage2":
		_spawn_stage2_placeholder_obstacles()
		return

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

func _spawn_stage2_placeholder_obstacles() -> void:
	var pigeon_texture: Texture2D = _load_texture(pigeon_texture_path)
	if pigeon_texture == null:
		return
	var world_center := play_area_rect.get_center()
	var offsets: Array[Vector2] = [
		Vector2(0.0, -180.0),
		Vector2(-260.0, 40.0),
		Vector2(260.0, 40.0),
		Vector2(-120.0, 220.0),
		Vector2(120.0, 220.0),
	]
	for index in offsets.size():
		var pigeon = BHObstacleScript.new()
		pigeon.setup(pigeon_texture, 24.0, 2.2, 4, 1, 4, 8.0)
		pigeon.set_visual_flip_h(index % 2 == 1)
		pigeon.position = world_center + offsets[index]
		obstacle_container.add_child(pigeon)

func _apply_initial_run_state() -> void:
	if initial_run_state.is_empty():
		return

	player.max_lives = maxi(int(initial_run_state.get("max_lives", player.max_lives)), 1)
	player.lives = clampi(int(initial_run_state.get("lives", player.max_lives)), 1, player.max_lives)
	player.level = maxi(int(initial_run_state.get("level", player.level)), 1)
	player.experience_points = maxi(int(initial_run_state.get("experience_points", player.experience_points)), 0)
	player.xp_to_next_level = maxi(int(initial_run_state.get("xp_to_next_level", player.xp_to_next_level)), 1)
	player.speed = float(initial_run_state.get("speed", player.speed))
	player.spiral_phase = float(initial_run_state.get("spiral_phase", player.spiral_phase))
	player.speedup_stacks = maxi(int(initial_run_state.get("speedup_stacks", player.speedup_stacks)), 0)
	player.reroll_tokens = maxi(int(initial_run_state.get("reroll_tokens", player.reroll_tokens)), 0)
	player.skip_tokens = maxi(int(initial_run_state.get("skip_tokens", player.skip_tokens)), 0)

	if initial_run_state.has("weapon_levels"):
		player.restore_weapon_inventory(initial_run_state.get("weapon_levels", {}))
	elif initial_run_state.has("active_weapons"):
		var legacy_inventory: Dictionary = {}
		for weapon_id in initial_run_state.get("active_weapons", []):
			legacy_inventory[int(weapon_id)] = 1
		player.restore_weapon_inventory(legacy_inventory)

	player._update_experience_ui()

func get_run_state() -> Dictionary:
	return {
		"lives": player.lives,
		"max_lives": player.max_lives,
		"experience_points": player.experience_points,
		"level": player.level,
		"xp_to_next_level": player.xp_to_next_level,
		"speed": player.speed,
		"weapon_levels": player.get_weapon_inventory(),
		"spiral_phase": player.spiral_phase,
		"speedup_stacks": player.speedup_stacks,
		"reroll_tokens": player.reroll_tokens,
		"skip_tokens": player.skip_tokens,
	}

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
			var xp_amount: int = int(orb.get_xp_amount())
			run_xp_gained += xp_amount
			player.add_experience(xp_amount)
		orb.queue_free()
