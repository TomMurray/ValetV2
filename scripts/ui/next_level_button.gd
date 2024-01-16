extends Button
class_name NextLevelButton

var scene_tree_links : SceneTreeLinksComponent:
	set(value):
		scene_tree_links = value
		disabled = scene_tree_links == null or not scene_tree_links.has_next()

func _ready():
	disabled = scene_tree_links == null or not scene_tree_links.has_next()

func _on_pressed():
	scene_tree_links.goto_next()

