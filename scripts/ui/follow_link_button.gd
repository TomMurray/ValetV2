@tool
extends Button
class_name FollowLinkButton

@export var link_tree_node : LinkTreeNode = null:
	set(value):
		link_tree_node = value
		update_configuration_warnings()

@export var link : Link = null:
	set(value):
		link = value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if link_tree_node == null:
		warnings.append("No LinkTreeNode set on FollowLinkButton")
	if link == null:
		warnings.append("No Link set on FollowLinkButton")
	return warnings

func _on_pressed():
	link_tree_node.follow(link)
