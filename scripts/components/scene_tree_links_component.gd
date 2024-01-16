extends Node
class_name SceneTreeLinksComponent

# This is a resource so is reference counted.
# This will be filled out by a scene that navigates to the scene
# with this component as its direct child
@export var scene_tree_node : SceneTreeNode

func has_curr():
	return scene_tree_node != null and scene_tree_node.get_curr_child()

func has_next():
	return scene_tree_node != null and scene_tree_node.get_next_child()

func has_ancestor():
	return scene_tree_node != null

func _do_switch(path : String):
	SceneManager.queue(path)
	SceneManager.switch(func(next_scene):
		var links_component := Utils.get_child_of_type(next_scene, SceneTreeLinksComponent) as SceneTreeLinksComponent
		if links_component:
			links_component.scene_tree_node = scene_tree_node
	)

func reload_current():
	if not scene_tree_node:
		return
	_do_switch(scene_tree_node.get_curr_child())

func goto_next():
	if not scene_tree_node:
		return
	var switch_to = scene_tree_node.get_next_child()
	scene_tree_node.child_index += 1
	_do_switch(switch_to)
