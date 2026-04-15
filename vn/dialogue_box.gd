extends CanvasLayer

signal dialogue_started
signal dialogue_finished(result)

@onready var root: Control = $Root
@onready var panel: PanelContainer = $Root/Panel

@onready var portrait: TextureRect = $Root/Portrait
@onready var speaker_name: Label = $Root/Panel/VBoxContainer/SpeakerName
@onready var dialogue_text: RichTextLabel = $Root/Panel/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Root/Panel/VBoxContainer/ChoicesContainer

@onready var skip_button: Button = $Root/SkipButton

@export var text_speed: float = 50.0

var shake_effect: ShakeEffect

var lines: Array = []
var current_line_index: int = 0
var current_text: String = ""
var visible_characters_count: int = 0
var visible_characters_progress: float = 0.0
var is_typing: bool = false
var current_speed: float = 0.0
var current_effect: String = ""
var last_choice_id: String = ""
var waiting_for_end := false #delay po koncu dialogu zeby zdazyc przeczytac ostatnia wiadomosc
var id_to_index := {} #mapowanie id dialogu na indeksy

func _ready() -> void:
	print(portrait)
	print(speaker_name)
	print(dialogue_text)
	print(choices_container)
	print("DialogueBox ready")
	visible = false
	set_process(false)
	
	dialogue_text.bbcode_enabled = true

	shake_effect = ShakeEffect.new()
	dialogue_text.install_effect(shake_effect)
	
	#USTAWIENIE POZYCJI SPRITEA
	portrait.anchor_left = 0.0
	portrait.anchor_top = 1.0
	portrait.anchor_right = 0.0
	portrait.anchor_bottom = 1.0
	portrait.offset_left = 0.0
	portrait.offset_top = -(panel.custom_minimum_size.y + portrait.custom_minimum_size.y)
	portrait.offset_right = portrait.custom_minimum_size.x
	portrait.offset_bottom = -panel.custom_minimum_size.y
	portrait.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	#PODPIECIE LOGIKI SKIP BUTTONA + STYLING
	skip_button.pressed.connect(_on_skip_pressed)
	skip_button.offset_right = - get_viewport().get_visible_rect().size.x + panel.custom_minimum_size.x + skip_button.size.x + 10
	skip_button.offset_bottom = -10.0

func start_dialogue(dialogue_lines: Array) -> void:
	if dialogue_lines.is_empty():
		return

	lines = dialogue_lines
	current_line_index = 0
	
	id_to_index.clear()
	for i in range(lines.size()):
		var line = lines[i]
		if line.has("id"):
			id_to_index[line["id"]] = i

	visible = true
	dialogue_started.emit()

	_show_current_line()
	set_process(true)

func _process(delta: float) -> void:
	if not is_typing:
		return

	visible_characters_progress += current_speed * delta
	visible_characters_count = int(visible_characters_progress)
	dialogue_text.visible_characters = visible_characters_count

	if visible_characters_count >= current_text.length():
		_finish_typing()


#LOGIKA SKIP BUTTONA Z UWZGLEDNIENIEM ROZNYCH SCIEZEK DIALOGOWYCH (jump to)
func _on_skip_pressed() -> void:
	skip_to_next_choice()
	
func skip_to_next_choice() -> void:
	if waiting_for_end:
		_end_dialogue()
		return
		
	if is_typing:
		_show_full_text()
	
	# Zabezpieczenie przed nieskończoną pętlą
	var visited := {}
	
	while current_line_index < lines.size():
		# Wykryj pętlę — jeśli byliśmy już w tej linii, przerwij
		if visited.has(current_line_index):
			_end_dialogue()
			return
		visited[current_line_index] = true
		
		var line: Dictionary = lines[current_line_index]
		var choices: Array = line.get("choices", [])
		
		# Ta linia ma wybory — zatrzymaj się tutaj
		if not choices.is_empty():
			_show_current_line()
			return
		
		# Sprawdź czy linia sama w sobie ma jump_to (auto-skok bez wyboru)
		if line.has("jump_to"):
			var target_id = int(line["jump_to"])
			if id_to_index.has(target_id):
				current_line_index = id_to_index[target_id]
				continue
			else:
				push_error("Nie znaleziono id: " + str(target_id))
				_end_dialogue()
				return
		
		# Zwykła linia — idź do następnej
		current_line_index += 1
	
	_end_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if waiting_for_end:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
			_end_dialogue()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			_show_full_text()
		elif choices_container.get_child_count() == 0:
			_go_to_next_line()
			get_viewport().set_input_as_handled()
			

#pomocnicza metoda
#func _get_shake_effect() -> ShakeEffect:
	#for child in dialogue_text.get_children():
		#if child is ShakeEffect:
			#return child as ShakeEffect   # <-- DODAJ "as ShakeEffect"
	#return null

func _show_current_line() -> void:
	_clear_choices()
	
	if current_line_index >= lines.size():
		_end_dialogue()
		return
	
	var line: Dictionary = lines[current_line_index]
	speaker_name.text = line.get("speaker", "")
	current_text = line.get("text", "")
	current_speed = line.get("speed", text_speed)
	current_effect = line.get("effect", "")
	
	if current_effect == "shake":
		dialogue_text.text = "[shake]" + current_text + "[/shake]"
	else:
		dialogue_text.text = current_text
	dialogue_text.visible_characters = 0
	
	var portrait_texture = line.get("portrait", null)
	portrait.texture = portrait_texture
	portrait.visible = portrait_texture != null
	
	visible_characters_count = 0
	visible_characters_progress = 0.0
	is_typing = true

func _finish_typing() -> void:
	is_typing = false
	dialogue_text.visible_characters = -1

	var line: Dictionary = lines[current_line_index]
	
	# Sprawdź czy ta linia kończy dialog - handling ścieżek wyboru
	if line.get("end_dialogue", false):
		waiting_for_end = true
		return
	
	var choices: Array = line.get("choices", [])
	if not choices.is_empty():
		_show_choices(choices)

func _show_full_text() -> void:
	visible_characters_count = current_text.length()
	visible_characters_progress = float(visible_characters_count)
	_finish_typing()

func _go_to_next_line() -> void:
	if waiting_for_end:
		return
	current_line_index += 1
	_show_current_line()

func _show_choices(choices: Array) -> void:
	for choice_data in choices:
		var button := Button.new()
		button.text = str(choice_data.get("text", "Wybór"))
		button.pressed.connect(_on_choice_selected.bind(choice_data))
		choices_container.add_child(button)

func _on_choice_selected(choice_data: Dictionary) -> void:
	last_choice_id = str(choice_data.get("id", ""))
	if choice_data.has("jump_to"):
		var target_id = int(choice_data["jump_to"])
		if id_to_index.has(target_id):
			current_line_index = id_to_index[target_id]
		else:
			push_error("Nie znaleziono id: " + str(target_id))
			return
		_show_current_line()
		return

	if choice_data.get("end_dialogue", false):
		_end_dialogue()
		return

	_go_to_next_line()

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _end_dialogue() -> void:
	visible = false
	set_process(false)
	_clear_choices()
	waiting_for_end = false
	dialogue_finished.emit({
		"choice": last_choice_id
	})
