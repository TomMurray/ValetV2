@tool
extends Camera3D
class_name LookAtCamera

@export var target : Node3D:
	get: return target
	set(value):
		target = value
		update_configuration_warnings()

func _ready():
	update_configuration_warnings()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		look_at(target.position, Vector3.UP)

func _get_configuration_warnings():
	if target == null:
		return ["No target set for LookAtCamera"]
	return []
