extends RefCounted

enum WeaponId {
	AOE_PULSE,
	VERTICAL_JET,
	SPIRAL_STREAM,
	HOMING_MISSILE,
	MOLOTOV_BOMB,
	FAN_BURST,
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
		"fire_mode": "aoe_pulse",
		"damage": 1,
		"lifetime": 0.32,
	},
	WeaponId.VERTICAL_JET: {
		"name": "Strumień",
		"fire_mode": "vertical_jet",
		"damage": 1,
		"shot_speed": 270.0,
		"offsets": [-10.0, 0.0, 10.0],
	},
	WeaponId.SPIRAL_STREAM: {
		"name": "Spirala",
		"fire_mode": "spiral_stream",
		"damage": 1,
		"shot_speed": 250.0,
		"shot_count": 4,
		"angle_step": 0.45,
		"phase_step": 0.35,
	},
	WeaponId.HOMING_MISSILE: {
		"name": "Rakieta Samonaprowadzająca",
		"fire_mode": "homing_missile",
		"damage": 3,
		"shot_speed": 185.0,
		"turn_rate": 3.6,
		"range": 1050.0,
	},
	WeaponId.MOLOTOV_BOMB: {
		"name": "Koktajl Mołotowa",
		"fire_mode": "molotov_bomb",
		"damage": 1,
		"shot_speed": 145.0,
		"distance": 430.0,
		"explosion_damage": 3,
		"explosion_radius": 84.0,
		"explosion_lifetime": 1.4,
	},
	WeaponId.FAN_BURST: {
		"name": "Stożek Odłamków",
		"fire_mode": "fan_burst",
		"damage": 1,
		"shot_speed": 280.0,
		"angles": [-0.42, -0.2, 0.0, 0.2, 0.42],
	},
}

const POWERUP_DEFINITIONS := {
	PowerupId.WEAPON_1: {
		"name": "Impuls",
		"description": "Fala uderzeniowa wokół gracza",
		"kind": "weapon",
		"weapon_id": WeaponId.AOE_PULSE,
	},
	PowerupId.WEAPON_2: {
		"name": "Strumień",
		"description": "Pionowa seria pocisków",
		"kind": "weapon",
		"weapon_id": WeaponId.VERTICAL_JET,
	},
	PowerupId.WEAPON_3: {
		"name": "Spirala",
		"description": "Obrotowa spirala pocisków",
		"kind": "weapon",
		"weapon_id": WeaponId.SPIRAL_STREAM,
	},
	PowerupId.WEAPON_4: {
		"name": "Rakieta Samonaprowadzająca",
		"description": "Wolny pocisk śledzący najbliższego przeciwnika",
		"kind": "weapon",
		"weapon_id": WeaponId.HOMING_MISSILE,
	},
	PowerupId.WEAPON_5: {
		"name": "Koktajl Mołotowa",
		"description": "Ciężki pocisk przebijający wrogów i wybuchający po dystansie",
		"kind": "weapon",
		"weapon_id": WeaponId.MOLOTOV_BOMB,
	},
	PowerupId.WEAPON_6: {
		"name": "Stożek Odłamków",
		"description": "Szeroka salwa przed graczem",
		"kind": "weapon",
		"weapon_id": WeaponId.FAN_BURST,
	},
	PowerupId.SPEEDUP: {
		"name": "Przyspieszenie",
		"description": "Zwiększa prędkość ruchu",
		"kind": "speed",
		"value": 30.0,
	},
	PowerupId.SHIELD: {
		"name": "Tarcza",
		"description": "Dodatkowe życie",
		"kind": "shield",
		"value": 1,
	},
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
	if WEAPON_DEFINITIONS.has(weapon_id):
		return WEAPON_DEFINITIONS[weapon_id]
	return {}

static func get_weapon_name(weapon_id: int) -> String:
	var data := get_weapon_definition(weapon_id)
	return String(data.get("name", "Unknown Weapon"))

static func get_powerup_data(powerup_id: int) -> Dictionary:
	if POWERUP_DEFINITIONS.has(powerup_id):
		return POWERUP_DEFINITIONS[powerup_id]
	return {}

static func get_powerup_name(powerup_id: int) -> String:
	var data := get_powerup_data(powerup_id)
	return String(data.get("name", "Unknown"))

static func get_powerup_description(powerup_id: int) -> String:
	var data := get_powerup_data(powerup_id)
	return String(data.get("description", ""))

static func get_random_choices(count: int, excluded_weapon_ids: Array[int] = []) -> Array[int]:
	var options := POWERUP_ORDER.duplicate()
	options = options.filter(
		func(powerup_id):
			var data := get_powerup_data(powerup_id)
			if String(data.get("kind", "")) != "weapon":
				return true
			var weapon_id := int(data.get("weapon_id", -1))
			return not excluded_weapon_ids.has(weapon_id)
	)

	options.shuffle()
	var picks: Array[int] = []
	for powerup_id in options:
		if picks.size() >= count:
			break
		picks.append(powerup_id)

	if picks.size() < count:
		var fallback := POWERUP_ORDER.duplicate()
		fallback.shuffle()
		for powerup_id in fallback:
			if picks.size() >= count:
				break
			if not picks.has(powerup_id):
				picks.append(powerup_id)
	return picks
