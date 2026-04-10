extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")

func get_lines():
	return [
		# ─────────────────────────────
		# INTRO
		# ─────────────────────────────
		{
			"id": "intro_1",
			"speaker": "",
			"text": "Wrocław. Lata 90.\nMiasto żyje. Miasto zarabia. Miasto... należy do nich."
		},
		{
			"id": "intro_2",
			"speaker": "",
			"text": "Corp O’Szczur.\nOficjalnie - deratyzacja.\nNieoficjalnie - kontrola wszystkiego, co pełza w cieniu."
		},
		{
			"id": "intro_3",
			"speaker": "",
			"text": "Szymon Czurewski. Pracownik miesiąca.\n11 razy z rzędu."
		},
		{
			"id": "intro_4",
			"speaker": "",
			"text": "Aż zobaczył coś, czego nie powinien...\nTeraz to on jest problemem do usunięcia."
		},

		# ─────────────────────────────
		# SCENA VN 0.1
		# ─────────────────────────────
		{
			"id": "vn_01_1",
			"speaker": "Szymon",
			"text": "No i super. 11 lat lojalności i nawet kosza prezentowego nie dali.",
			"portrait": szymon_base
		},
		{
			"id": "vn_01_2",
			"speaker": "System",
			"text": "(telefon dzwoni)"
		},
		{
			"id": "vn_01_3",
			"speaker": "Gosia",
			"text": "Jeśli jeszcze jesteś cały, to nie wychodź na ulicę. Oni już wiedzą.",
			"portrait": gosia_base
		},
		{
			"id": "vn_01_4",
			"speaker": "Szymon",
			"text": "Kim ty-",
			"portrait": szymon_base
		},
		{
			"id": "vn_01_5",
			"speaker": "Gosia",
			"text": "Kanały. Wejście przy rynku. Tam masz szansę. Najciemniej pod latarnią.",
			"portrait": gosia_base
		},
		{
			"id": "vn_01_6",
			"speaker": "System",
			"text": "(klik. cisza.)"
		},
		{
			"id": "vn_01_7",
			"speaker": "Szymon",
			"text": "No dobra… to będzie jeden z tych dni.\nNo to mamy kurczę kompot.",
			"portrait": szymon_base
		},

		# ─────────────────────────────
		# TUTORIAL GAMEPLAY INTRO
		# ─────────────────────────────
		{
			"id": "tutorial_1",
			"speaker": "Gosia",
			"text": "Steruj przyciskami WASD na klawiaturze i odeprzyj ich!",
			"portrait": gosia_base
		},
		{
			"id": "tutorial_2",
			"speaker": "Szymon",
			"text": "Muszę przedrzeć się przez ten tłum.",
			"portrait": szymon_base
		},
		{
			"id": "tutorial_3",
			"speaker": "Szymon",
			"text": "Jeśli ogarnę to szybko, to może zdążę jeszcze na kebaba po drodze do kanałów.",
			"portrait": szymon_base
		},
		{
			"id": "tutorial_4",
			"speaker": "Szymon",
			"text": "Nie przyciągać uwagi… nie przyciągać… uwagi…",
			"portrait": szymon_base
		},
		{
			"id": "tutorial_5",
			"speaker": "Szymon",
			"text": "Gdybym tylko nie pojawił się w złym miejscu o złym czasie…\nno ale… co się zobaczyło, to się nie odzobaczy.",
			"portrait": szymon_base
		},
		{
			"id": "tutorial_6",
			"speaker": "Gosia",
			"text": "Pamiętaj, że w każdym momencie możesz użyć ESC, żeby zatrzymać grę i przypomnieć sobie sterowanie.",
			"portrait": gosia_base
		}
	]
