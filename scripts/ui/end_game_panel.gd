@tool
extends Control
class_name EndGamePanel

@export var link_tree_node : LinkTreeNode = null:
	set(value):
		link_tree_node = value
		update_configuration_warnings()
		if link_tree_node:
			next_level_button.link_tree_node = link_tree_node
			retry_level_button.link_tree_node = link_tree_node

@export var level_logic : LevelLogic:
	set(value):
		if level_logic and level_logic.is_connected("complete", _on_level_logic_complete):
			level_logic.disconnect("complete", _on_level_logic_complete)
			
		level_logic = value
		level_logic.connect("complete", _on_level_logic_complete)
		
		update_configuration_warnings()

@onready var next_level_button : NextLevelButton = %next_level_button
@onready var retry_level_button : RetryLevelButton = %retry_level_button

func _get_configuration_warnings():
	var warnings : PackedStringArray
	if not link_tree_node:
		warnings.append("No LinkTreeNode set for EndGamePanel")
	if not level_logic:
		warnings.append("No LevelLogic set for EndGamePanel")
	return warnings

func _on_level_logic_complete(success):
	# Configure some elements to show or not depending on the outcome
	if success:
		for c in [%success_text, next_level_button]:
			c.show()
		next_level_button.update_disabled_status()
		next_level_button.grab_focus()
	else:
		for c in [%failure_text, retry_level_button]:
			c.show()
		retry_level_button.update_disabled_status()
		retry_level_button.grab_focus()
	
	# Show the panel
	show()
	
