extends Node
class_name LevelLogic

# Class responsible for tracking level objectives, and sending out signals for
# updated objectives (obstacles hit/max, level complete/failed etc.)

signal objectives_progress_changed
signal complete(success : bool)

@export var objective : LevelObjective
var was_completed : bool = false
var outcome : bool = false
var obstacles_hit : int = 0

func get_obstacles_hit() -> int:
	return obstacles_hit

func get_max_obstacles_hit() -> int:
	return objective.max_obstacles_hit

func is_complete() -> bool:
	return was_completed
	
func get_outcome() -> bool:
	return outcome

func on_obstacle_hit(obstacle : ObstacleComponent):
	obstacles_hit += 1
	objectives_progress_changed.emit()
	if obstacles_hit >= get_max_obstacles_hit():
		on_complete(false)

func on_complete(success : bool):
	if not was_completed:
		was_completed = true
		outcome = success
		complete.emit(outcome)

func on_parked():
	on_complete(true)
