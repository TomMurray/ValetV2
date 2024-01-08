extends Node3D
class_name Follow

@export var target : Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = target.position
