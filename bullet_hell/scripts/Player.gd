## Player.gd
## Gracz — mały punkt hitbox jak w Touhou.
## Shift = focus (wolniejszy ruch, widoczny hitbox, gęstszy ogień)

extends Area2D

#import
const PlayerBulletScript = preload("res://bullet_hell/scripts/PlayerBullet.gd")

signal player_died
signal player_scored(points: int)
signal bullet_spawned(bullet: Node2D)

# ── Statystyki ──────────────────────────────────────────────────────────────
@export var speed_normal: float = 220.0
@export var speed_focus: float = 100.0
@export var max_lives: int = 3
@export var shoot_damage: float = 1.0

# ── Stan ────────────────────────────────────────────────────────────────────
var lives: int = 3
var is_alive: bool = true
var is_invincible: bool = false
var fight_active: bool = true
var play_area: Rect2
var bullet_container: Node2D
var is_focused: bool = false  # Shift = tryb focus

# ── Efekt śmierci / nietykalności ───────────────────────────────────────────
var _blink_timer: float = 0.0
const INVINCIBILITY_DURATION := 1.5

@onready var hitbox_sprite = $HitboxSprite
@onready var focus_indicator = $FocusIndicator
@onready var shoot_timer = $ShootTimer
@onready var invincibility_timer = $InvincibilityTimer

# ── Konfiguracja ─────────────────────────────────────────────────────────────

func setup(area: Rect2, bullet_cont: Node2D) -> void:
	play_area = area
	bullet_container = bullet_cont
	lives = max_lives
	
	# Mały hitbox — tylko 4x4 piksele jak w Touhou
	var shape = RectangleShape2D.new()
	shape.size = Vector2(4, 4)
	$PlayerCollision.shape = shape
	
	# Połącz timer strzelania
	shoot_timer.timeout.connect(_shoot)
	invincibility_timer.timeout.connect(_end_invincibility)
	
	# Kolizja: gracz = warstwa 2, wykrywa warstwę 1 (pociski wroga)
	collision_layer = 2
	collision_mask = 1
	position = Vector2(
		area.position.x + area.size.x * 0.5,        # środek szerokości
		area.position.y + area.size.y * 0.8         # 80% wysokości
	)


func _process(delta: float) -> void:
	if not fight_active or not is_alive:
		return
	
	_handle_movement(delta)
	_handle_focus()
	_handle_blink(delta)


# ── Ruch ─────────────────────────────────────────────────────────────────────

func _handle_movement(delta: float) -> void:
	var dir := Vector2.ZERO
	
	if Input.is_action_pressed("ui_left")  or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("ui_up")   or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1
	
	if dir != Vector2.ZERO:
		dir = dir.normalized()
	
	var spd := speed_focus if is_focused else speed_normal
	var new_pos := position + dir * spd * delta
	
	# Ogranicz do planszy
	new_pos.x = clamp(new_pos.x, play_area.position.x + 4, play_area.end.x - 4)
	new_pos.y = clamp(new_pos.y, play_area.position.y + 4, play_area.end.y - 4)
	position = new_pos


func _handle_focus() -> void:
	is_focused = Input.is_key_pressed(KEY_SHIFT)
	focus_indicator.visible = is_focused
	# W trybie focus hitbox sprite jest bardziej widoczny
	hitbox_sprite.color = Color(1, 0.8, 0, 1) if is_focused else Color(1, 1, 1, 1)


# ── Strzelanie ───────────────────────────────────────────────────────────────

func _shoot() -> void:
	if not fight_active or not is_alive:
		return
	if not (Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		return
	
	if is_focused:
		# Focus: dwa gęste strzały prosto w górę
		_spawn_player_bullet(Vector2(0, -1), Vector2(-4, 0))
		_spawn_player_bullet(Vector2(0, -1), Vector2(4, 0))
	else:
		# Normal: trzy strzały w lekkiej rozpiętości
		_spawn_player_bullet(Vector2(-0.1, -1).normalized(), Vector2(-8, 0))
		_spawn_player_bullet(Vector2(0, -1), Vector2(0, 0))
		_spawn_player_bullet(Vector2(0.1, -1).normalized(), Vector2(8, 0))


func _spawn_player_bullet(direction: Vector2, offset: Vector2) -> void:
	var bullet = _create_player_bullet()
	bullet.position = position + offset
	bullet.direction = direction
	bullet.damage = shoot_damage
	bullet_spawned.emit(bullet)


func _create_player_bullet() -> Node2D:
	# Tworzymy bullet dynamicznie (nie potrzeba osobnej sceny)
	#zmiana - rozwiazanie problemu Invalid assignment of property or key 'direction' with value of type 'Vector2' on a base object of type 'Area2D'.
	var b = PlayerBulletScript.new()
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(4, 8)
	col.shape = shape
	b.add_child(col)
	
	var vis = ColorRect.new()
	vis.size = Vector2(4, 8)
	vis.position = Vector2(-2, -4)
	vis.color = Color(0.8, 1.0, 0.4, 1.0)
	b.add_child(vis)
	
	# Warstwa kolizji: gracz strzela = warstwa 3, trafia warstwę 4 (boss)
	b.collision_layer = 3
	b.collision_mask = 4
	
	return b


# ── Obrażenia ────────────────────────────────────────────────────────────────

func take_hit() -> void:
	if is_invincible or not is_alive:
		return
	
	lives -= 1
	
	if lives <= 0:
		is_alive = false
		visible = false
		player_died.emit()
	else:
		_start_invincibility()


func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer.start(INVINCIBILITY_DURATION)


func _end_invincibility() -> void:
	is_invincible = false
	visible = true
	hitbox_sprite.modulate.a = 1.0


func _handle_blink(delta: float) -> void:
	if not is_invincible:
		return
	_blink_timer += delta * 8.0
	hitbox_sprite.modulate.a = 0.3 + 0.7 * abs(sin(_blink_timer))
