## BossFight.gd
## Główny kontroler mini-gry. Wywoływany z gry bazowej przez:
##   BossFight.start_fight(win_condition, boss_hp, time_limit)
## Emituje sygnał fight_ended(result) gdzie result to "win"/"lose"

extends Node2D

# ── Konfiguracja wywołania ──────────────────────────────────────────────────
enum WinCondition { SURVIVE, KILL }

@export var win_condition: WinCondition = WinCondition.SURVIVE
@export var time_limit: float = 30.0
@export var boss_max_hp: float = 200.0

# ── Rozmiar planszy (stały prostokąt jak w Touhou) ──────────────────────────
const PLAY_AREA_SIZE := Vector2(440, 500)

# ── Konfiguracje bossów ─────────────────────────────────────────────────────
# Żeby dodać nowego bossa: skopiuj słownik, zmień parametry i patterns[]
# patterns[] to nazwy metod z Boss.gd — wykonują się cyklicznie po kolei

#const BOSS_A := {
	#"win_condition": 1,  # 1 = KILL — zabij bossa, brak timera
	#"hp": 150.0,
	#"patterns": [
		#{ "method": "_pattern_spiral",       "duration": 5.0, "fire_rate": 0.05 },
		#{ "method": "_pattern_double_spiral", "duration": 6.0, "fire_rate": 0.04 },
		#{ "method": "_pattern_aimed_burst",  "duration": 4.0, "fire_rate": 0.35 },
		#{ "method": "_pattern_ring_burst",   "duration": 4.0, "fire_rate": 0.60 },
	#]
#}

const BOSS_A := {
	"win_condition": 1,
	"hp": 100.0,
	"patterns": [
		{ "method": "_pattern_radial", "duration": 6.0, "fire_rate": 0.12 },
		{ "method": "_pattern_spiral", "duration": 6.0, "fire_rate": 0.08 },
		{ "method": "_pattern_aimed_burst", "duration": 5.0, "fire_rate": 0.4 },
		{ "method": "_pattern_cross_wave", "duration": 5.0, "fire_rate": 0.10 },
	]
}


const BOSS_B := {
	"win_condition": 0,  # 0 = SURVIVE — przeżyj X sekund
	"hp": 9999.0,        # praktycznie nieśmiertelny
	"time": 35.0,        # przeżyj 35 sekund
	"move_speed": 42.0,
	"patterns": [
		{ "method": "_pattern_circle_pulse", "duration": 6.0, "fire_rate": 0.50 },
		# increased circle frequency
		{ "method": "_pattern_soft_fan",      "duration": 6.0, "fire_rate": 0.85 },
		{ "method": "_pattern_homing_ring",   "duration": 6.0, "fire_rate": 1.00 },
		{ "method": "_pattern_random_spread",  "duration": 5.0, "fire_rate": 0.4 },
	]
}

# ── Sygnały do gry bazowej ──────────────────────────────────────────────────
signal fight_ended(result: String)  # "win" lub "lose"

# ── Stan gry ────────────────────────────────────────────────────────────────
var score: int = 0
var time_remaining: float = 0.0
var fight_active: bool = false
var play_area_rect: Rect2 = Rect2(20, 20, PLAY_AREA_SIZE.x, PLAY_AREA_SIZE.y)
var _intro_active: bool = false
var _intro_token: int = 0

var _objective_intro_layer: CanvasLayer = null
var _objective_intro_root: Control = null
var _objective_intro_text: Label = null
var _objective_intro_shooting: Label = null
var _objective_intro_skip: Button = null

@onready var player = $Player
@onready var boss = $Boss
@onready var hud = $HUD
@onready var bullet_container = $BulletContainer
@onready var player_bullet_container = $PlayerBulletContainer

func get_stage_type() -> String:
	return "boss"

# ── API publiczne ────────────────────────────────────────────────────────────

## Wywołaj tę funkcję z gry bazowej, żeby odpalić mini-grę.
## win_cond: WinCondition.SURVIVE lub WinCondition.KILL
func start_fight(config: Dictionary) -> void:
	win_condition = config.get("win_condition", WinCondition.SURVIVE)
	boss_max_hp   = config.get("hp", 200.0)
	time_limit    = config.get("time", 30.0)
	# apply move_speed to the Boss node if provided in config
	if config.has("move_speed") and boss != null:
		boss.move_speed = float(config.get("move_speed"))
	time_remaining = time_limit
	fight_active  = false
	var viewport_rect := get_viewport_rect()
	var play_top_left := (viewport_rect.size - PLAY_AREA_SIZE) * 0.5
	play_area_rect = Rect2(play_top_left, PLAY_AREA_SIZE)
	
	boss.setup(boss_max_hp, play_area_rect, config.get("patterns", []))
	player.setup(play_area_rect, player_bullet_container)
	player.set_shoot_enabled(win_condition == WinCondition.KILL)
	boss.player_ref = player
	hud.setup(win_condition, time_limit, boss_max_hp)
	hud.set_boss_hp_visible(win_condition == WinCondition.KILL)
	_draw_play_area()
	_begin_objective_intro()


func _ready() -> void:
	boss.boss_died.connect(_on_boss_died)
	boss.bullet_spawned.connect(_on_boss_bullet_spawned)
	player.player_died.connect(_on_player_died)
	player.player_scored.connect(_on_player_scored)
	player.bullet_spawned.connect(_on_player_bullet_spawned)
	
	#USUNAC W PROD
	#start_fight(BOSS_B)  # ← zmień na BOSS_B żeby przetestować

	_build_objective_intro_overlay()


func _process(delta: float) -> void:
	if not fight_active:
		return
	
	# Timer tylko w trybie SURVIVE
	if win_condition == WinCondition.SURVIVE:
		time_remaining -= delta
		hud.update_timer(time_remaining)
		if time_remaining <= 0.0:
			_end_fight("win")
	else:
		# KILL — schowaj timer, pokaż "zabij bossa"
		hud.hide_timer()
	
	hud.update_score(score)
	hud.update_boss_hp(boss.current_hp, boss_max_hp)
	
	# Win condition: przeżycie
	if win_condition == WinCondition.SURVIVE and time_remaining <= 0.0:
		_end_fight("win")
	
	# Lose condition: czas minął a gracz nie przeżył / jest bez żyć
	if time_remaining <= 0.0 and win_condition == WinCondition.KILL:
		_end_fight("lose")


# ── Obsługa sygnałów ────────────────────────────────────────────────────────

func _on_boss_died() -> void:
	if win_condition == WinCondition.KILL:
		_end_fight("win")
	else:
		# Boss umarł, ale warunek to przetrwanie — po prostu koniec
		_end_fight("win")


func _on_player_died() -> void:
	_end_fight("lose")


func _on_player_scored(points: int) -> void:
	score += points
	hud.flash_score()


func _on_boss_bullet_spawned(bullet: Node2D) -> void:
	bullet_container.add_child(bullet)
	bullet.play_area = play_area_rect
	# Połącz kolizję z graczem
	bullet.area_entered.connect(_on_enemy_bullet_hit_player.bind(bullet))


func _on_player_bullet_spawned(bullet: Node2D) -> void:
	player_bullet_container.add_child(bullet)
	bullet.play_area = play_area_rect
	bullet.area_entered.connect(_on_player_bullet_hit_boss.bind(bullet))


func _build_objective_intro_overlay() -> void:
	if _objective_intro_layer != null:
		return

	_objective_intro_layer = CanvasLayer.new()
	_objective_intro_layer.name = "ObjectiveIntroLayer"
	_objective_intro_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_objective_intro_layer.visible = false
	add_child(_objective_intro_layer)

	var dim := ColorRect.new()
	dim.anchors_preset = Control.PRESET_FULL_RECT
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	_objective_intro_layer.add_child(dim)

	_objective_intro_root = Control.new()
	_objective_intro_root.anchors_preset = Control.PRESET_FULL_RECT
	_objective_intro_root.anchor_right = 1.0
	_objective_intro_root.anchor_bottom = 1.0
	_objective_intro_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_objective_intro_layer.add_child(_objective_intro_root)

	_objective_intro_text = Label.new()
	_objective_intro_text.anchor_left = 0.5
	_objective_intro_text.anchor_top = 0.42
	_objective_intro_text.anchor_right = 0.5
	_objective_intro_text.anchor_bottom = 0.42
	_objective_intro_text.offset_left = -260.0
	_objective_intro_text.offset_top = -60.0
	_objective_intro_text.offset_right = 260.0
	_objective_intro_text.offset_bottom = 10.0
	_objective_intro_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_intro_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_objective_intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective_intro_text.add_theme_font_size_override("font_size", 30)
	_objective_intro_root.add_child(_objective_intro_text)

	_objective_intro_shooting = Label.new()
	_objective_intro_shooting.anchor_left = 0.5
	_objective_intro_shooting.anchor_top = 0.52
	_objective_intro_shooting.anchor_right = 0.5
	_objective_intro_shooting.anchor_bottom = 0.52
	_objective_intro_shooting.offset_left = -260.0
	_objective_intro_shooting.offset_top = -10.0
	_objective_intro_shooting.offset_right = 260.0
	_objective_intro_shooting.offset_bottom = 50.0
	_objective_intro_shooting.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_intro_shooting.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_objective_intro_shooting.add_theme_font_size_override("font_size", 24)
	_objective_intro_root.add_child(_objective_intro_shooting)

	_objective_intro_skip = Button.new()
	_objective_intro_skip.anchor_left = 0.5
	_objective_intro_skip.anchor_top = 0.88
	_objective_intro_skip.anchor_right = 0.5
	_objective_intro_skip.anchor_bottom = 0.88
	_objective_intro_skip.offset_left = -180.0
	_objective_intro_skip.offset_top = -18.0
	_objective_intro_skip.offset_right = 180.0
	_objective_intro_skip.offset_bottom = 18.0
	_objective_intro_skip.flat = true
	_objective_intro_skip.text = "Spacja - pomiń"
	_objective_intro_skip.focus_mode = Control.FOCUS_ALL
	_objective_intro_skip.add_theme_font_size_override("font_size", 20)
	_objective_intro_skip.pressed.connect(_skip_objective_intro)
	_objective_intro_root.add_child(_objective_intro_skip)


func _begin_objective_intro() -> void:
	_build_objective_intro_overlay()
	_intro_token += 1
	var token := _intro_token
	_intro_active = true
	_objective_intro_text.text = _get_objective_intro_text()
	_objective_intro_shooting.text = _get_shooting_text()
	_objective_intro_layer.visible = true
	_objective_intro_skip.grab_focus()
	get_tree().paused = true
	await get_tree().create_timer(5.0, true, false, false).timeout
	if _intro_active and token == _intro_token:
		_finish_objective_intro()


func _skip_objective_intro() -> void:
	if not _intro_active:
		return
	_finish_objective_intro()


func _finish_objective_intro() -> void:
	_intro_active = false
	get_tree().paused = false
	if _objective_intro_layer != null:
		_objective_intro_layer.visible = false
	fight_active = true


func _get_objective_intro_text() -> String:
	if win_condition == WinCondition.KILL:
		return "Cel: Zabij bossa"
	return "Cel: Przetrwaj fale pocisków"


func _get_shooting_text() -> String:
	if win_condition == WinCondition.KILL:
		return "Strzelanie: włączone"
	return "Strzelanie: wyłączone"


func _on_enemy_bullet_hit_player(area: Area2D, bullet: Node2D) -> void:
	if area == player and player.is_alive and not player.is_invincible:
		bullet.queue_free()
		player.take_hit()
		hud.update_lives(player.lives)


func _on_player_bullet_hit_boss(area: Area2D, bullet: Node2D) -> void:
	if area == boss and fight_active:
		bullet.queue_free()
		if win_condition == WinCondition.KILL:
			boss.take_damage(1.0)
			score += 10
		# W trybie SURVIVE: pocisk znika ale boss nie dostaje dmg


# ── Zakończenie walki ───────────────────────────────────────────────────────

func _end_fight(result: String) -> void:
	if not fight_active:
		return
	fight_active = false
	
	player.fight_active = false
	boss.fight_active = false
	
	# Wyczyść wszystkie pociski
	for b in bullet_container.get_children():
		b.queue_free()
	for b in player_bullet_container.get_children():
		b.queue_free()
	for child in get_children():
		if child.has_meta("play_area_visual"):
			child.queue_free()
	
	hud.show_result(result)
	
	# Poczekaj chwilę zanim wyemitujesz sygnał (żeby gracz zobaczył wynik)
	await get_tree().create_timer(2.5).timeout
	fight_ended.emit(result)


# ── Rysowanie obszaru gry ───────────────────────────────────────────────────

func _draw_play_area() -> void:
	var border = ColorRect.new()
	border.color = Color(0.04, 0.04, 0.08, 1.0)
	border.size = play_area_rect.size
	border.position = play_area_rect.position
	border.set_meta("play_area_visual", true)
	add_child(border)
	move_child(border, 0)  # Na spód hierarchii
	
	# Obramowanie (jasna ramka)
	var frame = ColorRect.new()
	frame.color = Color(0.3, 0.3, 0.5, 1.0)
	frame.size = play_area_rect.size + Vector2(4, 4)
	frame.position = play_area_rect.position - Vector2(2, 2)
	frame.set_meta("play_area_visual", true)
	add_child(frame)
	move_child(frame, 0)
