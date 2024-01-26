@tool
extends ColorRect
class_name PauseScreen

@export var link_tree_node : LinkTreeNode = null:
	set(value):
		link_tree_node = value
		update_configuration_warnings()
		if link_tree_node:
			exit_button.link_tree_node = link_tree_node

@onready var continue_button : Button = %continue_button
@onready var exit_button : FollowReturnButton = %exit_button

func _get_configuration_warnings() -> PackedStringArray:
	if not link_tree_node:
		return ["No LinkTreeNode set on PauseScreen"]
	return []

func _update_showing_status():
	if not Engine.is_editor_hint():
		if get_tree().paused:
			show()
			continue_button.grab_focus()
		else:
			hide()

func _ready():
	_update_showing_status()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		# Pause/unpause the game
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().paused = not get_tree().paused
			_update_showing_status()

func _on_button_pressed():
	get_tree().paused = false
	_update_showing_status()
