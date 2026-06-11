extends SceneTree

const BHPowerups = preload("res://bullet_heaven/scripts/BHPowerups.gd")
const BHPlayer = preload("res://bullet_heaven/scripts/BHPlayer.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_level_stats()
	_test_weapon_acquisition_and_cap()
	_test_choice_pool_excludes_maxed_weapon()
	if failures.is_empty():
		print("Bullet Heaven progression tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _test_level_stats() -> void:
	var pulse_level_five: Dictionary = BHPowerups.get_weapon_stats(BHPowerups.WeaponId.AOE_PULSE, 5)
	_expect(pulse_level_five.radius == 88.0, "Pulse level 5 radius should be 88")
	_expect(pulse_level_five.damage == 3, "Pulse level 5 damage should be 3")
	var molotov_level_four: Dictionary = BHPowerups.get_weapon_stats(BHPowerups.WeaponId.MOLOTOV_BOMB, 4)
	_expect(molotov_level_four.shot_count == 2, "Molotov level 4 should fire two bombs")

func _test_weapon_acquisition_and_cap() -> void:
	var player = BHPlayer.new()
	player.weapon_levels.clear()
	player.weapon_levels[BHPowerups.WeaponId.AOE_PULSE] = 1
	for _index in 7:
		player.apply_powerup(BHPowerups.PowerupId.WEAPON_1)
	_expect(player.get_weapon_level(BHPowerups.WeaponId.AOE_PULSE) == 5, "Weapon upgrades should cap at level 5")
	player.apply_powerup(BHPowerups.PowerupId.WEAPON_4)
	_expect(player.get_weapon_level(BHPowerups.WeaponId.HOMING_MISSILE) == 1, "New weapon should start at level 1")
	player.free()

func _test_choice_pool_excludes_maxed_weapon() -> void:
	var inventory := {BHPowerups.WeaponId.AOE_PULSE: 5}
	for _index in 20:
		var choices: Array[int] = BHPowerups.get_random_choices(8, inventory)
		_expect(not choices.has(BHPowerups.PowerupId.WEAPON_1), "Maxed weapon should not return to choice pool")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
