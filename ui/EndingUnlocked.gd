extends CanvasLayer

signal closed

@onready var ending_label = $CenterContainer/Panel/VBoxContainer/EndingLabel
@onready var title_label = $CenterContainer/Panel/VBoxContainer/TitleLabel
@onready var button = $CenterContainer/Panel/VBoxContainer/ContinueButton

func _ending_to_number(id: String) -> int:
	var map = {
		"aaa": 1,
		"aab": 2,
		"aba": 3,
		"abb": 4,
		"baa": 5,
		"bab": 6,
		"bba": 7,
		"bbb": 8
	}
	return map.get(id, 0)

func _ready():
	button.pressed.connect(func():
		closed.emit()
		queue_free()
	)

func show_result(ending_id: String, is_new: bool):
	visible = true

	var num = _ending_to_number(ending_id)

	title_label.text = "Zwycięstwo!"

	ending_label.text = "Odblokowano ending #" + str(num) + " (" + ending_id + ")"
	