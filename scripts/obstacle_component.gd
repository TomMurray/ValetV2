@tool
extends Node3D
class_name ObstacleComponent

signal was_hit(hit : Hit)

var level_logic : LevelLogic = null:
	get: return level_logic
	set(value): level_logic = value; update_configuration_warnings()

func _ready():
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not level_logic:
		return ["Level Logic required for ObstacleComponent"]
	return []

# Receives hits from the player car with info on how to respond.
# For now there is no feedback to the hitter (no return from this
# function).
func hit(hit : Hit) -> void:
	level_logic.on_obstacle_hit(self)
	was_hit.emit(hit)
