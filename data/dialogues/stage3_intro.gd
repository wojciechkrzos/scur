extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")

func get_lines():
	return [
		{
			"id": "s3_i_1",
			"speaker": "",
			"text": "Hala Stulecia.\nWrocław, rok 1913.\nZbudowana żeby trwać wiecznie."
		},
		{
			"id": "s3_i_2",
			"speaker": "",
			"text": "Trwa."
		},
		{
			"id": "s3_i_3",
			"speaker": "",
			"text": "Tylko że teraz pod jej fundamentami bije inne serce."
		},
		{
			"id": "s3_i_4",
			"speaker": "Szymon",
			"text": "No to jesteśmy w tym muzeum grozy.",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_5",
			"speaker": "Gosia",
			"text": "Szymon. Muszę ci coś powiedzieć.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_6",
			"speaker": "Szymon",
			"text": "Teraz?",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_7",
			"speaker": "Gosia",
			"text": "Zanim wejdziesz głębiej. Tak.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_8",
			"speaker": "Gosia",
			"text": "Marek Olejnik. Skąd go znasz?",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_9",
			"speaker": "Szymon",
			"text": "Pracowaliśmy razem. Cztery lata. Zniknął.",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_10",
			"speaker": "Gosia",
			"text": "Bo to mój brat.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_11",
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_12",
			"speaker": "Gosia",
			"text": "Dlatego cię sprowadziłam. Od początku.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_13",
			"speaker": "Szymon",
			"text": "Mogłaś powiedzieć.",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_14",
			"speaker": "Gosia",
			"text": "Gdybym powiedziała, szukałbyś jego. Nie prawdy.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_15",
			"speaker": "Gosia",
			"text": "Na górze jest ktoś. Matka. Corp O'Szczur. Projekt Kret. Wszystko.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_16",
			"speaker": "Szymon",
			"text": "Na górze?",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_17",
			"speaker": "Gosia",
			"text": "Nie wiemy kim jest. Ale steruje wszystkim.",
			"portrait": gosia_base
		},
		{
			"id": "s3_i_18",
			"speaker": "Szymon",
			"text": "Dobra.",
			"portrait": szymon_base
		},
		{
			"id": "s3_i_19",
			"speaker": "Szymon",
			"text": "To idziemy.",
			"portrait": szymon_base,
			"end_dialogue": true
		},
	]