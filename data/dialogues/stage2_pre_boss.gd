extends Resource

const marek_base = preload("res://assets/portraits/marek_base.png")
const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
const boss2_base = preload("res://assets/portraits/boss2_base.png")


func get_lines():
	# Stage 2 nie rozgałęzia już głównego flow — tylko logika wyboru w jednym drzewie
	return [
		# ─────────────────────────────
		# INTRO / WEJŚCIE DO KANAŁÓW (UNIFIED)
		# ─────────────────────────────
		{
			"id": 0,
			"speaker": "",
			"text": "Szymon dociera do centralnej komory kanałów. Nad czarną wodą wisi platforma. Na niej stoi Bóbrmistrz. Za nim neon: 'SZCZURZA MAFIA - WROCŁAW OD 1987'."
		},
				{
			"id": 1,
			"speaker": "Bóbrmistrz",
			"text": "No, no. Czurewski. Żyjesz. Myślałem że B.O.S.S. cię przetworzy.",
			"portrait": boss2_base
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Miał za dużo do powiedzenia. Pogadaliśmy.",
			"portrait": szymon_base
		},
		{
			"id": 3,
			"speaker": "Bóbrmistrz",
			"text": "Gadatliwy był zawsze. Korporacyjny szczur do szpiku kości.",
			"portrait": boss2_base
		},
		{
			"id": 4,
			"speaker": "Szymon",
			"text": "A ty?",
			"portrait": szymon_base
		},
		{
			"id": 5,
			"speaker": "Bóbrmistrz",
			"text": "Ja jestem inny rodzaj szczura. Zbudowałem to. Własnoręcznie. Zanim Corp O'Szczur stał się korporacją — był projekt. I ja byłem tym projektem.",
			"portrait": boss2_base
		},
		{
			"id": 6,
			"speaker": "Bóbrmistrz",
			"text": "Ale... czy jestem z tego dumny? Hm... Jestem zmęczony. Różnica jest spora.",
			"portrait": boss2_base
		},

		# ─────────────────────────────
		# MARK REVEAL (UNIFIED)
		# ─────────────────────────────
		{
			"id": 7,
			"speaker": "Szymon",
			"text": "Marek Olejnik. Gdzie jest.",
			"portrait": szymon_base
		},
		{
			"id": 8,
			"speaker": "Bóbrmistrz",
			"text": "...",
			"portrait": boss2_base
		},
		{
			"id": 9,
			"speaker": "Bóbrmistrz",
			"text": "Skąd znasz to nazwisko?",
			"portrait": boss2_base
		},
		{
			"id": 10,
			"speaker": "Szymon",
			"text": "To mój kolega. Zaginął dwa lata temu.",
			"portrait": szymon_base
		},
		{
			"id": 11,
			"speaker": "Bóbrmistrz",
			"text": "Nie zaginął.",
			"portrait": boss2_base
		},
		{
			"id": 12,
			"speaker": "",
			"text": "Za Bóbrmistrzem, w ścianie tunelu, tkwi Marek. Podłączony kablami. Oczy otwarte. Uśmiecha się."
		},
		{
			"id": 13,
			"speaker": "Marek",
			"text": "Cześć, Szymon.",
			"portrait": marek_base
		},
		{
			"id": 14,
			"speaker": "Szymon",
			"text": "...Marek.",
			"portrait": szymon_base
		},
		{
			"id": 15,
			"speaker": "Marek",
			"text": "Długo cię nie było.",
			"portrait": marek_base
		},
		{
			"id": 16,
			"speaker": "Szymon",
			"text": "Co z tobą zrobili?",
			"portrait": szymon_base
		},
		{
			"id": 17,
			"speaker": "Marek",
			"text": "Nic złego. Jest spokojnie. Ciągle.",
			"portrait": marek_base
		},

		# ─────────────────────────────
		# CORE EXPLANATION (UNIFIED)
		# ─────────────────────────────
		{
			"id": 18,
			"speaker": "Bóbrmistrz",
			"text": "Projekt Kret. Interfejs biologiczny. Marek nie jest więźniem. Jest węzłem.",
			"portrait": boss2_base
		},
		{
			"id": 19,
			"speaker": "Marek",
			"text": "Czuję każdy tunel. Każdy węzeł. Jak oddychanie.",
			"portrait": marek_base
		},
		{
			"id": 20,
			"speaker": "Marek",
			"text": "Jeśli mnie odłączysz... uruchomi się procedura awaryjna.",
			"portrait": marek_base
		},
		{
			"id": 21,
			"speaker": "Szymon",
			"text": "Co to znaczy?",
			"portrait": szymon_base
		},
		{
			"id": 22,
			"speaker": "Marek",
			"text": "Zawalenia. Eksplozje. Zalania. Pół Wrocławia pod ziemią.",
			"portrait": marek_base
		},
		{
			"id": 23,
			"speaker": "Szymon",
			"text": "Kłamiesz.",
			"portrait": szymon_base
		},
		{
			"id": 24,
			"speaker": "Marek",
			"text": "Może. Nie pamiętam już co to kłamstwo.",
			"portrait": marek_base
		},

		# ─────────────────────────────
		# FINAL PRE-BOSS CHOICE (UNIFIED)
		# ─────────────────────────────
		{
			"id": 25,
			"speaker": "Bóbrmistrz",
			"text": "Dead man's switch. Najlepszy wynalazek Corp O'Szczur.",
			"portrait": boss2_base
		},
		{
			"id": 26,
			"speaker": "Bóbrmistrz",
			"text": "Nie pilnujesz więźnia. Więzień pilnuje miasta.",
			"portrait": boss2_base
		},
		{
			"id": 27,
			"speaker": "Szymon",
			"text": "A ty? Co z tego masz?",
			"portrait": szymon_base
		},
		{
			"id": 28,
			"speaker": "Bóbrmistrz",
			"text": "Spokój. Kanały działają. Miasto nie wie. Wszyscy żyją.",
			"portrait": boss2_base
		},
		{
			"id": 29,
			"speaker": "Bóbrmistrz",
			"text": "A teraz ty. Co robisz, Czurewski?",
			"portrait": boss2_base,
			"choices": [
				{
					"id": "choice_stage2_a",
					"text": "Wyrwę go. Nawet jeśli wszystko się zawali.",
					"jump_to": 30
				},
				{
					"id": "choice_stage2_b",
					"text": "Potrzebuję dostępu. Marek zostaje.",
					"jump_to": 40
				}
			]
		},

		# ─────────────────────────────
		# PATH A (SAVE / HEROIC)
		# ─────────────────────────────
		{
			"id": 30,
			"speaker": "Bóbrmistrz",
			"text": "Sentymentalny głupiec.",
			"portrait": boss2_base
		},
		{
			"id": 31,
			"speaker": "Marek",
			"text": "Szymon... nie musisz.",
			"portrait": marek_base
		},
		{
			"id": 32,
			"speaker": "Szymon",
			"text": "Zamknij się. Idę po ciebie.",
			"portrait": szymon_base
		},
		{
			"id": 33,
			"speaker": "Gosia",
			"text": "...dobrze.",
			"portrait": gosia_base
		},
		{
			"id": 34,
			"speaker": "Gosia",
			"text": "Pokonaj go.",
			"portrait": gosia_base,
			"end_dialogue": true
		},

		# ─────────────────────────────
		# PATH B (SYSTEM / COLD)
		# ─────────────────────────────
		{
			"id": 40,
			"speaker": "Bóbrmistrz",
			"text": "Ha. Wiedziałem.",
			"portrait": boss2_base
		},
		{
			"id": 41,
			"speaker": "Marek",
			"text": "Rozumiem. To rozsądne.",
			"portrait": marek_base
		},
		{
			"id": 42,
			"speaker": "Szymon",
			"text": "Przepraszam.",
			"portrait": szymon_base
		},
		{
			"id": 43,
			"speaker": "Marek",
			"text": "Nie ma za co.",
			"portrait": marek_base
		},
		{
			"id": 44,
			"speaker": "Gosia",
			"text": "...",
			"portrait": gosia_base
		},
		{
			"id": 45,
			"speaker": "",
			"text": "Jej głos nie niesie emocji. Jakby coś w niej się odłączyło.",
			"end_dialogue": true
		}
	]
