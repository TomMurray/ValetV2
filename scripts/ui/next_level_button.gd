extends Button
class_name NextLevelButton

var link_tree_node : LinkTreeNode

func update_disabled_status():
	disabled = link_tree_node == null or not link_tree_node.has_return()

func _on_pressed():
	link_tree_node.follow_return()

