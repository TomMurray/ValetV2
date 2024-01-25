extends Button

@export var link_tree_node : LinkTreeNode
@export var link : Link

func _ready():
	grab_focus()

func _on_pressed():
	link_tree_node.follow(link)
