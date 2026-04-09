extends RefCounted

enum WeaponId {
	AOE_PULSE,
	VERTICAL_JET,
	SPIRAL_STREAM,
}

enum PowerupId {
	WEAPON_1,
	WEAPON_2,
	WEAPON_3,
	SPEEDUP,
	SHIELD,
}

const WEAPON_DEFINITIONS := {
	WeaponId.AOE_PULSE: {
		"name": "Weapon 1",
		"fire_mode": "aoe_pulse",
		"damage": 1,
		"lifetime": 0.32,
	},
	WeaponId.VERTICAL_JET: {
		"name": "Weapon 2",
		"fire_mode": "vertical_jet",
		"damage": 1,
		"shot_speed": 270.0,
		"offsets": [-10.0, 0.0, 10.0],
	},
	WeaponId.SPIRAL_STREAM: {
		"name": "Weapon 3",
		"fire_mode": "spiral_stream",
		"damage": 1,
		"shot_speed": 250.0,
		"shot_count": 4,
		"angle_step": 0.45,
		"phase_step": 0.35,
	},
}

const POWERUP_DEFINITIONS := {
	PowerupId.WEAPON_1: {
		"name": "Weapon 1",
		"description": "AOE pulse around the player",
		"kind": "weapon",
		"weapon_id": WeaponId.AOE_PULSE,
	},
	PowerupId.WEAPON_2: {
		"name": "Weapon 2",
		"description": "Vertical bullet jet",
		"kind": "weapon",
		"weapon_id": WeaponId.VERTICAL_JET,
	},
	PowerupId.WEAPON_3: {
		"name": "Weapon 3",
		"description": "Rotating bullet spiral",
		"kind": "weapon",
		"weapon_id": WeaponId.SPIRAL_STREAM,
	},
	PowerupId.SPEEDUP: {
		"name": "Speedup",
		"description": "Increase movement speed",
		"kind": "speed",
		"value": 30.0,
	},
	PowerupId.SHIELD: {
		"name": "Shield",
		"description": "Gain an extra life",
		"kind": "shield",
		"value": 1,
	},
}

const POWERUP_ORDER: Array[int] = [
	PowerupId.WEAPON_1,
	PowerupId.WEAPON_2,
	PowerupId.WEAPON_3,
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
