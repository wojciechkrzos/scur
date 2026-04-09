extends RefCounted

enum PowerupId {
	WEAPON_1,
	WEAPON_2,
	WEAPON_3,
	SPEEDUP,
	SHIELD,
}

const POWERUP_ORDER: Array[int] = [
	PowerupId.WEAPON_1,
	PowerupId.WEAPON_2,
	PowerupId.WEAPON_3,
	PowerupId.SPEEDUP,
	PowerupId.SHIELD,
]

static func get_powerup_name(powerup_id: int) -> String:
	match powerup_id:
		PowerupId.WEAPON_1:
			return "Weapon 1"
		PowerupId.WEAPON_2:
			return "Weapon 2"
		PowerupId.WEAPON_3:
			return "Weapon 3"
		PowerupId.SPEEDUP:
			return "Speedup"
		PowerupId.SHIELD:
			return "Shield"
		_:
			return "Unknown"

static func get_powerup_description(powerup_id: int) -> String:
	match powerup_id:
		PowerupId.WEAPON_1:
			return "AOE pulse around the player"
		PowerupId.WEAPON_2:
			return "Vertical bullet jet"
		PowerupId.WEAPON_3:
			return "Rotating bullet spiral"
		PowerupId.SPEEDUP:
			return "Increase movement speed"
		PowerupId.SHIELD:
			return "Gain an extra life"
		_:
			return ""

static func get_random_choices(count: int, excluded: Array[int] = []) -> Array[int]:
	var options := POWERUP_ORDER.duplicate()
	var fallback: Array[int] = []
	for powerup_id in options:
		if excluded.has(powerup_id):
			fallback.append(powerup_id)
		else:
			fallback.append(powerup_id)

	options = options.filter(func(powerup_id): return not excluded.has(powerup_id))
	options.shuffle()
	var picks: Array[int] = options.slice(0, min(count, options.size()))
	if picks.size() < count:
		fallback.shuffle()
		for powerup_id in fallback:
			if picks.size() >= count:
				break
			if not picks.has(powerup_id):
				picks.append(powerup_id)
	return picks
