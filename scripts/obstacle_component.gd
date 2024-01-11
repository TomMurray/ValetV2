extends Node3D
class_name ObstacleComponent

# Receives hits from the player car with info on how to respond.
# For now there is no feedback to the hitter (no return from this
# function).

func hit(hit : Hit) -> void:
	print("Hit: ", Utils.dir(hit))
