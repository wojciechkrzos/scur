extends Node2D

@export var debug_mode: String = "vn"  # "vn" albo "boss"

@onready var dialogue_box = $DialogueBox

#loader dialogow
func load_dialogue(id: String):
	match id:
		"test":
			return preload("res://data/dialogues/test.gd").new().get_lines()
	
	return []


#METODY DO VN
func start_vn(id: String):
	var data = load_dialogue(id)

	# 👇 NAJPIERW disconnect
	if dialogue_box.dialogue_finished.is_connected(_on_vn_finished):
		dialogue_box.dialogue_finished.disconnect(_on_vn_finished)

	dialogue_box.start_dialogue(data)
	dialogue_box.dialogue_finished.connect(_on_vn_finished)
	
func _on_vn_finished(result):
	print("VN finished, choice:", result.get("choice", ""))

	start_boss_test("B")


#METODY DO BOSSA

func _on_boss_finished(result):
	print("Boss ended:", result)
	
func start_boss_test(which: String = "A"):
	var boss_scene = preload("res://bullet_hell/scenes/BossFight.tscn")
	var boss = boss_scene.instantiate()

	add_child(boss)

	boss.fight_ended.connect(_on_boss_finished)

	match which:
		"A":
			boss.start_fight(boss.BOSS_A)
		"B":
			boss.start_fight(boss.BOSS_B)


#na przyszlosc
#stages = [
	#{"type": "vn", "id": "test"},
	#{"type": "boss", "id": "B"}
#]


func _ready() -> void:
	print("MAIN READY")
	print(dialogue_box)

	match debug_mode:
		"vn":
			start_vn("test")
		"boss":
			start_boss_test("B")
