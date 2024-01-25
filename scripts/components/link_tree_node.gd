@tool
extends Node
class_name LinkTreeNode

@export var scene_node_reference : Node:
	set(value):
		scene_node_reference = value
		update_configuration_warnings()

var link_stack := LinkStack.new()

func _get_configuration_warnings() -> PackedStringArray:
	# Check for correct scene node reference
	if scene_node_reference == null:
		return ["No scene node reference set on LinkTreeNode"]
	return []

func _ready():
	if not Engine.is_editor_hint():
		var scene_file_path := scene_node_reference.scene_file_path
		assert(scene_file_path != null)
		var ruid := ResourceLoader.get_resource_uid(scene_file_path)
		var ruid_text := ResourceUID.id_to_text(ruid)
		link_stack.links.append(Link.new(ruid_text))

func follow(link : Link):
	# Switch scenes to new link
	SceneManager.switch(link.path, func(new_scene):
		# Search for LinkTreeNode component in the newly loaded scene
		var link_tree_node := Utils.get_child_of_type(new_scene, LinkTreeNode)
		if link_tree_node != null:
			link_tree_node.link_stack = link_stack
	)

func reload():
	follow(link_stack.links.pop_back())

func has_return():
	return link_stack.links.size() >= 2

func follow_return():
	assert(has_return())
	# First pop the current node off the stack, then reload
	link_stack.links.pop_back()
	reload()
