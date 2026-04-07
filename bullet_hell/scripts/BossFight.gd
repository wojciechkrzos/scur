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
const PLAY_AREA_RECT := Rect2(20, 20, 440, 500)

# ── Konfiguracje bossów ─────────────────────────────────────────────────────
# Żeby dodać nowego bossa: skopiuj słownik, zmień parametry i patterns[]
# patterns[] to nazwy metod z Boss.gd — wykonują się cyklicznie po kolei

const BOSS_A := {
	"win_condition": 1,  # 1 = KILL — zabij bossa, brak timera
	"hp": 150.0,
	"patterns": [
		{ "method": "_pattern_spiral",       "duration": 5.0, "fire_rate": 0.05 },
		{ "method": "_pattern_double_spiral", "duration": 6.0, "fire_rate": 0.04 },
		{ "method": "_pattern_aimed_burst",  "duration": 4.0, "fire_rate": 0.35 },
		{ "method": "_pattern_ring_burst",   "duration": 4.0, "fire_rate": 0.60 },
	]
}

const BOSS_B := {
	"win_condition": 0,  # 0 = SURVIVE — przeżyj X sekund
	"hp": 9999.0,        # praktycznie nieśmiertelny
	"time": 45.0,        # przeżyj 45 sekund
	"patterns": [
		{ "method": "_pattern_wall",          "duration": 4.0, "fire_rate": 0.10 },
		{ "method": "_pattern_cross_wave",    "duration": 5.0, "fire_rate": 0.08 },
		{ "method": "_pattern_random_spread", "duration": 4.0, "fire_rate": 0.08 },
		{ "method": "_pattern_flower",        "duration": 5.0, "fire_rate": 0.12 },
	]
}

# ── Sygnały do gry bazowej ──────────────────────────────────────────────────
signal fight_ended(result: String)  # "win" lub "lose"

# ── Stan gry ────────────────────────────────────────────────────────────────
var score: int = 0
var time_remaining: float = 0.0
var fight_active: bool = false

@onready var player = $Player
@onready var boss = $Boss
@onready var hud = $HUD
@onready var bullet_container = $BulletContainer
@onready var player_bullet_container = $PlayerBulletContainer

# ── API publiczne ────────────────────────────────────────────────────────────

## Wywołaj tę funkcję z gry bazowej, żeby odpalić mini-grę.
## win_cond: WinCondition.SURVIVE lub WinCondition.KILL
func start_fight(config: Dictionary) -> void:
	win_condition = config.get("win_condition", WinCondition.SURVIVE)
	boss_max_hp   = config.get("hp", 200.0)
	time_limit    = config.get("time", 30.0)
	time_remaining = time_limit
	fight_active  = true
	
	boss.setup(boss_max_hp, PLAY_AREA_RECT, config.get("patterns", []))
	player.setup(PLAY_AREA_RECT, player_bullet_container)
	hud.setup(win_condition, time_limit, boss_max_hp)
	_draw_play_area()


func _ready() -> void:
	boss.boss_died.connect(_on_boss_died)
	boss.bullet_spawned.connect(_on_boss_bullet_spawned)
	player.player_died.connect(_on_player_died)
	player.player_scored.connect(_on_player_scored)
	player.bullet_spawned.connect(_on_player_bullet_spawned)
	
	#USUNAC W PROD
	#start_fight(BOSS_B)  # ← zmień na BOSS_B żeby przetestować


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
	bullet.play_area = PLAY_AREA_RECT
	# Połącz kolizję z graczem
	bullet.area_entered.connect(_on_enemy_bullet_hit_player.bind(bullet))


func _on_player_bullet_spawned(bullet: Node2D) -> void:
	player_bullet_container.add_child(bullet)
	bullet.play_area = PLAY_AREA_RECT
	bullet.area_entered.connect(_on_player_bullet_hit_boss.bind(bullet))


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
	
	hud.show_result(result)
	
	# Poczekaj chwilę zanim wyemitujesz sygnał (żeby gracz zobaczył wynik)
	await get_tree().create_timer(2.5).timeout
	fight_ended.emit(result)


# ── Rysowanie obszaru gry ───────────────────────────────────────────────────

func _draw_play_area() -> void:
	var border = ColorRect.new()
	border.color = Color(0.04, 0.04, 0.08, 1.0)
	border.size = PLAY_AREA_RECT.size
	border.position = PLAY_AREA_RECT.position
	add_child(border)
	move_child(border, 0)  # Na spód hierarchii
	
	# Obramowanie (jasna ramka)
	var frame = ColorRect.new()
	frame.color = Color(0.3, 0.3, 0.5, 1.0)
	frame.size = PLAY_AREA_RECT.size + Vector2(4, 4)
	frame.position = PLAY_AREA_RECT.position - Vector2(2, 2)
	add_child(frame)
	move_child(frame, 0)
