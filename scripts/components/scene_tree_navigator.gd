extends Node
class_name SceneTreeNavigator

@export var scene_tree_node : SceneTreeNode

func has_curr():
	return scene_tree_node.get_curr_child() != null

func goto_curr_child():
	assert(has_curr(), "Trying to navigate to current child but it doesn't exist")
	SceneManager.queue(scene_tree_node.get_curr_child())
	SceneManager.switch(func(child_scene):
		var links_component := Utils.get_child_of_type(child_scene, SceneTreeLinksComponent) as SceneTreeLinksComponent
		if links_component:
			links_component.scene_tree_node = scene_tree_node
	)
