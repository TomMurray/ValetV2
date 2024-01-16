extends Button
class_name RetryLevelButton

var scene_tree_links : SceneTreeLinksComponent

func _on_ready():
	disabled = scene_tree_links == null or not scene_tree_links.has_curr()

func _ready():
	disabled = scene_tree_links == null or not scene_tree_links.has_next()

func _on_pressed():
	scene_tree_links.reload_current()

