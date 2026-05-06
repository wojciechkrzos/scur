extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
#const bobr_base = preload("res://assets/portraits/bobr_base.png")
const bobr_base = null

func get_lines(stage1_choice: String = ""):
	if stage1_choice == "choice_fight":
		return _fight_path()
	elif stage1_choice == "choice_join":
		return _join_path()
	return _fight_path()  # fallback


# ─────────────────────────────
# FIGHT PATH (stage1 = choice_fight)
# Szymon walczył o Marka — jest na ścieżce sprawiedliwości
# ─────────────────────────────
func _fight_path() -> Array:
	return [
		{
			"id": "s2_f_1",
			"speaker": "Bóbrmistrz",
			"text": "No, no. Czurewski. Żyjesz. Myślałem że B.O.S.S. cię przetworzy.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_2",
			"speaker": "Szymon",
			"text": "Miał za dużo do powiedzenia. Pogadaliśmy.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_3",
			"speaker": "Bóbrmistrz",
			"text": "Gadatliwy był zawsze. Korporacyjny szczur do szpiku kości.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_4",
			"speaker": "Szymon",
			"text": "A ty?",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_5",
			"speaker": "Bóbrmistrz",
			"text": "Ja jestem inny rodzaj szczura. Zbudowałem to. Własnoręcznie. Zanim Corp O'Szczur stał się korporacją — był projekt. I ja byłem tym projektem.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_6",
			"speaker": "Szymon",
			"text": "I co — jesteś z tego dumny?",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_7",
			"speaker": "Bóbrmistrz",
			"text": "Dumny? Jestem zmęczony. Różnica jest spora.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_8",
			"speaker": "Bóbrmistrz",
			"text": "Szukasz Marka.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_9",
			"speaker": "Szymon",
			"text": "Tak.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_10",
			"speaker": "Bóbrmistrz",
			"text": "Znalazłeś go. Tyle że nie w sposób w jaki sobie wyobrażałeś. Projekt Kret. Sieć nadzoru pod całym miastem. Marek jest w środku. Dosłownie.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_11",
			"speaker": "Szymon",
			"text": "Co to znaczy dosłownie.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_12",
			"speaker": "Bóbrmistrz",
			"text": "Corp O'Szczur zrobił z niego węzeł. Jego pamięć, kontakty, wiedza o systemie — zintegrowane. Żyje. Ale odepnij go bez protokołu — a może zabijesz jego, może system, może jedno i drugie.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_13",
			"speaker": "Szymon",
			"text": "Dlaczego mi to mówisz?",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_14",
			"speaker": "Bóbrmistrz",
			"text": "Bo jestem stary. Bo mam dość. I bo jeśli ktoś ma szansę to skończyć — powinien wiedzieć w co wchodzi.",
			"portrait": bobr_base
		},
		# ── DEAD MAN'S SWITCH REVEAL ──────────────────────────────────────────
		{
			"id": "s2_f_15",
			"speaker": "Bóbrmistrz",
			"text": "Widzisz tę mapę?",
			"portrait": bobr_base,
			"effect": "point_at_map"
		},
		{
			"id": "s2_f_16",
			"speaker": "Bóbrmistrz",
			"text": "Myślałeś że to węzły sieci. To nie węzły.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_17",
			"speaker": "Bóbrmistrz",
			"text": "Jak Marek przestaje — zegary pod miastem zaczynają liczyć. Wrocław ma wtedy może cztery minuty. Może pięć. Zależy od wilgotności.",
			"portrait": bobr_base,
			"effect": "shake"
		},
		{
			"id": "s2_f_18",
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_19",
			"speaker": "Szymon",
			"text": "Corp O'Szczur podłożyło materiały wybuchowe pod całe miasto.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_20",
			"speaker": "Bóbrmistrz",
			"text": "Nie podłożyło. Ja podłożyłem. Na ich zlecenie. Dwadzieścia lat temu.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_21",
			"speaker": "Szymon",
			"text": "I teraz mi o tym mówisz.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_22",
			"speaker": "Bóbrmistrz",
			"text": "Teraz ci o tym mówię. Mam klucz dostępowy do węzła Marka. Nie oddam go za darmo. Przekonaj mnie że warto.",
			"portrait": bobr_base,
			"choices": [
				{
					"id": "s2_save",
					"text": "Marek jest moim przyjacielem. To mi wystarczy.",
					"jump_to": "s2_f_save_1"
				},
				{
					"id": "s2_understand",
					"text": "Chcę zniszczyć Corp O'Szczur. Na zawsze.",
					"jump_to": "s2_f_under_1"
				}
			]
		},

		# ── ŚCIEŻKA A: lojalność ────────────────────────────────────────────
		{
			"id": "s2_f_save_1",
			"speaker": "Szymon",
			"text": "Nie mam ci nic do udowodnienia. Marek żyje, Corp O'Szczur go więzi — to wystarczający powód.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_save_2",
			"speaker": "Bóbrmistrz",
			"text": "...Lojalność to nie jest coś, co rozumiem. Ale jest szczere.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_save_3",
			"speaker": "Bóbrmistrz",
			"text": "Weź. Jak go uwolnisz bez protokołu wyłączenia, system może zareagować. Nikt nie wie jak.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_save_4",
			"speaker": "Szymon",
			"text": "Ryzyko akceptuję.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_save_5",
			"speaker": "Bóbrmistrz",
			"text": "To teraz udowodnij że jesteś wart więcej ode mnie. Bo ja bym wziął klucz siłą.",
			"portrait": bobr_base,
			"end_dialogue": true
		},

		# ── ŚCIEŻKA B: zniszczenie ──────────────────────────────────────────
		{
			"id": "s2_f_under_1",
			"speaker": "Szymon",
			"text": "Nie chodzi już tylko o Marka. Chcę dokopać się do rdzenia — znaleźć coś, co ich definitywnie skończy. A Marek ma to w głowie.",
			"portrait": szymon_base
		},
		{
			"id": "s2_f_under_2",
			"speaker": "Bóbrmistrz",
			"text": "Zniszczenie. Nie przejęcie.",
			"portrait": bobr_base
		},
		{
			"id": "s2_f_under_3",
			"speaker": "Bóbrmistrz",
			"text": "Pierwszy raz od lat słyszę kogoś, kto tego chce zamiast tego drugiego. Dlatego właśnie nie mogę ci po prostu dać klucza. Musisz go zabrać. Wtedy będziesz wiedział na pewno, że go chcesz — a nie że ktoś ci go podarował.",
			"portrait": bobr_base,
			"end_dialogue": true
		}
	]


# ─────────────────────────────
# JOIN PATH (stage1 = choice_join)
# Szymon pytał o kasę — jest na ścieżce pragmatyzmu
# ─────────────────────────────
func _join_path() -> Array:
	return [
		{
			"id": "s2_j_1",
			"speaker": "Bóbrmistrz",
			"text": "Czurewski. Słyszałem że B.O.S.S. ci złożył ofertę. I że prawie ją przyjąłeś.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_2",
			"speaker": "Szymon",
			"text": "Prawie to duże słowo.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_3",
			"speaker": "Bóbrmistrz",
			"text": "W Corp O'Szczur prawie to podpisana umowa. Usiądź. Mamy chwilę.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_4",
			"speaker": "Szymon",
			"text": "Nie usiądę.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_5",
			"speaker": "Bóbrmistrz",
			"text": "Jak chcesz.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_6",
			"speaker": "Szymon",
			"text": "Szukam Marka.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_7",
			"speaker": "Bóbrmistrz",
			"text": "Wiem. Ale powiedz mi — po co? Nie dlatego że to przyjaciel. Naprawdę.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_8",
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_9",
			"speaker": "Bóbrmistrz",
			"text": "Bo widziałem już takich jak ty. Przychodzą tutaj z planem, z celem, z jasną głową. I za każdym razem, jak dochodzą do Marka — plan się sypie. Bo Marek nie jest tym, czego szukają.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_10",
			"speaker": "Szymon",
			"text": "To co jest?",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_11",
			"speaker": "Bóbrmistrz",
			"text": "Węzłem. Projekt Kret. Corp O'Szczur zrobił z niego centrum systemu — jego pamięć, kontakty, wiedza. Zintegrowany. Od lat.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_12",
			"speaker": "Szymon",
			"text": "...żyje?",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_13",
			"speaker": "Bóbrmistrz",
			"text": "Żyje. Ale nie wiem czy to jeszcze Marek, którego pamiętasz.",
			"portrait": bobr_base
		},
		# ── DEAD MAN'S SWITCH REVEAL ──────────────────────────────────────────
		{
			"id": "s2_j_14",
			"speaker": "Bóbrmistrz",
			"text": "Widzisz tę mapę?",
			"portrait": bobr_base,
			"effect": "point_at_map"
		},
		{
			"id": "s2_j_15",
			"speaker": "Bóbrmistrz",
			"text": "Myślałeś że to węzły sieci. To nie węzły.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_16",
			"speaker": "Bóbrmistrz",
			"text": "Jak Marek przestaje — zegary pod miastem zaczynają liczyć. Wrocław ma wtedy może cztery minuty. Może pięć. Zależy od wilgotności.",
			"portrait": bobr_base,
			"effect": "shake"
		},
		{
			"id": "s2_j_17",
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_18",
			"speaker": "Szymon",
			"text": "Corp O'Szczur podłożyło materiały wybuchowe pod całe miasto.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_19",
			"speaker": "Bóbrmistrz",
			"text": "Nie podłożyło. Ja podłożyłem. Na ich zlecenie. Dwadzieścia lat temu.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_20",
			"speaker": "Szymon",
			"text": "I teraz mi o tym mówisz.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_21",
			"speaker": "Bóbrmistrz",
			"text": "Teraz ci o tym mówię. Mam klucz do węzła. I mam pytanie — jak do niego dojdziesz, co zrobisz?",
			"portrait": bobr_base,
			"choices": [
				{
					"id": "s2_save",
					"text": "Wyciągnę go. Cokolwiek to kosztuje.",
					"jump_to": "s2_j_save_1"
				},
				{
					"id": "s2_understand",
					"text": "To zależy co tam znajdę.",
					"jump_to": "s2_j_under_1"
				}
			]
		},

		# ── ŚCIEŻKA A: ocalenie ─────────────────────────────────────────────
		{
			"id": "s2_j_save_1",
			"speaker": "Szymon",
			"text": "Jeśli żyje — wyciągam go. Nie ma tu nic do analizowania.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_save_2",
			"speaker": "Bóbrmistrz",
			"text": "Dawno nikt tak nie powiedział.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_save_3",
			"speaker": "Bóbrmistrz",
			"text": "Masz. Jak go odepniesz bez protokołu, system może zareagować. Może gwałtownie.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_save_4",
			"speaker": "Bóbrmistrz",
			"text": "Ale najpierw sprawdzę czy jesteś wystarczająco twardy na to co czeka wyżej.",
			"portrait": bobr_base,
			"end_dialogue": true
		},

		# ── ŚCIEŻKA B: pragmatyzm ───────────────────────────────────────────
		{
			"id": "s2_j_under_1",
			"speaker": "Szymon",
			"text": "Nie obiecuję niczego w ciemno. Chcę wiedzieć z czym wychodzę.",
			"portrait": szymon_base
		},
		{
			"id": "s2_j_under_2",
			"speaker": "Bóbrmistrz",
			"text": "Uczciwa odpowiedź. Pierwszy raz od dawna.",
			"portrait": bobr_base
		},
		{
			"id": "s2_j_under_3",
			"speaker": "Bóbrmistrz",
			"text": "Klucz jest do zabrania. Ale nie za darmo — to nigdy nie jest za darmo. Pokaż mi najpierw że warto go dać komuś takiemu jak ty.",
			"portrait": bobr_base,
			"end_dialogue": true
		}
	]