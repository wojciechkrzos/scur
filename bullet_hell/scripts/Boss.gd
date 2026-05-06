## Boss.gd
## Boss — system patternów jak w Touhou.
## Każdy pattern to osobna metoda _pattern_*().
## Dodaj nowe patterny i wrzuć je do PATTERNS[].

extends Area2D

signal boss_died
signal bullet_spawned(bullet: Node2D)

#import
const BulletScript = preload("res://bullet_hell/scripts/Bullet.gd")

# ── Statystyki ──────────────────────────────────────────────────────────────
@export var move_speed: float = 60.0

var current_hp: float = 200.0
var max_hp: float = 200.0
var fight_active: bool = true
var play_area: Rect2
var _active_patterns: Array = []

# ── System patternów ────────────────────────────────────────────────────────
# Każdy pattern to: { "method": "_pattern_xxx", "duration": sekundy, "fire_rate": sekundy }
const PATTERNS := [
	{ "method": "_pattern_radial",      "duration": 4.0, "fire_rate": 0.18 },
	{ "method": "_pattern_spiral",      "duration": 5.0, "fire_rate": 0.05 },
	{ "method": "_pattern_aimed_burst", "duration": 4.0, "fire_rate": 0.35 },
	{ "method": "_pattern_cross_wave",  "duration": 5.0, "fire_rate": 0.08 },
	{ "method": "_pattern_flower",      "duration": 5.0, "fire_rate": 0.12 },
	{ "method": "_pattern_wall",        "duration": 4.0, "fire_rate": 0.10 },
	# --- NOWE ---
	{ "method": "_pattern_double_spiral",  "duration": 6.0, "fire_rate": 0.04 },
	{ "method": "_pattern_ring_burst",     "duration": 4.0, "fire_rate": 0.60 },
	{ "method": "_pattern_random_spread",  "duration": 4.0, "fire_rate": 0.08 },
	{ "method": "_pattern_aimed_triple",   "duration": 5.0, "fire_rate": 0.25 },
	{ "method": "_pattern_circle_pulse",   "duration": 6.0, "fire_rate": 0.90 },
	{ "method": "_pattern_homing_ring",    "duration": 6.0, "fire_rate": 1.00 },
]

var _current_pattern_idx: int = 0
var _pattern_timer: float = 0.0
var _fire_timer: float = 0.0
var _spiral_angle: float = 0.0
var _wave_offset: float = 0.0
var _move_target: Vector2

# Referencja do gracza (ustawiana przez BossFight)
var player_ref: Node2D = null

@onready var shoot_timer = $ShootTimer
@onready var pattern_timer = $PatternTimer
@onready var hp_bar = $BossHP

# ── Konfiguracja ─────────────────────────────────────────────────────────────

func setup(hp: float, area: Rect2, custom_patterns: Array = []) -> void:
	#na razie chowam dla czytelnosci
	hp_bar.visible = false
	
	max_hp = hp
	current_hp = hp
	play_area = area
	
	# Użyj custom patternów jeśli podano, inaczej domyślne
	if custom_patterns.size() > 0:
		_active_patterns = custom_patterns
	else:
		_active_patterns = PATTERNS
	
	position = Vector2(area.position.x + area.size.x * 0.5, area.position.y + 80)
	_move_target = position
	
	# Kolizja bossa: warstwa 4, wykrywa warstwę 3 (pociski gracza)
	collision_layer = 4
	collision_mask = 3
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(50, 50)
	$BossCollision.shape = shape
	
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	
	#timers
	shoot_timer.timeout.connect(_on_fire_tick)
	shoot_timer.wait_time = _active_patterns[0]["fire_rate"]
	shoot_timer.start()
	
	pattern_timer.timeout.connect(_advance_pattern)
	pattern_timer.wait_time = _active_patterns[0]["duration"]
	pattern_timer.start()
	
	_reset_pattern_state()


func _process(delta: float) -> void:
	if not fight_active:
		return
	_move_boss(delta)


# ── Ruch bossa ───────────────────────────────────────────────────────────────

func _move_boss(delta: float) -> void:
	if position.distance_to(_move_target) < 5.0:
		_pick_new_target()
	position = position.move_toward(_move_target, move_speed * delta)


func _pick_new_target() -> void:
	var margin := 60.0
	_move_target = Vector2(
		randf_range(play_area.position.x + margin, play_area.end.x - margin),
		randf_range(play_area.position.y + margin, play_area.position.y + play_area.size.y * 0.4)
	)


# ── Zmiana patternu ──────────────────────────────────────────────────────────

func _advance_pattern() -> void:
	_current_pattern_idx = (_current_pattern_idx + 1) % _active_patterns.size()
	var p = _active_patterns[_current_pattern_idx]
	
	shoot_timer.wait_time = p["fire_rate"]
	pattern_timer.wait_time = p["duration"]
	_reset_pattern_state()


func _reset_pattern_state() -> void:
	_spiral_angle = 0.0
	_wave_offset = 0.0


# ── Główny tick strzelania ───────────────────────────────────────────────────

func _on_fire_tick() -> void:
	if not fight_active:
		return
	var method_name: String = _active_patterns[_current_pattern_idx]["method"]
	call(method_name)


# ════════════════════════════════════════════════════════════════════════════
#  PATTERNY STRZELANIA
#  Każda metoda _pattern_*() wywołuje _fire(direction, speed, color)
#  Żeby dodać nowy pattern: napisz metodę i wrzuć do PATTERNS[]
# ════════════════════════════════════════════════════════════════════════════

## Pattern 1: Radialny — kółko równomiernych pocisków
func _pattern_radial() -> void:
	var count := 12
	for i in count:
		var angle := TAU * i / count
		_fire(Vector2.from_angle(angle), 110.0, Color(1.0, 0.4, 0.4))


## Pattern 2: Spirala — ciągła spirala obracających się pocisków
func _pattern_spiral() -> void:
	var arms := 3
	for arm in arms:
		var angle := _spiral_angle + TAU * arm / arms
		_fire(Vector2.from_angle(angle), 130.0, Color(1.0, 0.8, 0.2))
	_spiral_angle += 0.18


## Pattern 3: Burst nakierowany na gracza
func _pattern_aimed_burst() -> void:
	if player_ref == null:
		return
	var to_player := (player_ref.position - position).normalized()
	var base_angle := to_player.angle()
	var spread := 5
	var spread_rad := 0.15
	for i in range(-spread, spread + 1):
		var angle := base_angle + i * spread_rad
		_fire(Vector2.from_angle(angle), 120.0, Color(1.0, 0.3, 0.8))


## Pattern 4: Fala krzyżowa — dwie fale prostopadłe z sinusoidalnym przesunięciem
func _pattern_cross_wave() -> void:
	# More dynamic cross waves: mix angled sweeping streams and faster fill shots
	var count := 10
	var speed_main := 140.0
	var speed_secondary := 190.0
	for i in range(count):
		var t := float(i) / count
		var phase := _wave_offset + t * TAU
		# oscillating angles so shots are not strictly vertical
		var angle_h := phase + sin(phase * 1.4) * 0.22
		var angle_v := phase - cos(phase * 1.2) * 0.22

		_fire(Vector2.from_angle(angle_h), speed_main, Color(0.4, 0.8, 1.0))
		_fire(Vector2.from_angle(angle_v), speed_main, Color(0.2, 1.0, 0.6))

		# occasional fast filler shots to punish standing still
		if i % 2 == 0:
			_fire(Vector2.from_angle(angle_h + 0.12), speed_secondary, Color(1.0, 0.6, 0.4))
	# sweep faster
	_wave_offset += 0.32


## Pattern 5: Kwiat — płatki z serii rozbieżnych pierścieni
func _pattern_flower() -> void:
	var petals := 6
	var bullets_per_petal := 3
	for p in petals:
		var base_angle := TAU * p / petals + _spiral_angle
		for b in bullets_per_petal:
			var offset := (b - 1) * 0.15
			_fire(Vector2.from_angle(base_angle + offset), 90.0 + b * 15.0, Color(1.0, 0.5, 1.0))
	_spiral_angle += 0.08


## Pattern 6: Ściana — poziome rzędy przesunięte w czasie (mura)
func _pattern_wall() -> void:
	var count := 9
	for i in count:
		var x_off := (float(i) / (count - 1) - 0.5) * 2.0
		var dir := Vector2(x_off * 0.3, 1.0).normalized()
		_fire(dir, 95.0, Color(0.9, 0.9, 0.3))


## Pattern 7: Miękki wachlarz nakierowany na gracza
func _pattern_soft_fan() -> void:
	if player_ref == null:
		return
	var to_player := (player_ref.position - position).normalized()
	var base_angle := to_player.angle()
	# Mix of slow-then-fast aimed arcs and a short burst of faster bullets for pressure
	var spread := 2
	var spread_rad := 0.18
	# aimed delayed arcs (capture player pos when slow phase ends, then accelerate past)
	for i in range(-spread, spread + 1):
		var angle := base_angle + i * spread_rad
		_fire_delayed_arc(
			Vector2.from_angle(angle),
			160.0,   # start speed
			30.0,    # min (slow) speed
			360.0,   # max speed after accel
			0.6,     # slow duration (0.6s)
			Color(0.8, 0.95, 1.0),
			player_ref,
			0.0,     # acceleration (default will be used if 0)
			0.0
		)
	# add a tighter burst to punish stationary players
	for j in 3:
		var offset := randf_range(-0.06, 0.06)
		_fire(Vector2.from_angle(base_angle + offset), 180.0, Color(1.0, 0.7, 0.5))


## Pattern 8: Powolny pierścień z czytelnymi przerwami
func _pattern_slow_ring() -> void:
	var count := 10
	for i in count:
		var angle := TAU * float(i) / float(count)
		_fire(Vector2.from_angle(angle), 72.0, Color(0.95, 0.75, 0.35))


## Pattern 9: Łagodna spirala z dwoma ramionami
func _pattern_lazy_spiral() -> void:
	var arms := 2
	for arm in arms:
		var angle := _spiral_angle + TAU * float(arm) / float(arms)
		_fire(Vector2.from_angle(angle), 88.0, Color(0.75, 0.45, 1.0))
	_spiral_angle += 0.11


## Pattern 10: Mur z bezpieczną przerwą pośrodku
func _pattern_gap_wall() -> void:
	var count := 9
	for i in count:
		if i == 4:
			continue
		var x_off := (float(i) / float(count - 1) - 0.5) * 2.0
		var dir := Vector2(x_off * 0.22, 1.0).normalized()
		_fire(dir, 110.0, Color(0.6, 1.0, 0.55))

## Podwójna spirala — dwie przeciwbieżne spirale jednocześnie
func _pattern_double_spiral() -> void:
	var arms := 4
	for arm in arms:
		var angle_cw  := _spiral_angle + TAU * arm / arms
		var angle_ccw := -_spiral_angle + TAU * arm / arms
		_fire(Vector2.from_angle(angle_cw),  125.0, Color(1.0, 0.3, 0.3))
		_fire(Vector2.from_angle(angle_ccw), 125.0, Color(0.3, 0.3, 1.0))
	_spiral_angle += 0.15


## Pierścień z pauzą — gęsty okrąg co chwilę, potem cisza
func _pattern_ring_burst() -> void:
	var count := 20
	for i in count:
		var angle := TAU * i / count
		_fire(Vector2.from_angle(angle), 90.0, Color(1.0, 0.6, 0.0))


## Losowy rozrzut — chaos, ale nakierowany luźno na gracza
func _pattern_random_spread() -> void:
	if player_ref == null:
		return
	var to_player := (player_ref.position - position).normalized()
	var base_angle := to_player.angle()
	for i in 10:
		var random_offset := randf_range(-0.8, 0.8)
		var speed := randf_range(200.0, 250.0)
		_fire(Vector2.from_angle(base_angle + random_offset), speed, Color(0.8, 1.0, 0.2))


## Potrójny nakierowany z bocznym rozrzutem — trudniejszy aimed
func _pattern_aimed_triple() -> void:
	if player_ref == null:
		return
	var to_player := (player_ref.position - position).normalized()
	var base_angle := to_player.angle()
	# Środkowy strumień
	for i in 3:
		_fire(Vector2.from_angle(base_angle + (i - 1) * 0.12), 130.0, Color(1.0, 0.2, 0.6))
	# Dwa boczne strumienie w stałych kierunkach
	_fire(Vector2.from_angle(base_angle + PI * 0.4), 100.0, Color(0.6, 0.2, 1.0))
	_fire(Vector2.from_angle(base_angle - PI * 0.4), 100.0, Color(0.6, 0.2, 1.0))


## Pattern 11: Circle pulse — najpierw zwalnia, potem gwałtownie przyspiesza
func _pattern_circle_pulse() -> void:
	var count := 14
	var slow_duration := 0.30
	for i in count:
		var angle := TAU * float(i) / float(count)
		_fire_delayed_arc(
			Vector2.from_angle(angle),
			145.0,
			28.0,
			320.0,
			slow_duration,
			Color(1.0, 0.85, 0.25)
		)


## Pattern 12: Homing ring — okrąg, który po chwili skręca w stronę gracza
func _pattern_homing_ring() -> void:
	if player_ref == null:
		return
	# Denser homing ring: two concentric rings with slight angular offset
	var count := 18
	for ring_idx in range(2):
		var angle_offset := 0.0 if ring_idx == 0 else TAU / (count * 2)
		for i in range(count):
			var angle := TAU * float(i) / float(count) + angle_offset
			# slower initial pause, then rapid acceleration toward captured player position
			_fire_delayed_arc(
				Vector2.from_angle(angle),
				150.0,   # start speed
				18.0,    # slow speed
				480.0,   # max speed (higher for difficulty)
				0.9,     # slow duration (0.9s)
				Color(0.55, 0.9, 1.0),
				player_ref,
				0.0,
				0.0
			)




# ── Spawn pocisku ────────────────────────────────────────────────────────────

func _fire(direction: Vector2, speed: float, color: Color) -> void:
	var b = _create_bullet(direction, speed, color)
	bullet_spawned.emit(b)


func _fire_delayed_arc(direction: Vector2, start_speed: float, min_speed: float, max_speed: float, slow_duration: float, color: Color, target_ref: Node2D = null, acceleration: float = 0.0, homing_strength: float = 0.0) -> void:
	var b = _create_bullet(direction, start_speed, color)
	b.set_meta("accelerate_after", slow_duration)
	# decelerate from start_speed down to min_speed over slow_duration
	var decel := -((start_speed - min_speed) / maxf(slow_duration, 0.01))
	b.set_meta("deceleration", decel)
	b.set_meta("min_speed", min_speed)
	b.set_meta("max_speed", max_speed)
	# if caller didn't provide acceleration, pick a sensible default so bullets re-accelerate
	var accel_to_use := acceleration
	if accel_to_use <= 0.0:
		# default: reach max_speed from min_speed in ~0.5s
		accel_to_use = maxf((max_speed - min_speed) / 0.5, 1.0)
	b.set_meta("acceleration", accel_to_use)
	if target_ref != null:
		b.set_meta("target_ref", target_ref)
		b.set_meta("homing_delay", slow_duration)
		b.set_meta("homing_strength", homing_strength)
	bullet_spawned.emit(b)


func _create_bullet(direction: Vector2, speed: float, color: Color) -> Node2D:
	var b = BulletScript.new()
	
	# Kształt: kółko (klasyczny pocisk Touhou)
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	b.add_child(col)
	
	# Wizualny sprite (kółko z SVG-like ColorRect)
	var vis = ColorRect.new()
	vis.size = Vector2(10, 10)
	vis.position = Vector2(-5, -5)
	vis.color = color
	b.add_child(vis)
	
	# Jądro (jasny środek — klasyczny styl Touhou)
	var core = ColorRect.new()
	core.size = Vector2(4, 4)
	core.position = Vector2(-2, -2)
	core.color = Color(1, 1, 1, 0.9)
	b.add_child(core)
	
	b.position = position
	b.collision_layer = 1   # Pociski wroga = warstwa 1
	b.collision_mask = 2    # Wykrywają gracza = warstwa 2
	
	# Ustaw prędkość i kierunek przez właściwości
	b.set_meta("direction", direction)
	b.set_meta("speed", speed)
	
	return b


# ── Obrażenia ────────────────────────────────────────────────────────────────

func take_damage(amount: float) -> void:
	current_hp -= amount
	hp_bar.value = current_hp
	
	# Flash na trafienie
	$BossSprite.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(self):
		$BossSprite.color = Color(0.8, 0.1, 0.1, 1)
	
	if current_hp <= 0:
		fight_active = false
		boss_died.emit()
