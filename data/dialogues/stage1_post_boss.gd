extends Resource
const boss1_base = preload("res://assets/portraits/boss1_base.png")
const szymon_base = preload("res://assets/portraits/szymon_base.png")

func get_lines(choice_id: String = ""):
	if choice_id == "choice_fight":
		return _path_fight()
	elif choice_id == "choice_join":
		return _path_join()
	else:
		return _path_fight()  # fallback

func _path_fight() -> Array:
	return [
		{
			"id": 0,
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": 1,
			"speaker": "Szymon",
			"text": "Marek. Żyje. To wystarczy.",
			"portrait": szymon_base
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Corp O'Szczur stoi. Na razie. Ale już wiem gdzie szukać.",
			"portrait": szymon_base,
			"end_dialogue": true
		},
	]

func _path_join() -> Array:
	return [
		{
			"id": 0,
			"speaker": "Szymon",
			"text": "Leży na bruku rynku. Wielki. Pokonany.",
			"portrait": szymon_base
		},
		{
			"id": 1,
			"speaker": "Szymon",
			"text": "Fotel nadal czeka. I wiem o tym.",
			"portrait": szymon_base
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Pytanie tylko — czy to jeszcze zemsta, czy już kariera?",
			"portrait": szymon_base,
			"end_dialogue": true
		},
	]
