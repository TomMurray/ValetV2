extends Node

# Simple switcher that allows switching between 2 scenes
# with the ability to preload, and to queue the switch

var next_path := ""
var load_requested := false
var loaded := false
var switch_requested := false

func queue(path : String):
	assert(next_path.is_empty(), "Trying to queue a new scene to load but one is still queued!")
	next_path = path

func preload_queued():
	assert(!next_path.is_empty(), "No next scene to preload")
	var err := ResourceLoader.load_threaded_request(next_path, "PackedScene", true, ResourceLoader.CACHE_MODE_IGNORE)
	load_requested = true
	loaded = false
	assert(err == OK, "Load request failed with error '%s' for path '%s'" % [err, next_path])

func switch():
	if not load_requested:
		preload_queued()
	switch_requested = true

func _process(_delta):
	if load_requested:
		# Check status
		var status := ResourceLoader.load_threaded_get_status(next_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			loaded = true
		else:
			assert(status == ResourceLoader.THREAD_LOAD_IN_PROGRESS, "Unexpected thread load status %d" % status)
	
	if loaded and switch_requested:
		call_deferred("_do_switch")

func _do_switch():
	assert(!next_path.is_empty() and loaded and switch_requested)
	
	# Switch out the old scene for the new
	var new_scene_res := ResourceLoader.load_threaded_get(next_path) as PackedScene
	assert(new_scene_res != null, "Load returned no PackedScene resource")
	
	# Autoloads always come first in the root scene tree, and
	# we always launch with some scene that will be a node added
	# as the last child.
	# This scene manager will always be responsible for loading
	# and switching scenes.
	var root = get_tree().root
	var old_scene := root.get_child(root.get_child_count() - 1)
	root.remove_child(old_scene)
	old_scene.free()
	root.add_child(new_scene_res.instantiate())
	
	# Reset queued data
	next_path = ""
	load_requested = false
	loaded = false
	switch_requested = false
	
	
