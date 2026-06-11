extends Resource

const BOSS3_BASE = preload("res://assets/portraits/BOSS3_BASE.png")
const SZYMON_BASE = preload("res://assets/portraits/SZYMON_BASE.png")
const GOSIA_BASE = preload("res://assets/portraits/GOSIA_BASE.png")
const MAREK_BASE = preload("res://assets/portraits/MAREK_BASE.png")

func get_lines(ending_id: String = ""):
	match ending_id:
		"aaa":
			return _path_aaa()

		"aab":
			return _path_aab()

		"aba":
			return _path_aba()

		"abb":
			return _path_abb()

		"baa":
			return _path_baa()

		"bab":
			return _path_bab()

		"bba":
			return _path_bba()

		"bbb":
			return _path_bbb()

		_:
			return _path_aaa()


# ─────────────────────────────
# AAA (Zniszczenie + prawda + wspólne wejście)
# ─────────────────────────────
func _path_aaa() -> Array:
	return [
		{
			"id": 1,
			"speaker": "Marek",
			"text": "Tu."
		},
		{
			"id": 2,
			"speaker": "Marek",
			"text": "Jak to zniszczymy, tunele przestają działać. Corp O'Szczur traci kontrolę nad miastem."
		},
		{
			"id": 3,
			"speaker": "Szymon",
			"text": "A dead man's switch?"
		},
		{
			"id": 4,
			"speaker": "Marek",
			"text": "Nie wiem. Naprawdę nie wiem."
		},
		{
			"id": 5,
			"speaker": "Gosia",
			"text": "Ja wiem."
		},
		{
			"id": 6,
			"speaker": "Gosia",
			"text": "Switch jest prawdziwy. Ale tylko dla sektora wschodniego. Rynek. Stare Miasto."
		},
		{
			"id": 7,
			"speaker": "Gosia",
			"text": "Reszta jest blefem."
		},
		{
			"id": 8,
			"speaker": "Szymon",
			"text": "Skąd wiesz?"
		},
		{
			"id": 9,
			"speaker": "Gosia",
			"text": "Bo przez rok robiłam dla nich dokumentację. Zanim zrozumiałam co dokumentuję."
		},
		{
			"id": 10,
			"speaker": "Marek",
			"text": "Gosiu..."
		},
		{
			"id": 11,
			"speaker": "Gosia",
			"text": "Nie teraz. Potem."
		},
		{
			"id": 12,
			"speaker": "Gosia",
			"text": "Szymon. Sektor wschodni musi zostać nienaruszony. Reszta sieci - możesz zniszczyć."
		},
		{
			"id": 13,
			"speaker": "Szymon",
			"text": "To wystarczy?"
		},
		{
			"id": 14,
			"speaker": "Gosia",
			"text": "Corp O'Szczur bez sieci to tylko firma z biurem i złą reputacją. Resztą zajmą się inni."
		},
		{
			"id": 15,
			"speaker": "Szymon",
			"text": "Marek. Jesteś pewien?"
		},
		{
			"id": 16,
			"speaker": "Marek",
			"text": "Nie."
		},
		{
			"id": 17,
			"speaker": "Marek",
			"text": "Ale zrób to."
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "No to... chyba to koniec."
		},
		{
			"id": 19,
			"speaker": "Gosia",
			"text": "Nie. To początek ich końca."
		},
		{
			"id": 20,
			"speaker": "Gosia",
			"text": "Ale tak. Na dziś koniec."
		},
		{
			"id": 21,
			"speaker": "Marek",
			"text": "Zimno tu."
		},
		{
			"id": 22,
			"speaker": "Szymon",
			"text": "Wiem."
		},
		{
			"id": 23,
			"speaker": "Szymon",
			"text": "Chodźcie. Znam miejsce gdzie robią przyzwoitego kebaba."
		},
		{
			"id": 24,
			"speaker": "Gosia",
			"text": "Teraz?"
		},
		{
			"id": 25,
			"speaker": "Szymon",
			"text": "Nie jadłem od rana. Właśnie zniszczyłem przestępczą korporację. Należy mi się kebab."
		},
		{
			"id": 26,
			"speaker": "Marek",
			"text": "Zawsze byłeś najgłupszym geniuszem jakiego znałem."
		},
		{
			"id": 27,
			"speaker": "Szymon",
			"text": "Pracownik miesiąca. Jedenaście razy z rzędu."
		},

		{
			"id": 28,
			"speaker": "Narrator",
			"text": "Corp O'Szczur oficjalnie ogłosiła upadłość trzy tygodnie później. Powód: 'trudności finansowe'."
		},
		{
			"id": 29,
			"speaker": "Narrator",
			"text": "Projekt Kret nigdy nie wyszedł na jaw. Tunele istnieją do dziś."
		},
		{
			"id": 30,
			"speaker": "Narrator",
			"text": "Marek spędził rok na rehabilitacji. Potem otworzył małą firmę budowlaną. Specjalizacja: fundamenty."
		},
		{
			"id": 31,
			"speaker": "Narrator",
			"text": "Gosia zniknęła z Wrocławia. Podobno pracuje w Gdańsku. Podobno."
		},
		{
			"id": 32,
			"speaker": "Narrator",
			"text": "Szymon Czurewski nigdy nie dostał kosza prezentowego."
		},
		{
			"id": 33,
			"speaker": "Narrator",
			"text": "Kebab był dobry."
		}
	]


# ─────────────────────────────
# AAB (przejęcie + system)
# ─────────────────────────────
func _path_aab() -> Array:
	return [
		{
			"id": 1,
			"speaker": "Szymon",
			"text": "Mam dostęp do całej sieci."
		},
		{
			"id": 2,
			"speaker": "Marek",
			"text": "Szymon..."
		},
		{
			"id": 3,
			"speaker": "Szymon",
			"text": "Wiem co myślisz."
		},
		{
			"id": 4,
			"speaker": "Marek",
			"text": "Naprawdę?"
		},
		{
			"id": 5,
			"speaker": "Szymon",
			"text": "Że to zły pomysł."
		},
		{
			"id": 6,
			"speaker": "Marek",
			"text": "To zły pomysł."
		},
		{
			"id": 7,
			"speaker": "Gosia",
			"text": "Szymon. Przejęcie systemu to nie to samo co jego zniszczenie."
		},
		{
			"id": 8,
			"speaker": "Szymon",
			"text": "Wiem. Ale zniszczenie zostawia pustkę. A pustki zawsze coś wypełnia. Wolę wiedzieć co."
		},
		{
			"id": 9,
			"speaker": "Gosia",
			"text": "A jeśli ciebie wypełni?"
		},
		{
			"id": 10,
			"speaker": "Szymon",
			"text": "Słucham?"
		},
		{
			"id": 11,
			"speaker": "Gosia",
			"text": "System. A jeśli to ty się zmienisz, nie on?"
		},
		{
			"id": 12,
			"speaker": "Szymon",
			"text": "Ryzykuję."
		},
		{
			"id": 13,
			"speaker": "Marek",
			"text": "Co teraz?"
		},
		{
			"id": 14,
			"speaker": "Szymon",
			"text": "Teraz restrukturyzacja."
		},
		{
			"id": 15,
			"speaker": "Gosia",
			"text": "Brzmi znajomo."
		},
		{
			"id": 16,
			"speaker": "Szymon",
			"text": "Gosia-"
		},
		{
			"id": 17,
			"speaker": "Gosia",
			"text": "Nie. Masz rację że brzmi znajomo, Szymon. Matka też 'restrukturyzowała'."
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "Będę inaczej."
		},
		{
			"id": 19,
			"speaker": "Gosia",
			"text": "Wiem że w to wierzysz."
		},
		{
			"id": 20,
			"speaker": "",
			"text": "Gosia bierze Marka za rękę. Wychodzą razem. Szymon zostaje przy ekranach."
		},
		{
			"id": 21,
			"speaker": "",
			"text": "Szymon patrzy na mapę sieci. Wrocław z góry. Każdy tunel. Każdy węzeł. Wszystko jego."
		},
		{
			"id": 22,
			"speaker": "",
			"text": "Telefon dzwoni. Nieznany numer."
		},
		{
			"id": 23,
			"speaker": "Szymon",
			"text": "Słucham."
		},
		{
			"id": 24,
			"speaker": "",
			"text": "Głos: Witamy w Corp O'Szczur, panie Czurewski. Czekaliśmy na pana."
		},
		{
			"id": 25,
			"speaker": "",
			"text": "Szymon rozłącza się. Ale nie odchodzi od ekranów."
		},
		{
			"id": 26,
			"speaker": "Narrator",
			"text": "Szymon Czurewski przejął aktywa Corp O'Szczur w październiku."
		},
		{
			"id": 27,
			"speaker": "Narrator",
			"text": "Pierwsze trzy miesiące były inne."
		},
		{
			"id": 28,
			"speaker": "Narrator",
			"text": "Potem zaczęły się 'trudne decyzje'."
		},
		{
			"id": 29,
			"speaker": "Narrator",
			"text": "Gosia nie odbiera telefonu."
		},
		{
			"id": 30,
			"speaker": "Narrator",
			"text": "Marek wysłał jedną wiadomość: 'Pamiętaj po co zacząłeś'."
		},
		{
			"id": 31,
			"speaker": "Narrator",
			"text": "Szymon ją przeczytał. Odpisał: 'Pamiętam'."
		},
		{
			"id": 32,
			"speaker": "Narrator",
			"text": "Nie wiadomo czy to prawda."
		}
	]


# ─────────────────────────────
# ABA (poświęcenie Marka)
# ─────────────────────────────
func _path_aba() -> Array:
	return [
		{
			"id": 1,
			"speaker": "Gosia",
			"text": "Widzę węzeł na mapie systemu. Jesteś przy nim?"
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Tak."
		},
		{
			"id": 3,
			"speaker": "Gosia",
			"text": "Szymon."
		},
		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Co?"
		},
		{
			"id": 5,
			"speaker": "Gosia",
			"text": "Marek jest w sektorze wschodnim. Wciąż podłączony."
		},
		{
			"id": 6,
			"speaker": "Szymon",
			"text": "Wiem."
		},
		{
			"id": 7,
			"speaker": "Gosia",
			"text": "Jeśli zniszczysz węzeł bez odłączenia go najpierw..."
		},
		{
			"id": 8,
			"speaker": "Szymon",
			"text": "Wiem."
		},
		{
			"id": 9,
			"speaker": "Gosia",
			"text": "Możemy po niego pojechać. Najpierw. A potem-"
		},
		{
			"id": 10,
			"speaker": "Szymon",
			"text": "Nie zdążymy. Matka ma ludzi wszędzie. Jak wrócimy po niego, przejmą węzeł z powrotem."
		},
		{
			"id": 11,
			"speaker": "Gosia",
			"text": "Szymon. To mój brat."
		},
		{
			"id": 12,
			"speaker": "Szymon",
			"text": "Wiem."
		},
		{
			"id": 13,
			"speaker": "Gosia",
			"text": "To powiedz mi że jest inne wyjście."
		},
		{
			"id": 14,
			"speaker": "",
			"text": "Gosia. Dead man's switch dla sektora wschodniego - jest prawdziwy?"
		},
		{
			"id": 15,
			"speaker": "Gosia",
			"text": "...tak."
		},
		{
			"id": 16,
			"speaker": "Szymon",
			"text": "Więc jeśli zniszczę węzeł, sektor wschodni zostaje. Marek zostaje z nim."
		},
		{
			"id": 17,
			"speaker": "Gosia",
			"text": "Jako interfejs. Podłączony. Bez sieci wokół, ale nadal..."
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "Żywy."
		},
		{
			"id": 19,
			"speaker": "Gosia",
			"text": "To nie jest życie."
		},
		{
			"id": 20,
			"speaker": "Szymon",
			"text": "Gosia."
		},
		{
			"id": 21,
			"speaker": "Gosia",
			"text": "Co?"
		},
		{
			"id": 22,
			"speaker": "Szymon",
			"text": "Przepraszam."
		},
		{
			"id": 23,
			"speaker": "",
			"text": "Szymon niszczy węzeł. Sieć umiera. Sektor wschodni zostaje. Marek zostaje."
		},
		{
			"id": 24,
			"speaker": "",
			"text": "Gosia nic nie mówi. Przez bardzo długi czas."
		},
		{
			"id": 25,
			"speaker": "Gosia",
			"text": "Corp O'Szczur upada?"
		},
		{
			"id": 26,
			"speaker": "Szymon",
			"text": "Upada."
		},
		{
			"id": 27,
			"speaker": "Gosia",
			"text": "Dobrze."
		},
		{
			"id": 28,
			"speaker": "",
			"text": "rozłącza się"
		},
		{
			"id": 29,
			"speaker": "",
			"text": "Szymon stoi w ciemnej Hali Stulecia. Sam. Wygrał. Wie co zostawił."
		},
		{
			"id": 30,
			"speaker": "Narrator",
			"text": "Corp O'Szczur upadła."
		},
		{
			"id": 31,
			"speaker": "Narrator",
			"text": "Projekt Kret częściowo zniszczony. Sektor wschodni nadal aktywny. Przyczyna nieznana."
		},
		{
			"id": 32,
			"speaker": "Narrator",
			"text": "Marek Olejnik oficjalnie: zaginiony."
		},
		{
			"id": 33,
			"speaker": "Narrator",
			"text": "Gosia Ratowska nie skontaktowała się z Szymonem Czurowskim nigdy więcej."
		},
		{
			"id": 34,
			"speaker": "Narrator",
			"text": "Szymon wrócił do Wrocławia. Mieszka przy Rynku. Czasem słyszy coś pod podłogą."
		},
		{
			"id": 35,
			"speaker": "Narrator",
			"text": "Nigdy nie sprawdza co."
		}
	]


func _path_abb() -> Array:
	return [
		{
			"id": 1,
			"speaker": "Gosia",
			"text": "Przejmujesz system."
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Tak."
		},
		{
			"id": 3,
			"speaker": "Gosia",
			"text": "Z Markiem w środku."
		},
		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Na razie."
		},
		{
			"id": 5,
			"speaker": "Gosia",
			"text": "'Na razie'."
		},
		{
			"id": 6,
			"speaker": "Szymon",
			"text": "Gosia, jeśli go teraz odłączę, sektor wschodni..."
		},
		{
			"id": 7,
			"speaker": "Gosia",
			"text": "Wiem. Wiem co mówisz."
		},
		{
			"id": 8,
			"speaker": "Gosia",
			"text": "Po prostu chcę żebyś powiedział wprost. Co robisz."
		},
		{
			"id": 9,
			"speaker": "Szymon",
			"text": "Przejmuję Corp O'Szczur. Zostawiam Marka podłączonego dopóki nie znajdę bezpiecznego sposobu na odłączenie. Używam systemu żeby znaleźć ten sposób."
		},
		{
			"id": 10,
			"speaker": "Gosia",
			"text": "A jeśli nie znajdziesz?"
		},
		{
			"id": 11,
			"speaker": "Szymon",
			"text": "Znajdę."
		},
		{
			"id": 12,
			"speaker": "Gosia",
			"text": "A jeśli system znajdzie ciebie?"
		},
		{
			"id": 13,
			"speaker": "",
			"text": "Szymon nie odpowiada. Przejmuje dostęp. Na ekranach mapa sieci. W sektorze wschodnim jeden punkt pulsuje regularnie. Marek."
		},
		{
			"id": 14,
			"speaker": "Szymon",
			"text": "Marek. Słyszysz mnie przez sieć?"
		},
		{
			"id": 15,
			"speaker": "Marek",
			"text": "Słyszę. W systemie jego głos brzmi inaczej - za spokojnie."
		},
		{
			"id": 16,
			"speaker": "Szymon",
			"text": "Wróciłem."
		},
		{
			"id": 17,
			"speaker": "Marek",
			"text": "Wiem. Czułem że wejdziesz do systemu."
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "Znajdę sposób. Obiecuję."
		},
		{
			"id": 19,
			"speaker": "Marek",
			"text": "Wiem."
		},
		{
			"id": 20,
			"speaker": "Marek",
			"text": "Szymon."
		},
		{
			"id": 21,
			"speaker": "Szymon",
			"text": "Co?"
		},
		{
			"id": 22,
			"speaker": "Marek",
			"text": "Jest mi tu dobrze. Naprawdę. Nie spiesz się."
		},
		{
			"id": 23,
			"speaker": "",
			"text": "Szymon przejmuje Corp O'Szczur."
		},
		{
			"id": 24,
			"speaker": "",
			"text": "Przez pierwszy rok szuka sposobu na odłączenie Marka. Zatrudnia trzech inżynierów. Dwóch rezygnuje. Jeden znika."
		},
		{
			"id": 25,
			"speaker": "",
			"text": "Marek Olejnik nadal jest podłączony. Mówi że mu dobrze."
		},
		{
			"id": 26,
			"speaker": "",
			"text": "Gosia Ratowska odwiedza brata raz w miesiącu. Za każdym razem mówi Szymonowi: 'Obiecałeś'."
		},
		{
			"id": 27,
			"speaker": "",
			"text": "Szymon zawsze odpowiada: 'Wiem'."
		},
		{
			"id": 28,
			"speaker": "",
			"text": "Corp O'Szczur działa dalej. Inaczej. Podobno."
		}
	]

func _path_baa() -> Array:
	return [
		{
			"id": 1,
			"speaker": "Marek",
			"text": "Nie rozumiem.",
			"portrait": MAREK_BASE
		},
		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Czego?",
			"portrait": SZYMON_BASE
		},
		{
			"id": 3,
			"speaker": "Marek",
			"text": "Dlaczego tu jesteś. Mówiłeś że zostajesz w Corp O'Szczur.",
			"portrait": MAREK_BASE
		},
		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Zmieniłem zdanie.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 5,
			"speaker": "Marek",
			"text": "Kiedy?",
			"portrait": MAREK_BASE
		},
		{
			"id": 6,
			"speaker": "Szymon",
			"text": "Jak zobaczyłem cię w tej ścianie.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 7,
			"speaker": "",
			"text": "Szymon patrzy na Marka. Marek patrzy na Szymona. Cztery lata w Corp O'Szczur. Wspólne raporty. Wspólne lunch breaki. Jeden zniknął. Drugi nie szukał."
		},
		{
			"id": 8,
			"speaker": "Szymon",
			"text": "Marek.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 9,
			"speaker": "Marek",
			"text": "Co?",
			"portrait": MAREK_BASE
		},
		{
			"id": 10,
			"speaker": "Szymon",
			"text": "Przepraszam. Że nie szukałem wcześniej.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 11,
			"speaker": "Marek",
			"text": "Nie wiedziałeś.",
			"portrait": MAREK_BASE
		},
		{
			"id": 12,
			"speaker": "Szymon",
			"text": "Mogłem wiedzieć. Gdybym pytał.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 13,
			"speaker": "",
			"text": "Marek wzrusza ramionami. To boli Szymona bardziej niż gdyby krzyknął."
		},
		{
			"id": 14,
			"speaker": "Gosia",
			"text": "Panowie. Serio. Węzeł.",
			"portrait": GOSIA_BASE
		},
		{
			"id": 15,
			"speaker": "",
			"text": "Szymon niszczy węzeł. Sprawnie. Szybko. Bez ceremonii. Jakby chciał skończyć zanim zmieni zdanie."
		},
		{
			"id": 16,
			"speaker": "",
			"text": "Sieć umiera."
		},
		{
			"id": 17,
			"speaker": "Marek",
			"text": "Czuję jak odpływa.",
			"portrait": MAREK_BASE
		},
		{
			"id": 18,
			"speaker": "Szymon",
			"text": "Dobrze?",
			"portrait": SZYMON_BASE
		},
		{
			"id": 19,
			"speaker": "Marek",
			"text": "Dziwnie. Ale... tak. Chyba dobrze.",
			"portrait": MAREK_BASE
		},
		{
			"id": 20,
			"speaker": "Gosia",
			"text": "Idziemy.",
			"portrait": GOSIA_BASE
		},
		{
			"id": 21,
			"speaker": "",
			"text": "wychodzą szybko. Hala Stulecia za nimi. Na zewnątrz - Wrocław. Noc. Neony. Tramwaj."
		},
		{
			"id": 22,
			"speaker": "Szymon",
			"text": "Co teraz?",
			"portrait": SZYMON_BASE
		},
		{
			"id": 23,
			"speaker": "Gosia",
			"text": "Nie wiem.",
			"portrait": GOSIA_BASE
		},
		{
			"id": 24,
			"speaker": "Marek",
			"text": "Ja też nie.",
			"portrait": MAREK_BASE
		},
		{
			"id": 25,
			"speaker": "Szymon",
			"text": "No to dobrze. Bo ja też nie.",
			"portrait": SZYMON_BASE
		},
		{
			"id": 26,
			"speaker": "",
			"text": "tramwaj przejeżdża. W środku - ludzie. Normalni. Nieświadomi. To chyba dobrze."
		},
		{
			"id": 27,
			"speaker": "Narrator",
			"text": "Corp O'Szczur upadła szybciej niż ktokolwiek się spodziewał. Bez sieci była tylko pustą nazwą."
		},
		{
			"id": 28,
			"speaker": "Narrator",
			"text": "Szymon Czurewski przez pewien czas był poszukiwany przez prokuraturę. Sprawa umorzona z braku dowodów."
		},
		{
			"id": 29,
			"speaker": "Narrator",
			"text": "Marek przez rok nie mógł spać bez snów o tunelach."
		},
		{
			"id": 30,
			"speaker": "Narrator",
			"text": "Powoli przechodziły."
		},
		{
			"id": 31,
			"speaker": "Narrator",
			"text": "Gosia i Szymon przez jakiś czas pracowali razem. Potem różnie."
		},
		{
			"id": 32,
			"speaker": "Narrator",
			"text": "Wrocław nigdy się nie dowiedział. Może to lepiej. Może nie."
		}
	]


# ─────────────────────────────
# BAB (system + kompromis)
# ─────────────────────────────
func _path_bab() -> Array:
	return [
		{
			"id": 0,
			"speaker": "Narrator",
			"text": "[Pod Halą Stulecia. \nCentralny węzeł. \nSzymon, Gosia, Marek.]"
		},

		{
			"id": 1,
			"speaker": "Szymon",
			"text": "Przejmuję system.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 2,
			"speaker": "Gosia",
			"text": "Wiedziałam.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 3,
			"speaker": "Szymon",
			"text": "Gosia-",
			"portrait": SZYMON_BASE
		},

		{
			"id": 4,
			"speaker": "Gosia",
			"text": "Nie. \nTo dobrze. \nNaprawdę.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 5,
			"speaker": "Szymon",
			"text": "Słucham?",
			"portrait": SZYMON_BASE
		},

		{
			"id": 6,
			"speaker": "Gosia",
			"text": "Masz dostęp do systemu. \nMarek jest wolny. \nCorp O'Szczur bez Matki \nto headless chicken.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 7,
			"speaker": "Gosia",
			"text": "Jeśli ktoś musi \nprzejąć stery, \nto wolę żeby był to ktoś \nkto wie co tu się działo.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 8,
			"speaker": "Marek",
			"text": "Ja nie jestem pewien.",
			"portrait": MAREK_BASE
		},

		{
			"id": 9,
			"speaker": "Gosia",
			"text": "Marek.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 10,
			"speaker": "Marek",
			"text": "Szymon przyszedł tu \npo awans i kasę. \nPamiętasz?",
			"portrait": MAREK_BASE
		},

		{
			"id": 11,
			"speaker": "Szymon",
			"text": "Pamiętam.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 12,
			"speaker": "Marek",
			"text": "I co się zmieniło?",
			"portrait": MAREK_BASE
		},

		{
			"id": 13,
			"speaker": "Szymon",
			"text": "Zobaczyłem cię w tej ścianie.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 14,
			"speaker": "Szymon",
			"text": "Nie mówię że jestem \nbohaterem. \nMówię że wiem \njak to działa. \nI że mam lepszy powód \nniż Matka \nżeby tego nie niszczyć.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 15,
			"speaker": "Gosia",
			"text": "Jaki powód?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 16,
			"speaker": "Szymon",
			"text": "Wrocław to moje miasto. \nNie mój produkt.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 17,
			"speaker": "Marek",
			"text": "Pilnuj go.",
			"portrait": MAREK_BASE
		},

		{
			"id": 18,
			"speaker": "Marek",
			"text": "Jego. \nI systemu. \nJednocześnie.",
			"portrait": MAREK_BASE
		},

		{
			"id": 19,
			"speaker": "Gosia",
			"text": "Zawsze.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 20,
			"speaker": "Narrator",
			"text": "Szymon Czurewski \nprzejął Corp O'Szczur."
		},

		{
			"id": 21,
			"speaker": "Narrator",
			"text": "Pierwsze decyzje \nbyły dobre."
		},

		{
			"id": 22,
			"speaker": "Narrator",
			"text": "System \njest cierpliwy."
		},

		{
			"id": 23,
			"speaker": "Narrator",
			"text": "Marek odwiedza Szymona \nraz w tygodniu. \nSprawdza."
		},

		{
			"id": 24,
			"speaker": "Narrator",
			"text": "Na razie \njest okej."
		},

		{
			"id": 25,
			"speaker": "Narrator",
			"text": "Na razie."
		}
	]


# ─────────────────────────────
# BBA (odrzucenie kontroli)
# ─────────────────────────────
func _path_bba() -> Array:
	return [
		{
			"id": 0,
			"speaker": "Narrator",
			"text": "[Pod Halą Stulecia. \nCentralny węzeł. \nSzymon sam. \nTylko słuchawka.]"
		},

		{
			"id": 1,
			"speaker": "Gosia",
			"text": "Niszczysz to.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 2,
			"speaker": "Szymon",
			"text": "Tak.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 3,
			"speaker": "Gosia",
			"text": "Po wszystkim co zrobiłeś \nżeby tu dotrzeć.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Tak.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 5,
			"speaker": "Gosia",
			"text": "Dlaczego?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 6,
			"speaker": "Narrator",
			"text": "[Szymon długo milczy. \nEkrany migają. \nMapa sieci. \nWrocław z góry. \nPunkt w sektorze wschodnim. \nMarek.]"
		},

		{
			"id": 7,
			"speaker": "Szymon",
			"text": "Bo widziałem co robi \nz ludźmi.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 8,
			"speaker": "Gosia",
			"text": "Wcześniej ci to \nnie przeszkadzało.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 9,
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 10,
			"speaker": "Gosia",
			"text": "Szymon. \nMarek jest \nwciąż podłączony.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 11,
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 12,
			"speaker": "Gosia",
			"text": "Jeśli zniszczysz węzeł-",
			"portrait": GOSIA_BASE
		},

		{
			"id": 13,
			"speaker": "Szymon",
			"text": "Sektor wschodni zostaje. \nMarek zostaje. \nWiem.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 14,
			"speaker": "Gosia",
			"text": "To po co?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 15,
			"speaker": "Szymon",
			"text": "Bo reszta sieci umrze. \nCorp O'Szczur straci \nkontrolę nad miastem. \nTo wystarczy.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 16,
			"speaker": "Gosia",
			"text": "A Marek?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 17,
			"speaker": "Szymon",
			"text": "Masz dostęp do sektora \nbez głównego węzła?",
			"portrait": SZYMON_BASE
		},

		{
			"id": 18,
			"speaker": "Gosia",
			"text": "...tak. \nTechnicznie.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 19,
			"speaker": "Szymon",
			"text": "Więc możesz \npo niego wrócić. \nBez Corp O'Szczur \nza plecami.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 20,
			"speaker": "Gosia",
			"text": "To mógłbyś zrobić sam.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 21,
			"speaker": "Szymon",
			"text": "Nie zaufałby mi. \nPo tym co wybrałem \nw kanałach.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 22,
			"speaker": "Gosia",
			"text": "A mi zaufa?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 23,
			"speaker": "Szymon",
			"text": "Jesteś jego siostrą.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 24,
			"speaker": "Gosia",
			"text": "Dobrze.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 25,
			"speaker": "Narrator",
			"text": "[Szymon niszczy węzeł. \nBez ceremonii. \nBez monologu. \nPo prostu niszczy.]"
		},

		{
			"id": 26,
			"speaker": "Narrator",
			"text": "[sieć umiera.]"
		},

		{
			"id": 27,
			"speaker": "Narrator",
			"text": "[Szymon siada na podłodze \nHali Stulecia. \nSam. \nCzeka.]"
		},

		{
			"id": 28,
			"speaker": "Narrator",
			"text": "[po chwili - \nkroki. \nGosia. \nI Marek. \nMarek patrzy na Szymona. \nDługo.]"
		},

		{
			"id": 29,
			"speaker": "Marek",
			"text": "Mogłeś mnie \nwcześniej zostawić.",
			"portrait": MAREK_BASE
		},

		{
			"id": 30,
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 31,
			"speaker": "Marek",
			"text": "Ale nie zostawiłeś.",
			"portrait": MAREK_BASE
		},

		{
			"id": 32,
			"speaker": "Szymon",
			"text": "Nie.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 33,
			"speaker": "Marek",
			"text": "Wystarczy.",
			"portrait": MAREK_BASE
		},

		{
			"id": 34,
			"speaker": "Narrator",
			"text": "Corp O'Szczur upadła."
		},

		{
			"id": 35,
			"speaker": "Narrator",
			"text": "Szymon Czurewski \nprzez kilka miesięcy \nmiał poczucie \nże zrobił coś złego \nżeby zrobić coś dobrego."
		},

		{
			"id": 36,
			"speaker": "Narrator",
			"text": "Potem przestał \nto rozróżniać."
		},

		{
			"id": 37,
			"speaker": "Narrator",
			"text": "Marek wrócił do zdrowia. \nWolno."
		},

		{
			"id": 38,
			"speaker": "Narrator",
			"text": "Gosia powiedziała Szymonowi \ntylko raz: \n'Następnym razem \nzdecyduj wcześniej'."
		},

		{
			"id": 39,
			"speaker": "Narrator",
			"text": "Szymon powiedział: \n'Wiem'."
		},

		{
			"id": 40,
			"speaker": "Narrator",
			"text": "Oboje wiedzą \nże to prawda."
		}
	]


# ─────────────────────────────
# BBB (pełna kontrola)
# ─────────────────────────────
func _path_bbb() -> Array:
	return [
		{
			"id": 0,
			"speaker": "Narrator",
			"text": "[Pod Halą Stulecia. \nCentralny węzeł. \nSzymon sam.]"
		},

		{
			"id": 1,
			"speaker": "Narrator",
			"text": "[Przejmuje dostęp. \nSpokojnie. \nSprawnie. \nJakby robił to \ncałe życie.]"
		},

		{
			"id": 2,
			"speaker": "Narrator",
			"text": "[Mapa sieci na ekranach. \nWrocław z góry. \nWszystkie tunele. \nWszystkie węzły. \nWszystkie dźwignie \nnaraz.]"
		},

		{
			"id": 3,
			"speaker": "Gosia",
			"text": "Szymon.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 4,
			"speaker": "Szymon",
			"text": "Co?",
			"portrait": SZYMON_BASE
		},

		{
			"id": 5,
			"speaker": "Gosia",
			"text": "Marek jest \nwciąż podłączony.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 6,
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 7,
			"speaker": "Gosia",
			"text": "I?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 8,
			"speaker": "Szymon",
			"text": "I jest bezpieczny. \nSystem działa. \nNa razie zostawiam.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 9,
			"speaker": "Narrator",
			"text": "[cisza]"
		},

		{
			"id": 10,
			"speaker": "Gosia",
			"text": "On jest moim bratem.",
			"portrait": GOSIA_BASE
		},

		{
			"id": 11,
			"speaker": "Szymon",
			"text": "Wiem, Gosia.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 12,
			"speaker": "Gosia",
			"text": "To kiedy-",
			"portrait": GOSIA_BASE
		},

		{
			"id": 13,
			"speaker": "Szymon",
			"text": "Jak ustabilizuję sieć. \nJak przejmę wszystkie \npunkty dostępu. \nJak będzie bezpiecznie.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 14,
			"speaker": "Gosia",
			"text": "A jeśli \nnigdy nie będzie \nbezpiecznie?",
			"portrait": GOSIA_BASE
		},

		{
			"id": 15,
			"speaker": "Narrator",
			"text": "[Szymon nie odpowiada.]"
		},

		{
			"id": 16,
			"speaker": "Narrator",
			"text": "[na jednym z ekranów - \npunkt w sektorze wschodnim. \nMarek. \nPulsuje regularnie. \nŻyje.]"
		},

		{
			"id": 17,
			"speaker": "Narrator",
			"text": "[Szymon patrzy na punkt. \nPotem odwraca wzrok. \nWraca do mapy.]"
		},

		{
			"id": 18,
			"speaker": "Szymon",
			"text": "Znajdę sposób.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 19,
			"speaker": "Narrator",
			"text": "[Gosia rozłącza się.]"
		},

		{
			"id": 20,
			"speaker": "Narrator",
			"text": "[Szymon zostaje sam \nz mapą Wrocławia. \nZ siecią tuneli. \nZ Corp O'Szczur \nw swoich rękach.]"
		},

		{
			"id": 21,
			"speaker": "Narrator",
			"text": "[po chwili telefon dzwoni. \nNumer: 'Klient - Poznań'. \nSzymon patrzy na ekran. \nOdbiera.]"
		},

		{
			"id": 22,
			"speaker": "Szymon",
			"text": "Corp O'Szczur. \nSłucham.",
			"portrait": SZYMON_BASE
		},

		{
			"id": 23,
			"speaker": "Narrator",
			"text": "[Hala Stulecia. \nEkrany. \nMapa. \nWrocław pod kontrolą.]"
		},

		{
			"id": 24,
			"speaker": "Narrator",
			"text": "Szymon Czurewski \nzostał Prezesem Corp O'Szczur \nw wieku trzydziestu czterech lat."
		},

		{
			"id": 25,
			"speaker": "Narrator",
			"text": "Pierwsza decyzja: \nnowe logo. \n'UrbanNet Solutions'. \nBrzmi lepiej."
		},

		{
			"id": 26,
			"speaker": "Narrator",
			"text": "Marek Olejnik \nnadal jest podłączony. \nSzymon odwiedza go \nraz w miesiącu. \nPrzynosi kawę \nktórej Marek nie może wypić."
		},

		{
			"id": 27,
			"speaker": "Narrator",
			"text": "Gosia Ratowska \nzłożyła zawiadomienie \nna policję. \nSprawę umorzono."
		},

		{
			"id": 28,
			"speaker": "Narrator",
			"text": "Corp O'Szczur \notworzyła nową filię \nw Poznaniu."
		},

		{
			"id": 29,
			"speaker": "Narrator",
			"text": "Potem w Krakowie."
		},

		{
			"id": 30,
			"speaker": "Narrator",
			"text": "Potem w Warszawie."
		},

		{
			"id": 31,
			"speaker": "Narrator",
			"text": "Wrocław \nnigdy się nie dowiedział."
		},

		{
			"id": 32,
			"speaker": "Narrator",
			"text": "Tak jak zawsze."
		},

		{
			"id": 33,
			"speaker": "Narrator",
			"text": "[ostatni ekran: \nmapa Polski. \nPunkty w każdym mieście. \nPulsują regularnie. \nRosną.]"
		},

		{
			"id": 34,
			"speaker": "Narrator",
			"text": "[fade to black]"
		}
	]
