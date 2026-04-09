extends Resource

func get_lines():
	return [
		{
			"id": "intro_1",
			"speaker": "Narrator",
			"text": "Uciekasz przed korporacją.",
		},
		{
			"id": "intro_2",
			"speaker": "System",
			"text": "Nie masz dużo czasu.",
			"effect": "shake"
		},
		{
			"id": "intro_choice",
			"speaker": "???",
			"text": "Co robisz?",
			"choices": [
				{"id": "run", "text": "Uciekaj"},
				{"id": "hide", "text": "Ukryj się"}
			]
		}
	]
