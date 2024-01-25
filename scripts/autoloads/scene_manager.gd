extends Node

# Simple switcher that allows switching between 2 scenes

func switch(path : String, switch_callback = null):
	call_deferred("_do_switch", path, switch_callback)

func _do_switch(path : String, switch_callback : Callable):
	assert(path != null and !path.is_empty())
	
	# Switch out the old scene for the new
	var new_scene_res := load(path) as PackedScene
	assert(new_scene_res != null, "Load returned no PackedScene resource")
	
	# Autoloads always come first in the root scene tree, and
	# we always launch with some scene that will be a node added
	# as the last child.
	# This scene manager will always be responsible for loading
	# and switching scenes.
	var root = get_tree().root
	var old_scene := root.get_child(root.get_child_count() - 1)
	var new_scene := new_scene_res.instantiate()
	if switch_callback != null:
		switch_callback.call(new_scene)
	root.remove_child(old_scene)
	old_scene.free()
	root.add_child(new_scene)
	
	
