@tool
extends Node
class_name LevelRestartComponent

@onready var level_port := %level_port as LevelPortComponent

func _input(event):
	if event.is_action_pressed("restart"):
		level_port.go()
