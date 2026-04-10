extends Resource

const boss1_base = preload("res://assets/portraits/boss1_base.png")
const szymon_base = preload("res://assets/portraits/szymon_base.png")

func get_lines():
	return [
		{
			"id": "boss_1",
			"speaker": "B.O.S.S.",
			"text": "Szymon… lojalny pracownik. A jednak taka zdrada. Szkoda.",
			"portrait": boss1_base
		},
		{
			"id": "boss_2",
			"speaker": "Szymon",
			"text": "HR mnie zwolniło. Ty mnie chcesz zabić. Trochę overkill.",
			"portrait": szymon_base
		},
		{
			"id": "boss_3",
			"speaker": "B.O.S.S.",
			"text": "To tylko biznes.",
			"effect": "shake",
			"portrait": boss1_base
		}
	]
