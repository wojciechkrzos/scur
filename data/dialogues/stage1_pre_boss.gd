extends Resource
const boss1_base = preload("res://assets/portraits/boss1_base.png")
const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")

func get_lines():
	return [
		# ── Wejście ──────────────────────────────────────────────────────
		{
			"id": 0,
			"speaker": "B.O.S.S.",
			"text": "Szymon… lojalny pracownik. A jednak taka zdrada. Szkoda.",
			"portrait": boss1_base
		},
		{
			"id": 1,
			"speaker": "Szymon",
			"text": "HR mnie zwolniło. Ty mnie chcesz zabić. Trochę overkill.",
			"portrait": szymon_base
		},
		{
			"id": 2,
			"speaker": "B.O.S.S.",
			"text": "To tylko biznes.",
			"effect": "shake",
			"portrait": boss1_base
		},
		{
			"id": 3,
			"speaker": "B.O.S.S.",
			"text": "Wiesz co jest śmieszne? Przez osiem lat robiłeś dokładnie to samo co ja. Tylko że w białych rękawiczkach.",
			"portrait": boss1_base
		},
		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Ja nikogo nie…",
			"portrait": szymon_base
		},
		{
			"id": 5,
			"speaker": "B.O.S.S.",
			"text": "Marek. Pamiętasz Marka? Twój raport. Jego etat. Prosta matematyka.",
			"effect": "shake",
			"portrait": boss1_base
		},
		{
			"id": 6,
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": 7,
			"speaker": "B.O.S.S.",
			"text": "Corp O'Szczur nie zrobiła z ciebie szczura, Szymon. Ty już nim byłeś. My tylko daliśmy ci tytuł.",
			"portrait": boss1_base
		},
		{
			"id": 8,
			"speaker": "B.O.S.S.",
			"text": "Mam dla ciebie propozycję. Ostatnią.",
			"portrait": boss1_base
		},
		{
			"id": 9,
			"speaker": "B.O.S.S.",
			"text": "Wróć. Nie na poprzednie stanowisko — wyżej. Wrocław potrzebuje kogoś z twoimi… kwalifikacjami. Kogoś, kto rozumie jak działa system od środka.",
			"portrait": boss1_base
		},
		{
			"id": 10,
			"speaker": "Szymon",
			"text": "Żartujesz.",
			"portrait": szymon_base
		},
		{
			"id": 11,
			"speaker": "B.O.S.S.",
			"text": "Przez osiem lat byłeś skuteczny. Okrutny tam gdzie trzeba. I co najważniejsze — nigdy nie pytałeś za dużo. Aż do teraz.",
			"portrait": boss1_base
		},
		{
			"id": 12,
			"speaker": "B.O.S.S.",
			"text": "Więc pytam jeszcze raz. Co chcesz, Szymon? Zemstę? Sprawiedliwość? A może… fotel?",
			"portrait": boss1_base,
			"choices": [
				{
					"id": "choice_fight",
					"text": "Chcę wiedzieć co stało się z Markiem.",
					"jump_to": 13
				},
				{
					"id": "choice_join",
					"text": "Ile płacisz?",
					"jump_to": 20
				}
			]
		},

		# ── ŚCIEŻKA A: Szymon pyta o Marka → walka ──────────────────────
		{
			"id": 13,
			"speaker": "B.O.S.S.",
			"text": "...",
			"portrait": boss1_base
		},
		{
			"id": 14,
			"speaker": "B.O.S.S.",
			"text": "Wiedziałem, że o to zapytasz. Zawsze byłeś sentymentalny. To twoja największa wada.",
			"portrait": boss1_base
		},
		{
			"id": 15,
			"speaker": "Szymon",
			"text": "Gdzie on jest.",
			"portrait": szymon_base
		},
		{
			"id": 16,
			"speaker": "B.O.S.S.",
			"text": "W bezpiecznym miejscu. Tak długo jak ty... współpracujesz.",
			"effect": "shake",
			"portrait": boss1_base
		},
		{
			"id": 17,
			"speaker": "Szymon",
			"text": "Więc jednak żyje.",
			"portrait": szymon_base
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "To był błąd. Właśnie potwierdziłeś, że mam powód żeby cię pokonać.",
			"portrait": szymon_base
		},
		{
			"id": 19,
			"speaker": "B.O.S.S.",
			"text": "Sentymentalni głupcy. Zawsze tacy sami.",
			"effect": "shake",
			"portrait": boss1_base
		},
		{
			"id": 20,
			"speaker": "Gosia",
			"text": "Halo? Halo, Szymon? Musisz pokonać go, strzelając za pomocą Spacji! I skup się, gdy będziesz chciał precyzyjnie strzelać - wciskając przycisk Shift!",
			"portrait": gosia_base,
			"end_dialogue": true
		},

		# ── ŚCIEŻKA B: Szymon pyta o kasę → mroczne zakończenie ─────────
		{
			"id": 21,
			"speaker": "B.O.S.S.",
			"text": "Ha.",
			"portrait": boss1_base
		},
		{
			"id": 22,
			"speaker": "B.O.S.S.",
			"text": "Trzykrotność poprzedniej pensji. Służbowy szczur — przepraszam, samochód. I pakiet benefitów którego nie powstydziłby się żaden człowiek.",
			"portrait": boss1_base
		},
		{
			"id": 23,
			"speaker": "Szymon",
			"text": "A Marek?",
			"portrait": szymon_base
		},
		{
			"id": 24,
			"speaker": "B.O.S.S.",
			"text": "Marek podjął złe decyzje. Ty podejmujesz lepsze.",
			"portrait": boss1_base
		},
		{
			"id": 25,
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": 26,
			"speaker": "Szymon",
			"text": "Dobra. Ale najpierw udowodnij, że jesteś wart tej kasy.",
			"portrait": szymon_base
		},
		{
			"id": 27,
			"speaker": "B.O.S.S.",
			"text": "Widzisz? Zawsze wiedziałem, że jesteś jednym z nas.",
			"effect": "shake",
			"portrait": boss1_base
		},
				{
			"id": 28,
			"speaker": "Gosia",
			"text": "Halo? Halo, Szymon? Musisz pokonać go, strzelając za pomocą Spacji! I skup się, gdy będziesz chciał precyzyjnie strzelać - wciskając przycisk Shift!",
			"portrait": gosia_base,
			"end_dialogue": true
		},
	]
