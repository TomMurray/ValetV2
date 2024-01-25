extends Control
class_name LevelSelect

@export var initial_focus_button : Control = null

func _ready():
	if initial_focus_button:
		initial_focus_button.grab_focus()
