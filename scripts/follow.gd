@tool
extends Node3D
class_name PlayerFollowCamera

@onready var camera : LookAtCamera = %camera

@export var target : Node3D:
	set(value):
		target = value
		if camera:
			camera.target = target
		update_configuration_warnings()

func _get_configuration_warnings():
	if not target:
		return ["No target set for PlayerFollowCamera"]
	return []

func _ready():
	if camera:
		camera.target = target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		position = target.position
