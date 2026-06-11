extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
const matka_base = preload("res://assets/portraits/boss3_base.png")

func get_lines(choice_id: String = ""):
	match choice_id:
		"choice_stage3_a":
			return _path_a()

		"choice_stage3_b":
			return _path_b()

		_:
			return _path_a()


# ─────────────────────────────
# PATH A: DESTROY
# ─────────────────────────────
func _path_a() -> Array:
	return [
		{
			"id": "s3_d_6",
			"speaker": "",
			"text": "System zaczyna się zapadać.",
			"portrait": null
		},
		{
			"id": "s3_d_7",
			"speaker": "Gosia",
			"text": "Słyszę cię. Węzeł się sypie.",
			"portrait": gosia_base
		},
		{
			"id": "s3_d_8",
			"speaker": "Szymon",
			"text": "Idziemy stąd.",
			"portrait": szymon_base,
			"end_dialogue": true
		},
	]


# ─────────────────────────────
# PATH B: TAKE
# ─────────────────────────────
func _path_b() -> Array:
	return [
		{
			"id": "s3_t_6",
			"speaker": "Matka",
			"text": "I co teraz?",
			"portrait": matka_base
		},
		{
			"id": "s3_t_7",
			"speaker": "Szymon",
			"text": "Jeszcze nie wiem.",
			"portrait": szymon_base
		},
		{
			"id": "s3_t_8",
			"speaker": "",
			"text": "System nie znika. Zmienia właściciela.",
			"portrait": null
		},
		{
			"id": "s3_t_9",
			"speaker": "Gosia",
			"text": "Słyszę cię.",
			"portrait": gosia_base
		},
		{
			"id": "s3_t_10",
			"speaker": "Szymon",
			"text": "Idziemy dalej.",
			"portrait": szymon_base,
			"end_dialogue": true
		},
	]
