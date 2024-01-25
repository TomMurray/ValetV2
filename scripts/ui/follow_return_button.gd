@tool
extends Button
class_name FollowReturnButton

@export var link_tree_node : LinkTreeNode = null:
	set(value):
		link_tree_node = value
		update_configuration_warnings()
		
func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if link_tree_node == null:
		warnings.append("No LinkTreeNode set on FollowReturnButton")
	return warnings

func _update_disabled_status():
	disabled = not link_tree_node or not link_tree_node.has_return()

func _ready():
	_update_disabled_status()
	if link_tree_node:
		link_tree_node.connect("ready", _on_link_tree_node_ready)

func _on_link_tree_node_ready():
	_update_disabled_status()

func _on_pressed():
	assert(link_tree_node.has_return())
	link_tree_node.follow_return()
