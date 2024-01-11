@tool
extends RigidBody3D

@onready var obstacle_component := %ObstacleComponent as ObstacleComponent
@export var level_logic : LevelLogic:
	get: return level_logic
	set(value):
		level_logic = value
		if obstacle_component:
			obstacle_component.level_logic = level_logic
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if obstacle_component:
		warnings.append_array(obstacle_component._get_configuration_warnings())
	return warnings
	
func _ready():
	obstacle_component.level_logic = level_logic
	update_configuration_warnings()
