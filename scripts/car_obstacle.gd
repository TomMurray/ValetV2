@tool
extends StaticBody3D
class_name CarObstacle

@onready var obstacle_component : ObstacleComponent = %ObstacleComponent

@export var explosion_scene : PackedScene

@export var level_logic : LevelLogic = null:
	set(value):
		level_logic = value
		update_configuration_warnings()

var was_hit_once := false

func _get_configuration_warnings() -> PackedStringArray:
	if not level_logic:
		return ["No LevelLogic set on CarObstacle"]
	return []

func _ready():
	obstacle_component.level_logic = level_logic

func _on_obstacle_component_was_hit(hit):
	if not was_hit_once:
		# Spawn explosion scene where the obstacle is
		var explosion = explosion_scene.instantiate() as Node3D
		add_child(explosion)
	was_hit_once = true
	
