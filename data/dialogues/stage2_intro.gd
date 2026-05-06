extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")

func get_lines():
	return [
		# ─────────────────────────────
		# NARRATOR
		# ─────────────────────────────
		{
			"id": "s2_intro_1",
			"speaker": "",
			"text": "Kanały Wrocławia. Miasto pod miastem — sieć tuneli starsza niż połowa ulic, zbudowana przez tych, których nikt nie pamiętał z imienia."
		},
		{
			"id": "s2_intro_2",
			"speaker": "",
			"text": "Corp O'Szczur jej nie budował. Odziedziczył ją. Wzmocnił. Każdy kanał, każde przejście, każdy zawór — teraz w systemie."
		},
		{
			"id": "s2_intro_3",
			"speaker": "",
			"text": "Szymon idzie w dół. Dosłownie i w przenośni."
		},

		# ─────────────────────────────
		# SCENA VN 2.1
		# ─────────────────────────────
		{
			"id": "s2_intro_4",
			"speaker": "Gosia",
			"text": "Szymon. Masz mnie?",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_5",
			"speaker": "Szymon",
			"text": "Mam. Powiedz mi kim jesteś, bo zaczynam mieć wrażenie że rozmawiam z dobrze poinformowanym duchem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_6",
			"speaker": "Gosia",
			"text": "Duchem? Nie. Chociaż Corp O'Szczur próbował. Pracowałam dla nich — Dział Analityki. Cztery lata, teczka na każdego, dostęp do rzeczy, których nie powinnam widzieć.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_7",
			"speaker": "Szymon",
			"text": "I co zrobiłaś z tym dostępem?",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_8",
			"speaker": "Gosia",
			"text": "Wyszłam. Zabrałam kopie. I zaczęłam szukać.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_9",
			"speaker": "Szymon",
			"text": "Czego?",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_10",
			"speaker": "Gosia",
			"text": "Kogoś. To nie jest teraz ważne.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_11",
			"speaker": "Szymon",
			"text": "To znaczy, że jest ważne.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_12",
			"speaker": "Gosia",
			"text": "To znaczy, że nie mamy czasu. Słuchaj — Bóbrmistrz. Stary. Brutalny. I — co ważne — on zbudował to co teraz pod tobą stoi. Projekt Kret. Sieć nadzoru. Był przy tym od początku.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_13",
			"speaker": "Szymon",
			"text": "Skąd wiesz że tam jest?",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_14",
			"speaker": "Gosia",
			"text": "Bo mam jego akta. I akta jego systemu. I kilka innych rzeczy, które Corp O'Szczur bardzo chciałby odzyskać.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_15",
			"speaker": "Szymon",
			"text": "Czyli pomagasz mi, bo potrzebujesz kogoś kto zejdzie na dół i zrobi robotę.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_16",
			"speaker": "Gosia",
			"text": "Pomagam ci, bo chcę żeby Corp O'Szczur skończyło się z hukiem, a nie z ugodą i odprawą. Ale tak — robota też.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_17",
			"speaker": "Szymon",
			"text": "Przynajmniej jesteś szczera.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_18",
			"speaker": "Gosia",
			"text": "Jeden z nas musi być.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_19",
			"speaker": "Gosia",
			"text": "Uwaga — kanały mają uszy. Dosłownie. Słuchowe czujniki w rurach, projekt Bóbrmistrza jeszcze z lat osiemdziesiątych. On już wie że idziesz.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_20",
			"speaker": "Szymon",
			"text": "Stary i paranoiczny. Najgorszy rodzaj.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_21",
			"speaker": "Gosia",
			"text": "Szymon. On wie co stało się z Markiem. To pewne.",
			"portrait": gosia_base
		},
		{
			"id": "s2_intro_22",
			"speaker": "Szymon",
			"text": "...to wystarczy.",
			"portrait": szymon_base
		},
		{
			"id": "s2_intro_23",
			"speaker": "Gosia",
			"text": "Musi wystarczyć.",
			"portrait": gosia_base,
			"end_dialogue": true
		}
	]