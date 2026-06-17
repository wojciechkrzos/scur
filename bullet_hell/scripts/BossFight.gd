## BossFight.gd
## Główny kontroler mini-gry. Wywoływany z gry bazowej przez:
##   BossFight.start_fight(win_condition, boss_hp, time_limit)
## Emituje sygnał fight_ended(result) gdzie result to "win"/"lose"

extends Node2D

const CombatAudioScript = preload("res://bullet_heaven/scripts/BHAudio.gd")
const HellBackdropScript = preload("res://bullet_hell/scripts/HellBackdrop.gd")

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

# const BOSS_C := {
# 	"win_condition": 1,
# 	"hp": 100.0,
# 	"patterns": [
# 		{ "method": "_pattern_radial", "duration": 6.0, "fire_rate": 0.12 },
# 		{ "method": "_pattern_spiral", "duration": 6.0, "fire_rate": 0.08 },
# 		{ "method": "_pattern_aimed_burst", "duration": 5.0, "fire_rate": 0.4 },
# 		{ "method": "_pattern_cross_wave", "duration": 5.0, "fire_rate": 0.10 },
# 	]
# }
# const BOSS_C := {
# 	"win_condition": 1,
# 	"hp": 130.0,
# 	"patterns": [
# 		{ "method": "_pattern_homing_ring",   "duration": 6.0, "fire_rate": 0.9 },
# 		{ "method": "_pattern_gap_wall",      "duration": 5.0, "fire_rate": 0.12 },
# 		{ "method": "_pattern_aimed_triple",  "duration": 5.0, "fire_rate": 0.25 },
# 		{ "method": "_pattern_double_spiral", "duration": 6.0, "fire_rate": 0.05 },
# 		{ "method": "_pattern_circle_pulse",  "duration": 6.0, "fire_rate": 0.85 },
# 		{ "method": "_pattern_random_spread", "duration": 4.0, "fire_rate": 0.08 },
# 	]
# }
const BOSS_C := {
    "win_condition": 1,
    "hp": 120.0,
    "patterns": [
        { "method": "_pattern_freeze_trap",   "duration": 3.0, "fire_rate": 0.7 }, 
        { "method": "_pattern_homing_ring",    "duration": 4.0, "fire_rate": 1.2 },
		{ "method": "_pattern_freeze_trap",   "duration": 3.0, "fire_rate": 0.7 }, 
        { "method": "_pattern_void_burst",     "duration": 4.0, "fire_rate": 1.0 },
		{ "method": "_pattern_soft_fan",      "duration": 4.0, "fire_rate": 0.85 },
        { "method": "_pattern_circle_pulse",   "duration": 4.5, "fire_rate": 0.8 },
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
var elapsed_fight_time: float = 0.0

var _objective_intro_layer: CanvasLayer = null
var _objective_intro_root: Control = null
var _objective_intro_text: Label = null
var _objective_intro_shooting: Label = null
var _objective_intro_skip: Button = null
var audio_controller
var _hit_shake_tween: Tween

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
	elapsed_fight_time = 0.0
	fight_active  = false
	_ensure_audio_controller()
	audio_controller.play_music("bullet_hell")
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
	_ensure_audio_controller()
	boss.boss_died.connect(_on_boss_died)
	boss.bullet_spawned.connect(_on_boss_bullet_spawned)
	player.player_died.connect(_on_player_died)
	player.player_hit.connect(_on_player_hit)
	player.player_scored.connect(_on_player_scored)
	player.bullet_spawned.connect(_on_player_bullet_spawned)
	
	#USUNAC W PROD
	#start_fight(BOSS_B)  # ← zmień na BOSS_B żeby przetestować

	_build_objective_intro_overlay()

func _ensure_audio_controller() -> void:
	if audio_controller != null and is_instance_valid(audio_controller):
		return
	audio_controller = CombatAudioScript.new()
	audio_controller.name = "BulletHellAudio"
	add_child(audio_controller)


func _process(delta: float) -> void:
	if not fight_active:
		return
	elapsed_fight_time += delta
	
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

func _on_player_hit(_remaining_lives: int) -> void:
	hud.play_damage_feedback()
	_play_hit_shake()

func _play_hit_shake() -> void:
	if _hit_shake_tween != null and _hit_shake_tween.is_valid():
		_hit_shake_tween.kill()
	position = Vector2.ZERO
	_hit_shake_tween = create_tween()
	_hit_shake_tween.tween_property(self, "position", Vector2(6.0, -3.0), 0.035)
	_hit_shake_tween.tween_property(self, "position", Vector2(-5.0, 4.0), 0.045)
	_hit_shake_tween.tween_property(self, "position", Vector2(3.0, 1.0), 0.04)
	_hit_shake_tween.tween_property(self, "position", Vector2.ZERO, 0.06)


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
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null and game_state.has_method("record_run_score"):
		game_state.record_run_score(0, elapsed_fight_time / 60.0, 0, score)
	
	# Poczekaj chwilę zanim wyemitujesz sygnał (żeby gracz zobaczył wynik)
	await get_tree().create_timer(2.5).timeout
	fight_ended.emit(result)


# ── Rysowanie obszaru gry ───────────────────────────────────────────────────

func _draw_play_area() -> void:
	var starfield = HellBackdropScript.new()
	starfield.name = "HellBackdrop"
	starfield.setup(play_area_rect)
	starfield.set_meta("play_area_visual", true)
	add_child(starfield)
	move_child(starfield, 0)

	# 1. Głębokie, ciemne tło samego pola walki
	var border = ColorRect.new()
	border.color = Color(0.015, 0.0, 0.006, 0.38)
	border.size = play_area_rect.size
	border.position = play_area_rect.position
	border.set_meta("play_area_visual", true)
	add_child(border)
	move_child(border, 0)
	
	# 2. Ramka z neonową poświatą (Glow) wokół pola gry
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = Color.TRANSPARENT
	frame_style.border_width_left = 3
	frame_style.border_width_top = 3
	frame_style.border_width_right = 3
	frame_style.border_width_bottom = 3
	frame_style.border_color = Color(0.94, 0.02, 0.07, 0.88)
	frame_style.shadow_size = 10
	frame_style.shadow_color = Color(0.9, 0.0, 0.04, 0.38)
	
	var frame = Panel.new()
	frame.add_theme_stylebox_override("panel", frame_style)
	frame.size = play_area_rect.size + Vector2(6, 6)
	frame.position = play_area_rect.position - Vector2(3, 3)
	frame.set_meta("play_area_visual", true)
	add_child(frame)
	move_child(frame, 1)
	var frame_tween := frame.create_tween().set_loops()
	frame_tween.tween_property(frame, "modulate", Color(1.0, 0.34, 0.34, 0.78), 0.9).set_trans(Tween.TRANS_SINE)
	frame_tween.tween_property(frame, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE)

	# 3. GENIALNY MASKER: Tworzymy czarne zasłony na krawędziach ekranu,
	# dzięki czemu pociski wychodzące za ramkę "znikną" pod nimi dla oka gracza!
	var window_size = get_viewport().get_visible_rect().size
	
	# Kotwice dla 4 zasłon (lewa, prawa, górna, dolna)
	var masks = [
		Rect2(0, 0, play_area_rect.position.x, window_size.y), # Lewa
		Rect2(play_area_rect.end.x, 0, window_size.x - play_area_rect.end.x, window_size.y), # Prawa
		Rect2(play_area_rect.position.x, 0, play_area_rect.size.x, play_area_rect.position.y), # Górna
		Rect2(play_area_rect.position.x, play_area_rect.end.y, play_area_rect.size.x, window_size.y - play_area_rect.end.y) # Dolna
	]
	
	for m_rect in masks:
		var mask = ColorRect.new()
		mask.color = Color(0.025, 0.0, 0.006, 1.0)
		mask.size = m_rect.size
		mask.position = m_rect.position
		mask.set_meta("play_area_visual", true)
		add_child(mask)
		# Wrzucamy maski tuż pod HUD, ale nad pociski (wybierz odpowiedni indeks w zależności od projektu)
		move_child(mask, get_child_count() - 2)
