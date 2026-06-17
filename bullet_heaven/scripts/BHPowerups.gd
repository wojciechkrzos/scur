extends RefCounted

const MAX_WEAPON_LEVEL := 5


enum WeaponId {
	AOE_PULSE,
	VERTICAL_JET,
	SPIRAL_STREAM,
	HOMING_MISSILE,
	MOLOTOV_BOMB,
	FAN_BURST
}

enum PowerupId {
	WEAPON_1,
	WEAPON_2,
	WEAPON_3,
	WEAPON_4,
	WEAPON_5,
	WEAPON_6,
	SPEEDUP,
	SHIELD,
}

const WEAPON_DEFINITIONS := {
	WeaponId.AOE_PULSE: {
		"name": "Impuls",
		"icon_path": "res://assets/bullet_heaven/icons/impulse.png",
		"fire_mode": "aoe_pulse",
		"levels": [
			{"damage": 1, "radius": 54.0, "lifetime": 0.32},
			{"damage": 1, "radius": 62.0, "lifetime": 0.34},
			{"damage": 2, "radius": 70.0, "lifetime": 0.36},
			{"damage": 2, "radius": 78.0, "lifetime": 0.38},
			{"damage": 3, "radius": 88.0, "lifetime": 0.42},
		],
	},
	WeaponId.VERTICAL_JET: {
		"name": "Strumień",
		"icon_path": "res://assets/bullet_heaven/icons/vertical_jet.png",
		"fire_mode": "vertical_jet",
		"levels": [
			{"damage": 1, "shot_speed": 270.0, "shot_count": 3, "spacing": 10.0},
			{"damage": 2, "shot_speed": 285.0, "shot_count": 3, "spacing": 10.0},
			{"damage": 2, "shot_speed": 300.0, "shot_count": 5, "spacing": 10.0},
			{"damage": 3, "shot_speed": 320.0, "shot_count": 5, "spacing": 10.0},
			{"damage": 3, "shot_speed": 345.0, "shot_count": 7, "spacing": 9.0},
		],
	},
	WeaponId.SPIRAL_STREAM: {
		"name": "Spirala",
		"icon_path": "res://assets/bullet_heaven/icons/spiral.png",
		"fire_mode": "spiral_stream",
		"levels": [
			{"damage": 1, "shot_speed": 250.0, "shot_count": 4, "phase_step": 0.35},
			{"damage": 1, "shot_speed": 260.0, "shot_count": 5, "phase_step": 0.40},
			{"damage": 2, "shot_speed": 270.0, "shot_count": 5, "phase_step": 0.46},
			{"damage": 2, "shot_speed": 285.0, "shot_count": 6, "phase_step": 0.53},
			{"damage": 3, "shot_speed": 300.0, "shot_count": 8, "phase_step": 0.62},
		],
	},
	WeaponId.HOMING_MISSILE: {
		"name": "Rakieta Samonaprowadzająca",
		"icon_path": "res://assets/bullet_heaven/icons/homing_missile.png",
		"fire_mode": "homing_missile",
		"levels": [
			{"damage": 3, "shot_speed": 185.0, "turn_rate": 3.6, "range": 1050.0, "shot_count": 1},
			{"damage": 4, "shot_speed": 195.0, "turn_rate": 4.1, "range": 1100.0, "shot_count": 1},
			{"damage": 4, "shot_speed": 205.0, "turn_rate": 4.7, "range": 1150.0, "shot_count": 2},
			{"damage": 5, "shot_speed": 220.0, "turn_rate": 5.3, "range": 1200.0, "shot_count": 2},
			{"damage": 6, "shot_speed": 235.0, "turn_rate": 6.0, "range": 1250.0, "shot_count": 3},
		],
	},
	WeaponId.MOLOTOV_BOMB: {
		"name": "Koktajl Mołotowa",
		"icon_path": "res://assets/bullet_heaven/icons/molotov.png",
		"fire_mode": "molotov_bomb",
		"levels": [
			{"damage": 1, "shot_speed": 145.0, "distance": 430.0, "explosion_damage": 3, "explosion_radius": 84.0, "explosion_lifetime": 1.4, "shot_count": 1},
			{"damage": 1, "shot_speed": 150.0, "distance": 445.0, "explosion_damage": 4, "explosion_radius": 92.0, "explosion_lifetime": 1.55, "shot_count": 1},
			{"damage": 2, "shot_speed": 155.0, "distance": 460.0, "explosion_damage": 4, "explosion_radius": 102.0, "explosion_lifetime": 1.7, "shot_count": 1},
			{"damage": 2, "shot_speed": 160.0, "distance": 475.0, "explosion_damage": 5, "explosion_radius": 111.0, "explosion_lifetime": 1.85, "shot_count": 2},
			{"damage": 3, "shot_speed": 170.0, "distance": 500.0, "explosion_damage": 6, "explosion_radius": 120.0, "explosion_lifetime": 2.0, "shot_count": 2},
		],
	},
	WeaponId.FAN_BURST: {
		"name": "Stożek Odłamków",
		"icon_path": "res://assets/bullet_heaven/icons/fan_burst.png",
		"fire_mode": "fan_burst",
		"levels": [
			{"damage": 1, "shot_speed": 280.0, "shot_count": 5, "spread": 0.84},
			{"damage": 1, "shot_speed": 290.0, "shot_count": 7, "spread": 0.96},
			{"damage": 2, "shot_speed": 300.0, "shot_count": 7, "spread": 1.02},
			{"damage": 2, "shot_speed": 315.0, "shot_count": 9, "spread": 1.08},
			{"damage": 3, "shot_speed": 330.0, "shot_count": 11, "spread": 1.16},
		],
	},
}

const POWERUP_DEFINITIONS := {
	PowerupId.WEAPON_1: {"name": "Impuls", "description": "Fala uderzeniowa wokół gracza", "kind": "weapon", "weapon_id": WeaponId.AOE_PULSE},
	PowerupId.WEAPON_2: {"name": "Strumień", "description": "Pionowa seria pocisków", "kind": "weapon", "weapon_id": WeaponId.VERTICAL_JET},
	PowerupId.WEAPON_3: {"name": "Spirala", "description": "Obrotowa spirala pocisków", "kind": "weapon", "weapon_id": WeaponId.SPIRAL_STREAM},
	PowerupId.WEAPON_4: {"name": "Rakieta Samonaprowadzająca", "description": "Pocisk śledzący najbliższego przeciwnika", "kind": "weapon", "weapon_id": WeaponId.HOMING_MISSILE},
	PowerupId.WEAPON_5: {"name": "Koktajl Mołotowa", "description": "Pocisk tworzący płonący obszar", "kind": "weapon", "weapon_id": WeaponId.MOLOTOV_BOMB},
	PowerupId.WEAPON_6: {"name": "Stożek Odłamków", "description": "Szeroka salwa przed graczem", "kind": "weapon", "weapon_id": WeaponId.FAN_BURST},
	PowerupId.SPEEDUP: {"name": "Przyspieszenie", "description": "Zwiększa prędkość ruchu", "kind": "speed", "value": 30.0, "icon_path": "res://assets/bullet_heaven/icons/speed.png"},
	PowerupId.SHIELD: {"name": "Tarcza", "description": "Dodatkowe życie", "kind": "shield", "value": 1, "icon_path": "res://assets/bullet_heaven/icons/shield.png"},
}

const POWERUP_ORDER: Array[int] = [
	PowerupId.WEAPON_1,
	PowerupId.WEAPON_2,
	PowerupId.WEAPON_3,
	PowerupId.WEAPON_4,
	PowerupId.WEAPON_5,
	PowerupId.WEAPON_6,
	PowerupId.SPEEDUP,
	PowerupId.SHIELD,
]

static func get_weapon_definition(weapon_id: int) -> Dictionary:
	return WEAPON_DEFINITIONS.get(weapon_id, {})

static func get_weapon_stats(weapon_id: int, level: int) -> Dictionary:
	var definition: Dictionary = get_weapon_definition(weapon_id)
	var levels: Array = definition.get("levels", [])
	if levels.is_empty():
		return {}
	var level_index: int = clampi(level, 1, levels.size()) - 1
	var stats: Dictionary = (levels[level_index] as Dictionary).duplicate(true)
	stats["name"] = String(definition.get("name", "Unknown Weapon"))
	stats["fire_mode"] = String(definition.get("fire_mode", ""))
	stats["level"] = level_index + 1
	return stats

static func get_weapon_name(weapon_id: int) -> String:
	return String(get_weapon_definition(weapon_id).get("name", "Unknown Weapon"))

static func get_weapon_icon(weapon_id: int) -> Texture2D:
	var path: String = String(get_weapon_definition(weapon_id).get("icon_path", ""))
	return load(path) as Texture2D if not path.is_empty() else null

static func get_powerup_data(powerup_id: int) -> Dictionary:
	return POWERUP_DEFINITIONS.get(powerup_id, {})

static func get_powerup_name(powerup_id: int) -> String:
	return String(get_powerup_data(powerup_id).get("name", "Unknown"))

static func get_powerup_description(powerup_id: int) -> String:
	return String(get_powerup_data(powerup_id).get("description", ""))

static func get_powerup_icon(powerup_id: int) -> Texture2D:
	var data: Dictionary = get_powerup_data(powerup_id)
	var path: String = String(data.get("icon_path", ""))
	if String(data.get("kind", "")) == "weapon":
		return get_weapon_icon(int(data.get("weapon_id", -1)))
	return load(path) as Texture2D if not path.is_empty() else null

static func get_random_choices(count: int, weapon_levels: Dictionary = {}) -> Array[int]:
	var new_weapons: Array[int] = []
	var upgrades_and_utility: Array[int] = []
	for powerup_id in POWERUP_ORDER:
		var data: Dictionary = get_powerup_data(powerup_id)
		if String(data.get("kind", "")) == "weapon":
			var weapon_id: int = int(data.get("weapon_id", -1))
			var current_level := int(weapon_levels.get(weapon_id, 0))
			if current_level >= MAX_WEAPON_LEVEL:
				continue
			if current_level <= 0:
				new_weapons.append(powerup_id)
			else:
				upgrades_and_utility.append(powerup_id)
			continue
		upgrades_and_utility.append(powerup_id)

	new_weapons.shuffle()
	upgrades_and_utility.shuffle()
	var options: Array[int] = []
	options.append_array(new_weapons)
	options.append_array(upgrades_and_utility)
	return options.slice(0, mini(count, options.size()))

static func get_upgrade_summary(weapon_id: int, current_level: int) -> String:
	var next_level: int = clampi(current_level + 1, 1, MAX_WEAPON_LEVEL)
	var current: Dictionary = get_weapon_stats(weapon_id, maxi(current_level, 1))
	var next: Dictionary = get_weapon_stats(weapon_id, next_level)
	if current_level <= 0:
		return "Nowa broń"

	match weapon_id:
		WeaponId.AOE_PULSE:
			return "Promień %.0f → %.0f | Obrażenia %d → %d" % [current.radius, next.radius, current.damage, next.damage]
		WeaponId.VERTICAL_JET, WeaponId.SPIRAL_STREAM, WeaponId.FAN_BURST:
			return "Pociski %d → %d | Obrażenia %d → %d" % [current.shot_count, next.shot_count, current.damage, next.damage]
		WeaponId.HOMING_MISSILE:
			return "Rakiety %d → %d | Obrażenia %d → %d" % [current.shot_count, next.shot_count, current.damage, next.damage]
		WeaponId.MOLOTOV_BOMB:
			return "Bomby %d → %d | Wybuch %d → %d" % [current.shot_count, next.shot_count, current.explosion_damage, next.explosion_damage]
	return "Poziom %d → %d" % [current_level, next_level]
