extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
const matka_base = preload("res://assets/portraits/boss3_base.png")

func get_lines(choice_id: String = ""):
	if choice_id == "choice_s3_destroy":
		return _destroy_path()
	elif choice_id == "choice_s3_take":
		return _take_path()
	else:
		return _destroy_path()


# ─────────────────────────────
# PATH A: DESTROY
# ─────────────────────────────
func _destroy_path() -> Array:
	return [
		{
			"id": "s3_d_1",
			"speaker": "Matka",
			"text": "Zniszczyć. Klasyka.",
			"portrait": matka_base
		},
		{
			"id": "s3_d_2",
			"speaker": "Szymon",
			"text": "Koniec systemu.",
			"portrait": szymon_base
		},
		{
			"id": "s3_d_3",
			"speaker": "Matka",
			"text": "A potem co?",
			"portrait": matka_base
		},
		{
			"id": "s3_d_4",
			"speaker": "Szymon",
			"text": "Wrocław sobie poradzi.",
			"portrait": szymon_base
		},
		{
			"id": "s3_d_5",
			"speaker": "Matka",
			"text": "Zawsze ktoś go zastępuje.",
			"portrait": matka_base
		},
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
func _take_path() -> Array:
	return [
		{
			"id": "s3_t_1",
			"speaker": "Matka",
			"text": "Przejąć. Też klasyka.",
			"portrait": matka_base
		},
		{
			"id": "s3_t_2",
			"speaker": "Szymon",
			"text": "Znam system.",
			"portrait": szymon_base
		},
		{
			"id": "s3_t_3",
			"speaker": "Matka",
			"text": "Wszyscy znają. Dopóki nie siądą na miejscu.",
			"portrait": matka_base
		},
		{
			"id": "s3_t_4",
			"speaker": "Gosia",
			"text": "Szymon...",
			"portrait": gosia_base
		},
		{
			"id": "s3_t_5",
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": szymon_base
		},
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