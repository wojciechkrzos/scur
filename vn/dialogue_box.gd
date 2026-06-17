extends CanvasLayer

signal dialogue_started
signal dialogue_finished(result)

@onready var root: Control = $Root
@onready var panel: PanelContainer = $Root/Panel
@onready var background_image: TextureRect = $Root/BackgroundImage

@onready var portrait: TextureRect = $Root/Portrait
@onready var speaker_name: Label = $Root/Panel/VBoxContainer/SpeakerName
@onready var dialogue_text: RichTextLabel = $Root/Panel/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Root/Panel/VBoxContainer/ChoicesContainer

@onready var skip_button: Button = $Root/SkipButton
@onready var next_button: Button = $Root/NextButton

@export var text_speed: float = 50.0

const VN_MUSIC_PATH := "res://assets/audio/music/vn_dark_ambient.wav"
const VN_MELLOW_MUSIC_PATH := "res://assets/audio/music/vn_mellow_dark.wav"
const TYPEWRITER_SFX_PATH := "res://assets/audio/sfx/dialogue_blip.wav"

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
var current_dialogue_id: String = ""
var music_player: AudioStreamPlayer
var music_tween: Tween
var typewriter_player: AudioStreamPlayer
var last_blip_character_count: int = 0
var blip_step: int = 2

const DIALOGUE_BACKGROUNDS := {
	"tutorial": "res://assets/vn/background_tutorial.png",
	"stage1_pre_boss": "res://assets/vn/background_stage_1_pre_boss.png",
	"stage1_post_boss": "res://assets/vn/background_stage_1_post_boss.png",
	"stage2_intro": "res://assets/vn/background_stage_2.png",
	"stage2_pre_boss": "res://assets/vn/background_stage_2.png",
	"stage2_post_boss": "res://assets/vn/background_stage_2.png",
	"stage3_intro": "res://assets/vn/background_stage_3.png",
	"stage3_pre_boss": "res://assets/vn/background_stage_3.png",
	"stage3_post_boss": "res://assets/vn/background_stage_3.png",
}

func _ready() -> void:
	print(portrait)
	print(speaker_name)
	print(dialogue_text)
	print(choices_container)
	print("DialogueBox ready")
	visible = false
	set_process(false)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	dialogue_text.bbcode_enabled = true
	_setup_music()

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
	skip_button.offset_right = - get_viewport().get_visible_rect().size.x + panel.custom_minimum_size.x + 250
	skip_button.offset_bottom = -190.0
	next_button.pressed.connect(_on_next_pressed)
	next_button.offset_right = skip_button.offset_right - next_button.size.x - 20
	next_button.offset_bottom = -190.0
	_apply_dialogue_background()

func set_dialogue_context(dialogue_id: String) -> void:
	current_dialogue_id = dialogue_id
	_apply_dialogue_background()

func start_dialogue(dialogue_lines: Array) -> void:
	if dialogue_lines.is_empty():
		return

	_ensure_music_player()
	lines = dialogue_lines
	current_line_index = 0
	_apply_dialogue_background()
	
	id_to_index.clear()
	for i in range(lines.size()):
		var line = lines[i]
		if line.has("id"):
			id_to_index[line["id"]] = i

	visible = true
	_fade_music_in()
	dialogue_started.emit()

	_show_current_line()
	set_process(true)

func _apply_dialogue_background() -> void:
	if background_image == null:
		return

	background_image.texture = null
	background_image.visible = false

	if current_dialogue_id.is_empty():
		return

	if not DIALOGUE_BACKGROUNDS.has(current_dialogue_id):
		return

	var texture_path: String = str(DIALOGUE_BACKGROUNDS[current_dialogue_id])
	if not ResourceLoader.exists(texture_path):
		return

	var texture_resource := ResourceLoader.load(texture_path)
	if texture_resource is Texture2D:
		background_image.texture = texture_resource as Texture2D
		background_image.visible = true

func _process(delta: float) -> void:
	if not is_typing:
		return

	visible_characters_progress += current_speed * delta
	visible_characters_count = int(visible_characters_progress)
	dialogue_text.visible_characters = visible_characters_count
	_play_typewriter_blip()

	if visible_characters_count >= current_text.length():
		_finish_typing()


#LOGIKA SKIP BUTTONA Z UWZGLEDNIENIEM ROZNYCH SCIEZEK DIALOGOWYCH (jump to)
func _on_skip_pressed() -> void:
	skip_to_next_choice()

func _on_next_pressed() -> void:
	_advance_dialogue()
	
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

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_advance_dialogue()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_accept"):
		_advance_dialogue()
		get_viewport().set_input_as_handled()

func _advance_dialogue() -> void:
	if waiting_for_end:
		_end_dialogue()
		return
	if is_typing:
		_show_full_text()
		return
	if choices_container.get_child_count() == 0:
		_go_to_next_line()
			

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
	if portrait_texture is String:
		var portrait_path := str(portrait_texture)
		portrait_texture = null if portrait_path.is_empty() else load(portrait_path)
	portrait.texture = portrait_texture if portrait_texture is Texture2D else null
	portrait.visible = portrait.texture != null
	
	visible_characters_count = 0
	visible_characters_progress = 0.0
	last_blip_character_count = 0
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
		var target_id: Variant = choice_data["jump_to"]
		if not id_to_index.has(target_id):
			var target_string := str(target_id)
			if target_string.is_valid_int():
				target_id = int(target_string)
		if id_to_index.has(target_id):
			current_line_index = id_to_index[target_id]
		else:
			push_error("Nie znaleziono id: " + str(choice_data["jump_to"]))
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
	_fade_music_out()
	dialogue_finished.emit({
		"choice": last_choice_id
	})

func stop_dialogue() -> void:
	visible = false
	set_process(false)
	_clear_choices()
	waiting_for_end = false
	if music_tween != null and music_tween.is_valid():
		music_tween.kill()
	if music_player != null:
		music_player.stop()

func _setup_music() -> void:
	_ensure_music_player()

func _ensure_music_player() -> void:
	if music_player != null and is_instance_valid(music_player):
		if music_player.stream == null:
			_assign_music_stream()
	else:
		music_player = AudioStreamPlayer.new()
		music_player.name = "VNMusicPlayer"
		music_player.bus = &"Music"
		music_player.process_mode = Node.PROCESS_MODE_ALWAYS
		music_player.volume_db = -40.0
		add_child(music_player)
		_assign_music_stream()

	if typewriter_player != null and is_instance_valid(typewriter_player):
		return
	typewriter_player = AudioStreamPlayer.new()
	typewriter_player.name = "TypewriterBlipPlayer"
	typewriter_player.bus = &"SFX"
	typewriter_player.process_mode = Node.PROCESS_MODE_ALWAYS
	typewriter_player.volume_db = -12.0
	typewriter_player.max_polyphony = 6
	if ResourceLoader.exists(TYPEWRITER_SFX_PATH):
		typewriter_player.stream = load(TYPEWRITER_SFX_PATH) as AudioStream
	add_child(typewriter_player)

func _assign_music_stream() -> void:
	if music_player == null:
		return
	var music_path := _get_vn_music_path()
	if not ResourceLoader.exists(music_path):
		return
	var stream := load(music_path) as AudioStream
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_player.stream = stream

func _get_vn_music_path() -> String:
	return VN_MELLOW_MUSIC_PATH if ResourceLoader.exists(VN_MELLOW_MUSIC_PATH) else VN_MUSIC_PATH

func _play_typewriter_blip() -> void:
	if typewriter_player == null or typewriter_player.stream == null:
		return
	if visible_characters_count <= last_blip_character_count:
		return
	if visible_characters_count % blip_step != 0:
		return
	if current_text.is_empty():
		return
	var char_index := clampi(visible_characters_count - 1, 0, current_text.length() - 1)
	if current_text.substr(char_index, 1) != " ":
		typewriter_player.pitch_scale = randf_range(0.92, 1.08)
		typewriter_player.play()
	last_blip_character_count = visible_characters_count

func _fade_music_in() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("play_music_path"):
		if audio_manager.has_method("play_procedural_music"):
			if audio_manager.play_procedural_music("vn_mellow", 2.0, 1.0):
				if audio_manager.has_method("get_music_player"):
					music_player = audio_manager.get_music_player()
				return
		var music_path := _get_vn_music_path()
		if audio_manager.play_music_path(music_path, true, 4.0, 1.0):
			if audio_manager.has_method("get_music_player"):
				music_player = audio_manager.get_music_player()
			return
	if music_player == null or music_player.stream == null:
		return
	if music_tween != null and music_tween.is_valid():
		music_tween.kill()
	music_player.volume_db = -40.0
	if not music_player.playing:
		music_player.play()
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", 4.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _fade_music_out() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("stop_music") and audio_manager.has_method("get_music_player") and music_player == audio_manager.get_music_player():
		audio_manager.stop_music(0.75)
		return
	if music_player == null or not music_player.playing:
		return
	if music_tween != null and music_tween.is_valid():
		music_tween.kill()
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", -40.0, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	music_tween.tween_callback(music_player.stop)
