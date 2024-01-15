@tool
extends Node3D
class_name Follow

@export var target : Node3D
@export var offset := Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = target.position + offset
