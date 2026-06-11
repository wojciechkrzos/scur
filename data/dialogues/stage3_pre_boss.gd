extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
const matka_base = preload("res://assets/portraits/boss3_base.png")

func get_lines():
	return [
		{
			"id": "s3_p_1",
			"speaker": "Matka",
			"text": "Szymon Czurewski. Pracownik miesiąca. Jedenaście razy z rzędu.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_2",
			"speaker": "Szymon",
			"text": "Dwunasty miesiąc nie wyszedł.",
			"portrait": szymon_base
		},
		{
			"id": "s3_p_3",
			"speaker": "Matka",
			"text": "Wyszedł. Tylko zmieniliśmy kategorię.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_4",
			"speaker": "Matka",
			"text": "Zrobiliśmy z ciebie projekt.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_5",
			"speaker": "Szymon",
			"text": "Nie jestem projektem.",
			"portrait": szymon_base
		},
		{
			"id": "s3_p_6",
			"speaker": "Matka",
			"text": "Każdy tak mówi.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_7",
			"speaker": "Matka",
			"text": "Marek zrozumiał.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_8",
			"speaker": "Szymon",
			"text": "Co mu zrobiłaś.",
			"portrait": szymon_base
		},
		{
			"id": "s3_p_9",
			"speaker": "Matka",
			"text": "To nie była przemoc. To była rozmowa.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_10",
			"speaker": "Matka",
			"text": "Mam czas. Mogę przekonać i ciebie.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_11",
			"speaker": "Szymon",
			"text": "Nie masz.",
			"portrait": szymon_base
		},
		{
			"id": "s3_p_12",
			"speaker": "Matka",
			"text": "Oczywiście że mam.",
			"portrait": matka_base
		},
		{
			"id": "s3_p_13",
			"speaker": "Szymon",
			"text": "Bo za chwilę cię pokonam.",
			"portrait": szymon_base
		},
		{
			"id": "s3_p_14",
			"speaker": "Matka",
			"text": "Jeszcze nie wiesz czy chcesz zniszczyć czy przejąć.",
			"portrait": matka_base,
			"choices": [
				{
					"id": "choice_stage3_a",
					"text": "Zniszczę to wszystko.",
					"jump_to": "s3_destroy_1"
				},
				{
					"id": "choice_stage3_b",
					"text": "Przejmę to.",
					"jump_to": "s3_take_1"
				}
			]
		},
        		{
			"id": "s3_destroy_1",
			"speaker": "Matka",
			"text": "Zniszczyć. Klasyczny odruch.",
			"portrait": matka_base
		},
		{
			"id": "s3_destroy_2",
			"speaker": "Matka",
			"text": "A co potem? Kto wypełni pustkę?",
			"portrait": matka_base
		},
		{
			"id": "s3_destroy_3",
			"speaker": "Szymon",
			"text": "Wrocław sobie poradzi.",
			"portrait": szymon_base
		},
		{
			"id": "s3_destroy_4",
			"speaker": "Matka",
			"text": "Zawsze ktoś wypełniał pustkę.",
			"portrait": matka_base
		},

		{
			"id": "s3_take_1",
			"speaker": "Matka",
			"text": "Przejąć. Klasyczny odruch.",
			"portrait": matka_base
		},
		{
			"id": "s3_take_2",
			"speaker": "Szymon",
			"text": "Znam system od środka.",
			"portrait": szymon_base
		},
		{
			"id": "s3_take_3",
			"speaker": "Matka",
			"text": "Każdy tak mówił.",
			"portrait": matka_base
		},
		{
			"id": "s3_take_4",
			"speaker": "Matka",
			"text": "Ale ty jeszcze nie usiadłeś na fotelu.",
			"portrait": matka_base
		},
		{
			"id": "s3_take_5",
			"speaker": "Matka",
			"text": "A chcesz.",
			"portrait": matka_base
		},
		{
			"id": "s3_take_6",
			"speaker": "Gosia",
			"text": "Szymon…",
			"portrait": gosia_base
		},
		{
			"id": "s3_take_7",
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": szymon_base
		}
	]