@tool
extends Node
class_name LevelRestartComponent

@export var link_tree_node : LinkTreeNode:
	set(value):
		link_tree_node = value
		update_configuration_warnings()

func _get_configuration_warnings():
	if not link_tree_node:
		return ["No LinkTreeNode set on LevelRestartComponent"]
	return []

func _input(event):
	if event.is_action_pressed("restart") and link_tree_node != null:
		link_tree_node.reload()
