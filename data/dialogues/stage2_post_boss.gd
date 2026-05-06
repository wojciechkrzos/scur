extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
#const bobr_base = preload("res://assets/portraits/bobr_base.png")
const bobr_base = null
#const marek_base = preload("res://assets/portraits/marek_glitch.png")
const marek_base = null


func get_lines(stage1_choice: String, stage2_choice: String):
	if stage1_choice == "choice_fight" and stage2_choice == "s2_save":
		return _AA()
	if stage1_choice == "choice_fight" and stage2_choice == "s2_understand":
		return _AB()
	if stage1_choice == "choice_join" and stage2_choice == "s2_save":
		return _BA()
	if stage1_choice == "choice_join" and stage2_choice == "s2_understand":
		return _BB()
	return _AA()  # fallback


# ─────────────────────────────
# WARIANT AA
# fight + save
# "walczyłem o Marka" + "wyciągnę go bez względu na cenę"
# ─────────────────────────────
func _AA() -> Array:
	return [
		{
			"id": "s2_AA_1",
			"speaker": "Bóbrmistrz",
			"text": "...lewa kieszeń. Klucz.",
			"portrait": bobr_base
		},
		{
			"id": "s2_AA_2",
			"speaker": "",
			"text": "(Szymon wyjmuje stary, podziurawiony chip. Idzie głębiej. Korytarz. Serwery. Ekrany pełne danych. I potem — głos. Ledwo słyszalny, przerywany szumem.)"
		},
		{
			"id": "s2_AA_3",
			"speaker": "Marek",
			"text": "...k...to tam?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AA_4",
			"speaker": "Szymon",
			"text": "Marek. To ja.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AA_5",
			"speaker": "Marek",
			"text": "Szymon... myślałem że to znowu... test. Oni robią testy. Żeby zobaczyć czy... czy coś jeszcze czuję.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AA_6",
			"speaker": "Szymon",
			"text": "To nie test. Jestem tu. Mam klucz.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AA_7",
			"speaker": "Marek",
			"text": "Nie odłączaj mnie tak po prostu. System jest... przywiązany. Do mnie, przeze mnie, nie wiem już...",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AA_8",
			"speaker": "Marek",
			"text": "Jak to odepniesz bez protokołu — nie wiem co się stanie.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AA_9",
			"speaker": "Szymon",
			"text": "Co się może stać?",
			"portrait": szymon_base
		},
		{
			"id": "s2_AA_10",
			"speaker": "Marek",
			"text": "Może nic. Może... wszystko. Może wreszcie... będę człowiekiem.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AA_11",
			"speaker": "Szymon",
			"text": "Ryzykujemy.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AA_12",
			"speaker": "Marek",
			"text": "Wiedziałem... że przyjdziesz. Przez cały czas... wiedziałem.",
			"portrait": marek_base,
			"effect": "shake",
			"end_dialogue": true
		}
	]


# ─────────────────────────────
# WARIANT AB
# fight + understand
# "walczyłem o Marka" + "chcę zniszczyć system — Marek jest kluczem"
# ─────────────────────────────
func _AB() -> Array:
	return [
		{
			"id": "s2_AB_1",
			"speaker": "Bóbrmistrz",
			"text": "...system ma zabezpieczenia. To nie jest tak proste jak wyciągnięcie wtyczki.",
			"portrait": bobr_base
		},
		{
			"id": "s2_AB_2",
			"speaker": "Szymon",
			"text": "Wiem. Gosia mi powiedziała.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AB_3",
			"speaker": "Bóbrmistrz",
			"text": "...Gosia. Ona wie więcej niż mówi. Bądź ostrożny.",
			"portrait": bobr_base
		},
		{
			"id": "s2_AB_4",
			"speaker": "",
			"text": "(Szymon idzie. Serwery. Ekrany. Dane. I potem — głos.)"
		},
		{
			"id": "s2_AB_5",
			"speaker": "Marek",
			"text": "...kto... to?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AB_6",
			"speaker": "Szymon",
			"text": "Szymon.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AB_7",
			"speaker": "Marek",
			"text": "Szymon Czurewski. Widzę twój... plik. Widzę wszystko co zrobiłeś.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AB_8",
			"speaker": "Marek",
			"text": "Widziałem rozmowę z B.O.S.S.-em. Pytania. Dobierasz się do systemu.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AB_9",
			"speaker": "Szymon",
			"text": "Chcę go zniszczyć.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AB_10",
			"speaker": "Marek",
			"text": "...jest tylko jedna droga żeby to zrobić naprawdę. I ona... przechodzi przeze mnie.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AB_11",
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AB_12",
			"speaker": "Marek",
			"text": "I wciąż chcesz?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_AB_13",
			"speaker": "Szymon",
			"text": "Jeszcze nie wiem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_AB_14",
			"speaker": "Marek",
			"text": "...przynajmniej... jesteś szczery.",
			"portrait": marek_base,
			"effect": "shake",
			"end_dialogue": true
		}
	]


# ─────────────────────────────
# WARIANT BA
# join + save
# "pytałem o kasę" + "wyciągnę go — cokolwiek to kosztuje"
# ─────────────────────────────
func _BA() -> Array:
	return [
		{
			"id": "s2_BA_1",
			"speaker": "Bóbrmistrz",
			"text": "...spodziewałem się że weźmiesz klucz i wyjdziesz.",
			"portrait": bobr_base
		},
		{
			"id": "s2_BA_2",
			"speaker": "Szymon",
			"text": "Jeszcze nie zdecydowałem co z nim zrobię.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BA_3",
			"speaker": "Bóbrmistrz",
			"text": "To właśnie twój problem, Czurewski. Ciągle nie decydujesz. Ale to chyba lepiej niż decydować za szybko.",
			"portrait": bobr_base
		},
		{
			"id": "s2_BA_4",
			"speaker": "",
			"text": "(Szymon idzie. Serwery. Ekrany. I potem — głos.)"
		},
		{
			"id": "s2_BA_5",
			"speaker": "Marek",
			"text": "...k...to?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_6",
			"speaker": "Szymon",
			"text": "Szymon.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BA_7",
			"speaker": "Marek",
			"text": "...Czurewski. Widzę twój plik. Widzę rozmowę z B.O.S.S.-em.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_8",
			"speaker": "Marek",
			"text": "Pytanie o kasę.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_9",
			"speaker": "Szymon",
			"text": "Marek...",
			"portrait": szymon_base
		},
		{
			"id": "s2_BA_10",
			"speaker": "Marek",
			"text": "Nie tłumacz się. Każdy... przeżywa jak może.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_11",
			"speaker": "Marek",
			"text": "Po co tu jesteś?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_12",
			"speaker": "Szymon",
			"text": "Po ciebie.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BA_13",
			"speaker": "Marek",
			"text": "...nie wiem czy... ci wierzę.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BA_14",
			"speaker": "Marek",
			"text": "Ale chyba... chcę.",
			"portrait": marek_base,
			"effect": "shake",
			"end_dialogue": true
		}
	]


# ─────────────────────────────
# WARIANT BB
# join + understand
# "pytałem o kasę" + "to zależy co tam znajdę"
# ─────────────────────────────
func _BB() -> Array:
	return [
		{
			"id": "s2_BB_1",
			"speaker": "Bóbrmistrz",
			"text": "...widzę cię, Czurewski. Już nie wiesz po której stronie stoisz.",
			"portrait": bobr_base
		},
		{
			"id": "s2_BB_2",
			"speaker": "Szymon",
			"text": "Może nigdy nie wiedziałem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BB_3",
			"speaker": "Bóbrmistrz",
			"text": "Uczciwa odpowiedź. Klucz jest w lewej kieszeni. I pamiętaj — system pamięta każdego, kto go dotknął. Łącznie z tobą.",
			"portrait": bobr_base
		},
		{
			"id": "s2_BB_4",
			"speaker": "",
			"text": "(Szymon idzie. Serwery. Ekrany. I potem — głos. Chłodniejszy niż się spodziewał.)"
		},
		{
			"id": "s2_BB_5",
			"speaker": "Marek",
			"text": "...kto tam?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BB_6",
			"speaker": "Szymon",
			"text": "Szymon.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BB_7",
			"speaker": "Marek",
			"text": "Czurewski. Widzę plik. Widzę rozmowę z B.O.S.S.-em.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BB_8",
			"speaker": "Marek",
			"text": "Po co tu jesteś?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BB_9",
			"speaker": "Szymon",
			"text": "Chcę wiedzieć jak to wszystko działa.",
			"portrait": szymon_base
		},
		{
			"id": "s2_BB_10",
			"speaker": "Marek",
			"text": "Bo chcesz to zniszczyć... czy przejąć?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_BB_11",
			"speaker": "Szymon",
			"text": "...jest różnica?",
			"portrait": szymon_base
		},
		{
			"id": "s2_BB_12",
			"speaker": "Marek",
			"text": "Jest. Ogromna. I myślę... że wiesz która.",
			"portrait": marek_base,
			"effect": "shake",
			"end_dialogue": true
		}
	]