@tool
extends Control
class_name MainMenu

@export var control_to_focus : Control = null:
	set(value):
		control_to_focus = value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not control_to_focus:
		return ["No Control to focus set on MainMenu"]
	return []

func _ready():
	control_to_focus.grab_focus()
