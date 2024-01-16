extends Button
class_name NextLevelButton

@export var scene_tree_links : SceneTreeLinksComponent = null:
	set(value):
		scene_tree_links = value
		update_disabled_status()

func update_disabled_status():
	disabled = scene_tree_links == null or not scene_tree_links.has_next()

func _ready():
	update_disabled_status()

func _on_pressed():
	scene_tree_links.goto_next()

