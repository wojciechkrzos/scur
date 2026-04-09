extends Node2D

signal fight_ended(result: String)

const BHEnemyScript = preload("res://bullet_heaven/scripts/BHEnemy.gd")

const PLAYER_COLLISION_DAMAGE := 999
const WAVE_INTERVAL_DECREMENT := 0.07

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

@onready var backdrop = $Backdrop
@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var bullet_container = $BulletContainer
@onready var spawn_timer = $SpawnTimer
@onready var hud = $HUD

func start_fight() -> void:
	_reset_stage_state()

	player.setup(play_area_rect, bullet_container)
	hud.setup(stage_duration, player.max_lives)
	backdrop.setup(play_area_rect)
	backdrop.set_scroll_offset(world_offset)

	spawn_timer.wait_time = current_spawn_interval
	if not spawn_timer.timeout.is_connected(_spawn_enemy):
		spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

func _ready() -> void:
	player.player_died.connect(_on_player_died)
	player.shot_spawned.connect(_on_player_shot_spawned)
	start_fight()

func _process(delta: float) -> void:
	if not fight_active:
		return

	_scroll_world(delta)
	_update_combat_timer(delta)
	_update_hud()

func _spawn_enemy() -> void:
	if not fight_active:
		return

	var enemy = BHEnemyScript.new()
	enemy.player_ref = player
	enemy.global_position = _random_edge_position(play_area_rect)
	enemy.area_entered.connect(_on_enemy_area_entered.bind(enemy))
	enemy.died.connect(_on_enemy_died)
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
	shot.global_position = player.global_position
	shot.anchor_ref = player

func _on_enemy_area_entered(area: Area2D, enemy: Area2D) -> void:
	if not fight_active:
		return
	if area == player and player.is_alive:
		enemy.take_damage(PLAYER_COLLISION_DAMAGE)
		player.take_hit()
		return
	if area.is_in_group("bh_player_bullet"):
		enemy.take_damage(1)
		area.queue_free()

func _on_enemy_died() -> void:
	kills += 1

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

func _scroll_world(delta: float) -> void:
	var move_input: Vector2 = player.get_move_input()
	if move_input == Vector2.ZERO:
		return

	var scroll_delta := -move_input * world_scroll_speed * delta
	world_offset += scroll_delta
	enemy_container.position += scroll_delta
	bullet_container.position += scroll_delta
	backdrop.set_scroll_offset(world_offset)

func _reset_stage_state() -> void:
	play_area_rect = get_viewport_rect()
	fight_active = true
	time_remaining = stage_duration
	kills = 0
	wave_level = 1
	current_spawn_interval = base_spawn_interval
	world_offset = Vector2.ZERO
	enemy_container.position = Vector2.ZERO
	bullet_container.position = Vector2.ZERO
	_clear_container(enemy_container)
	_clear_container(bullet_container)

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _update_combat_timer(delta: float) -> void:
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_end_fight("win")
		return

	var target_wave := 1 + int((stage_duration - time_remaining) / wave_step_seconds)
	if target_wave <= wave_level:
		return

	wave_level = target_wave
	current_spawn_interval = max(spawn_interval_floor, base_spawn_interval - WAVE_INTERVAL_DECREMENT * float(wave_level - 1))
	spawn_timer.wait_time = current_spawn_interval

func _update_hud() -> void:
	hud.update_timer(time_remaining)
	hud.update_lives(player.lives)
	hud.update_kills(kills)
	hud.update_pattern(player.get_pattern_name())
