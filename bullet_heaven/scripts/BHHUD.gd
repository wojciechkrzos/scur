extends CanvasLayer

@onready var lives_label = $LivesLabel
@onready var kills_label = $KillsLabel
@onready var timer_label = $TimerLabel
@onready var pattern_label = $PatternLabel
@onready var result_label = $ResultLabel

func setup(duration: float, lives: int) -> void:
	update_lives(lives)
	update_kills(0)
	update_timer(duration)
	update_pattern("AIMED FAN")
	result_label.visible = false

func update_lives(n: int) -> void:
	lives_label.text = "Lives: " + "♥ ".repeat(max(n, 0))

func update_kills(k: int) -> void:
	kills_label.text = "Kills: %04d" % k

func update_timer(t: float) -> void:
	var secs = max(t, 0.0)
	timer_label.text = "Time: %05.1f" % secs
	if secs < 8.0:
		timer_label.modulate = Color(1.0, 0.4, 0.4)
	else:
		timer_label.modulate = Color(1.0, 1.0, 1.0)

func update_pattern(name_text: String) -> void:
	pattern_label.text = "Pattern: " + name_text

func show_result(result: String) -> void:
	result_label.visible = true
	if result == "win":
		result_label.text = "WAVE CLEAR"
		result_label.modulate = Color(0.5, 1.0, 0.5)
	else:
		result_label.text = "YOU DIED"
		result_label.modulate = Color(1.0, 0.4, 0.4)
