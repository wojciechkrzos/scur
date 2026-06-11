extends Resource

const szymon_base = preload("res://assets/portraits/szymon_base.png")
const gosia_base = preload("res://assets/portraits/gosia_base.png")
const marek_base = preload("res://assets/portraits/marek_base.png")
const boss2_base = preload("res://assets/portraits/boss2_base.png")

func get_lines(choice_id: String = ""):
	match choice_id:
		"choice_stage2_a":
			return _path_a()

		"choice_stage2_b":
			return _path_b()

		_:
			return _path_a()


# ─────────────────────────────
# PATH A: SAVE (heroiczny)
# Szymon odłącza Marka, ryzykując wszystko
# ─────────────────────────────
func _path_a() -> Array:
	return [
		{
			"id": "s2_p_save_1",
			"speaker": "Szymon",
			"text": "Marek. Odłączam cię.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_2",
			"speaker": "Marek",
			"text": "Szymon... switch.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_3",
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_4",
			"speaker": "Marek",
			"text": "Możesz nie zdążyć.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_5",
			"speaker": "Szymon",
			"text": "Wiem.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_6",
			"speaker": "",
			"text": "Szymon wyciąga kable. Jeden. Drugi. Trzeci.",
			"portrait": null
		},
		{
			"id": "s2_p_save_7",
			"speaker": "Marek",
			"text": "Aaa—",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_8",
			"speaker": "",
			"text": "Nie krzyk bólu. Raczej utrata czegoś większego niż ciało.",
			"portrait": null
		},
		{
			"id": "s2_p_save_9",
			"speaker": "",
			"text": "Cisza.",
			"portrait": null
		},
		{
			"id": "s2_p_save_10",
			"speaker": "",
			"text": "Nic się nie zawala.",
			"portrait": null
		},
		{
			"id": "s2_p_save_11",
			"speaker": "Marek",
			"text": "...nie wiem.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_12",
			"speaker": "Marek",
			"text": "Naprawdę nie wiem. Myślałem, że to prawda.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_13",
			"speaker": "Szymon",
			"text": "Nakłamali cię. Albo sam się w to wkręciłeś.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_14",
			"speaker": "Marek",
			"text": "Przepraszam.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_save_15",
			"speaker": "Szymon",
			"text": "Chodź. Wychodzimy.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_16",
			"speaker": "Gosia",
			"text": "Szymon... czy on... Marek...",
			"portrait": gosia_base
		},
		{
			"id": "s2_p_save_17",
			"speaker": "Szymon",
			"text": "Żyje. Idzie ze mną.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_18",
			"speaker": "Gosia",
			"text": "Dziękuję.",
			"portrait": gosia_base
		},
		{
			"id": "s2_p_save_19",
			"speaker": "Szymon",
			"text": "Jeszcze nie dziękuj. Hala Stulecia. Tam kończy się to wszystko.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_save_20",
			"speaker": "Gosia",
			"text": "Wiem. Ale... dziękuję.",
			"portrait": gosia_base,
			"end_dialogue": true
		},
	]


# ─────────────────────────────
# PATH B: SYSTEM (pragmatyczny / korporacyjny)
# Szymon nie odłącza Marka — wykorzystuje system
# ─────────────────────────────
func _path_b() -> Array:
	return [
		{
			"id": "s2_p_sys_1",
			"speaker": "Marek",
			"text": "Masz dostęp do sieci. Co teraz?",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_sys_2",
			"speaker": "Szymon",
			"text": "Hala Stulecia. Centrala. Ktoś tam rządzi tym wszystkim.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_3",
			"speaker": "Marek",
			"text": "Czuję to. Przez sieć.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_sys_4",
			"speaker": "Szymon",
			"text": "Możesz mi pokazać drogę?",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_5",
			"speaker": "Marek",
			"text": "Tak.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_sys_6",
			"speaker": "Marek",
			"text": "Szymon.",
			"portrait": marek_base,
			"effect": "shake"
		},
		{
			"id": "s2_p_sys_7",
			"speaker": "Szymon",
			"text": "Co?",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_8",
			"speaker": "Marek",
			"text": "Wróć po mnie. Potem.",
			"portrait": marek_base
		},
		{
			"id": "s2_p_sys_9",
			"speaker": "Szymon",
			"text": "...",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_10",
			"speaker": "Szymon",
			"text": "Wrócę.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_11",
			"speaker": "",
			"text": "Obaj wiedzą, że to może być kłamstwo.",
			"portrait": null
		},
		{
			"id": "s2_p_sys_12",
			"speaker": "Gosia",
			"text": "Idziesz dalej.",
			"portrait": gosia_base
		},
		{
			"id": "s2_p_sys_13",
			"speaker": "Szymon",
			"text": "Tak.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_14",
			"speaker": "Gosia",
			"text": "Bez niego.",
			"portrait": gosia_base
		},
		{
			"id": "s2_p_sys_15",
			"speaker": "Szymon",
			"text": "Na razie.",
			"portrait": szymon_base
		},
		{
			"id": "s2_p_sys_16",
			"speaker": "Gosia",
			"text": "Słyszę cię.",
			"portrait": gosia_base,
			"end_dialogue": true
		},
	]
