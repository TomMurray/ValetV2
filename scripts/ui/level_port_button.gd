@tool
extends Button
class_name LevelPortButton

@export var level_port : LevelPortComponent = null:
	set(value):
		level_port = value
		update_configuration_warnings()

func _get_configuration_warnings():
	if not level_port:
		return ["No LevelPortComponent set on LevelPortButton"]
	return []

func _ready():
	disabled = not level_port

func _on_pressed():
	level_port.go()
