extends Node
class_name LevelLogic

signal objectives_progress_changed
signal objectives_failed

# Class responsible for tracking level objectives, and sending out signals for
# updated objectives (obstacles hit/max, level complete/failed etc.)

@export var objective : LevelObjective
var obstacles_hit : int = 0

func get_obstacles_hit() -> int:
	return obstacles_hit

func get_max_obstacles_hit() -> int:
	return objective.max_obstacles_hit

func on_obstacle_hit(obstacle : ObstacleComponent):
	obstacles_hit += 1
	objectives_progress_changed.emit()
	if obstacles_hit > get_max_obstacles_hit():
		objectives_failed.emit()
