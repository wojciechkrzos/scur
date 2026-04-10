extends CanvasLayer

signal resume_pressed

@onready var continue_button = $VBoxContainer/ContinueButton

func show_menu(tutorial_text: String, objective_text: String):
	visible = true
	get_tree().paused = true
	
	$VBoxContainer/TutorialLabel.text = "Sterowanie:\n" + tutorial_text
	$VBoxContainer/ObjectiveLabel.text = "Twój cel:\n" + objective_text

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_resume)

func _on_resume():
	get_tree().paused = false
	resume_pressed.emit()
