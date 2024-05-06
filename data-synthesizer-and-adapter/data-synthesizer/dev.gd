extends Node

var node_randomizer

func _ready():
	node_randomizer = get_node('Randomizer')
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		node_randomizer.emit()
