extends Node2D

signal fight_ended(result: String)

const BHEnemyScript = preload("res://bullet_heaven/scripts/BHEnemy.gd")
const BHExperienceOrbScript = preload("res://bullet_heaven/scripts/BHExperienceOrb.gd")
const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")

@export var stage_duration: float = 35.0
@export var base_spawn_interval: float = 0.6
@export var spawn_interval_floor: float = 0.2
@export var wave_step_seconds: float = 7.0
@export var world_scroll_speed: float = 520.0

var fight_active: bool = false
var time_remaining: float = 0.0
var kills: int = 0
var wave_level: int = 1
var current_spawn_interval: float = 0.6
var play_area_rect: Rect2 = Rect2(0, 0, 800, 600)
var world_offset: Vector2 = Vector2.ZERO
var pending_level_ups: int = 0
var current_powerup_choices: Array[int] = []

@onready var backdrop = $Backdrop
@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var pickup_container = $PickupContainer
@onready var bullet_container = $BulletContainer
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

func start_fight() -> void:
	play_area_rect = get_viewport_rect()
	fight_active = true
	time_remaining = stage_duration
	kills = 0
	wave_level = 1
	current_spawn_interval = base_spawn_interval
	world_offset = Vector2.ZERO

	player.setup(play_area_rect, bullet_container)
	hud.setup(stage_duration, player.max_lives)
	hud.update_pattern(player.get_pattern_name())
	backdrop.setup(play_area_rect)
	backdrop.set_scroll_offset(world_offset)
	enemy_container.position = Vector2.ZERO
	pickup_container.position = Vector2.ZERO
	bullet_container.position = Vector2.ZERO
	pending_level_ups = 0
	current_powerup_choices.clear()
	_hide_level_up_ui()

	for child in enemy_container.get_children():
		child.queue_free()
	for child in pickup_container.get_children():
		child.queue_free()
	for child in bullet_container.get_children():
		child.queue_free()

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
	start_fight()

func _process(delta: float) -> void:
	if not fight_active:
		return

	_scroll_world(delta)

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

func _spawn_enemy() -> void:
	if not fight_active:
		return

	var enemy = BHEnemyScript.new()
	enemy.player_ref = player
	enemy.global_position = _random_edge_position(play_area_rect)
	enemy.area_entered.connect(_on_enemy_area_entered.bind(enemy))
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy_container.add_child(enemy)

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

func _spawn_xp_pellet(position: Vector2, xp_amount: int) -> void:
	var orb = BHExperienceOrbScript.new()
	orb.xp_amount = max(xp_amount, 1)
	orb.add_to_group("bh_xp_pellet")
	orb.position = pickup_container.to_local(position)
	pickup_container.call_deferred("add_child", orb)

func _open_level_up_ui(current_level: int) -> void:
	if current_powerup_choices.is_empty():
		current_powerup_choices = BHPowerups.get_random_choices(3, player.get_owned_weapon_ids())

	level_up_title.text = "LEVEL UP"
	level_up_subtitle.text = "Level %02d - choose 1 of 3 powerups" % current_level
	level_up_hint.text = "Paused until you pick an upgrade"

	var buttons := [choice_button_1, choice_button_2, choice_button_3]
	for index in buttons.size():
		var button: Button = buttons[index]
		if index < current_powerup_choices.size():
			var powerup_id := current_powerup_choices[index]
			button.visible = true
			button.disabled = false
			button.text = BHPowerups.get_powerup_name(powerup_id) + "\n" + BHPowerups.get_powerup_description(powerup_id)
			button.set_meta("powerup_id", powerup_id)
		else:
			button.visible = false

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

	var scroll_delta := -move_input * world_scroll_speed * delta
	world_offset += scroll_delta
	enemy_container.position += scroll_delta
	pickup_container.position += scroll_delta
	bullet_container.position += scroll_delta
	backdrop.set_scroll_offset(world_offset)
