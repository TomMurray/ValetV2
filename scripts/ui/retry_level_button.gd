extends Button
class_name RetryLevelButton

var scene_tree_links : SceneTreeLinksComponent:
	set(value):
		scene_tree_links = value
		disabled = scene_tree_links == null or not scene_tree_links.has_curr()

func _ready():
	disabled = scene_tree_links == null or not scene_tree_links.has_curr()

func _on_pressed():
	scene_tree_links.reload_current()

