@tool
extends Control
class_name EndGamePanel

@export var scene_tree_links : SceneTreeLinksComponent:
	set(value):
		scene_tree_links = value
		%next_level_button.scene_tree_links = value
		%retry_level_button.scene_tree_links = value
		update_configuration_warnings()

@export var level_logic : LevelLogic:
	set(value):
		if level_logic and level_logic.is_connected("complete", _on_level_logic_complete):
			level_logic.disconnect("complete", _on_level_logic_complete)
			
		level_logic = value
		level_logic.connect("complete", _on_level_logic_complete)
		
		update_configuration_warnings()

func _get_configuration_warnings():
	var warnings : PackedStringArray
	if not scene_tree_links:
		warnings.append("No SceneTreeLinksComponent set for EndGamePanel")
	if not level_logic:
		warnings.append("No LevelLogic set for EndGamePanel")
	return warnings

func _on_level_logic_complete(success):
	# Configure some elements to show or not depending on the outcome
	if success:
		for c in [%success_text, %next_level_button]:
			c.show()
		%next_level_button.grab_focus()
	else:
		for c in [%failure_text, %retry_level_button]:
			c.show()
		%retry_level_button.grab_focus()
	
	# Show the panel
	show()
	
