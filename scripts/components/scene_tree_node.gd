extends Resource
class_name SceneTreeNode

@export var this_scene : String
@export var children : Array[String]
@export var child_index = 0

func get_parent():
	return this_scene if not this_scene.is_empty() else null

func get_curr_child():
	return get_child(child_index)

func get_next_child():
	return get_child(child_index + 1)

func get_child(index : int):
	if index < children.size():
		return children[index]
	return null
