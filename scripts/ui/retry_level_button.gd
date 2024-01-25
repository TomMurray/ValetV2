extends Button
class_name RetryLevelButton

var link_tree_node : LinkTreeNode

func update_disabled_status():
	disabled = link_tree_node == null

func _on_pressed():
	link_tree_node.reload()

