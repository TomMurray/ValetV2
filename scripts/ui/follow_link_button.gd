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

func _update_disabled_status():
	disabled = not link_tree_node or not Utils.is_valid_resource_path(link.path)

func _ready():
	if not Engine.is_editor_hint():
		_update_disabled_status()
		if link_tree_node:
			link_tree_node.connect("ready", _on_link_tree_node_ready)

func _on_link_tree_node_ready():
	_update_disabled_status()

func _on_pressed():
	link_tree_node.follow(link)
