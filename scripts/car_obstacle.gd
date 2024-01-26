@tool
extends StaticBody3D
class_name CarObstacle

@onready var obstacle_component : ObstacleComponent = %ObstacleComponent
@export var level_logic : LevelLogic = null:
	set(value):
		level_logic = value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not level_logic:
		return ["No LevelLogic set on CarObstacle"]
	return []

func _ready():
	obstacle_component.level_logic = level_logic

func _on_obstacle_component_was_hit(hit):
	# For now, just remove the car model
	queue_free()
