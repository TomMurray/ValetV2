@tool
extends Node
class_name LevelRestartComponent

@export var scene_tree_links : SceneTreeLinksComponent:
	set(value):
		scene_tree_links = value
		update_configuration_warnings()

func _get_configuration_warnings():
	if not scene_tree_links:
		return ["No SceneTreeLinksComponent set on LevelRestartComponent"]
	return []

func _input(event):
	if event.is_action_pressed("restart") and scene_tree_links and scene_tree_links.has_curr():
		scene_tree_links.reload_current()
