extends Node2D

const BHHitboxDebugScript = preload("res://bullet_heaven/scripts/BHHitboxDebug.gd")

var _fight: Node2D

func _ready() -> void:
	z_index = 4096
	top_level = false

func setup(fight: Node2D) -> void:
	_fight = fight

func _is_visible() -> bool:
	if _fight != null and bool(_fight.get("show_hitbox_debug")):
		return true
	return BHHitboxDebugScript.is_enabled()

func _process(_delta: float) -> void:
	visible = _is_visible()
	if visible:
		queue_redraw()

func _draw() -> void:
	if not _is_visible() or _fight == null:
		return

	var player: Node2D = _fight.get("player")
	if player == null:
		return

	var player_collision_radius: float = float(_fight.get("player_collision_radius"))
	var enemy_container: Node2D = _fight.get("enemy_container")
	var bullet_container: Node2D = _fight.get("bullet_container")

	var player_origin := to_local(player.global_position)
	BHHitboxDebugScript.draw_collision_circle(
		self,
		player_origin,
		player_collision_radius,
		Color(0.2, 0.95, 1.0, 0.95)
	)
	BHHitboxDebugScript.draw_origin_marker(self, player_origin, Color(0.2, 0.95, 1.0, 0.95), 3.0)

	if player.has_method("get_debug_sprite_size"):
		var sprite_size: Vector2 = player.call("get_debug_sprite_size")
		BHHitboxDebugScript.draw_bounds_rect(
			self,
			player_origin,
			sprite_size,
			Color(0.35, 1.0, 0.45, 0.95)
		)

	if enemy_container != null:
		for enemy in enemy_container.get_children():
			if not is_instance_valid(enemy) or not (enemy is Node2D):
				continue
			_draw_enemy_debug(enemy as Node2D)

	if bullet_container != null:
		for bullet in bullet_container.get_children():
			if not is_instance_valid(bullet) or not (bullet is Node2D):
				continue
			_draw_attack_debug(bullet as Node2D)

	for child in player.get_children():
		if not is_instance_valid(child) or not (child is Node2D):
			continue
		if child.is_in_group("bh_player_attack"):
			_draw_attack_debug(child as Node2D)

	_draw_legend()

func _draw_legend() -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 14
	var x: float = 16.0
	var y: float = 84.0
	var line_height: float = 18.0
	var lines: Array[String] = [
		"H: toggle hitbox debug",
		"Cyan circle: player collision",
		"Green box: player sprite bounds",
		"Red circle: enemy collision",
		"Orange box: enemy sprite bounds",
		"Magenta circle: attack radius",
	]
	for line in lines:
		draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.95, 0.95, 0.95, 0.92))
		y += line_height

func _draw_enemy_debug(enemy: Node2D) -> void:
	var enemy_origin := to_local(enemy.global_position)
	var enemy_radius: float = 16.0
	if "collision_radius" in enemy:
		enemy_radius = float(enemy.collision_radius)

	BHHitboxDebugScript.draw_collision_circle(
		self,
		enemy_origin,
		enemy_radius,
		Color(1.0, 0.28, 0.28, 0.95)
	)
	BHHitboxDebugScript.draw_origin_marker(self, enemy_origin, Color(1.0, 0.28, 0.28, 0.95), 2.5)

	if enemy.has_method("get_debug_sprite_size"):
		var sprite_size: Vector2 = enemy.call("get_debug_sprite_size")
		BHHitboxDebugScript.draw_bounds_rect(
			self,
			enemy_origin,
			sprite_size,
			Color(1.0, 0.55, 0.2, 0.95)
		)

func _draw_attack_debug(node: Node2D) -> void:
	var attack_center := to_local(node.global_position)
	var attack_radius: float = 6.0
	if "radius" in node:
		attack_radius = float(node.radius)
	BHHitboxDebugScript.draw_collision_circle(
		self,
		attack_center,
		attack_radius,
		Color(0.92, 0.35, 1.0, 0.9)
	)
