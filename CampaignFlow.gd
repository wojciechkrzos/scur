extends Node

signal finished

const Stage1Flow = preload("res://Stage1Flow.gd")
const Stage2Flow = preload("res://Stage2Flow.gd")
const Stage3Flow = preload("res://Stage3Flow.gd")
const EndingFlow = preload("res://EndingFlow.gd")

var main_ref: Node

var stages: Array = []
var index: int = 0
var current_runner: Node = null


func start(main_node: Node) -> void:
	main_ref = main_node

	stages = [
		Stage1Flow.new(),
		Stage2Flow.new(),
		Stage3Flow.new(),
		EndingFlow.new()
	]

	index = 0
	_run_next_stage()


func _run_next_stage() -> void:
	if current_runner:
		current_runner.queue_free()
		current_runner = null

	if index >= stages.size():
		finished.emit()
		return

	current_runner = stages[index]
	index += 1

	add_child(current_runner)

	current_runner.finished.connect(_on_stage_finished)
	current_runner.start(main_ref)


func _on_stage_finished() -> void:
	_run_next_stage()