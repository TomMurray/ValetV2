@tool
extends RigidBody3D

@export var impulse_mass_factor : float = 1.0

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


func _on_obstacle_component_was_hit(hit : Hit):
	# Apply an exaggerated impulse to the cone on collision.
	# Rather than the hit normal we'll use the direction from the hitter (the car)
	# to the collision point as a direction, then discard the vertical component and
	# point it upwards by a constant angle.
	var outward_dir = hit.pos - hit.hitter.global_position
	var impulse_dir_xz = Vector3(outward_dir.x, 0, outward_dir.z).normalized()
	var impulse_dir = impulse_dir_xz.rotated(impulse_dir_xz.cross(Vector3.UP).normalized(), deg_to_rad(60))
	apply_impulse(impulse_dir * mass * impulse_mass_factor, hit.pos - global_position)
