@tool
extends CharacterBody3D

@export var colour := Color.WHITE:
	set(value):
		colour = value
		# Also change the visual appearance in the editor
		var body := $body as MeshInstance3D
		# Reset to base material
		body.set_surface_override_material(0, null)
		var new_mtl := body.get_active_material(0).duplicate() as BaseMaterial3D
		new_mtl.albedo_color = colour
		body.set_surface_override_material(0, new_mtl)

# Array of wheel nodes accessible by flattened 2-d index
# [y, x] e.g. front-right = (1, 1) flattened index = 3
@onready var wheels = [$wheel_bl, $wheel_br, $wheel_fl, $wheel_fr]
enum Wheel {
	BACK_L,
	BACK_R,
	FRONT_L,
	FRONT_R
}

const MAX_STEER : float = deg_to_rad(40.0)
const STEER_DEG_PER_SEC : float = deg_to_rad(120.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# We need to consider the forces on each wheel (acceleration on front
	# wheels, in the direction they're going, friction preventing tyres
	# from sliding against the ground) and integrate these to give the motion
	# of the car as a whole.
	
	# Apply correct visual rotation to the front wheels
	if not Engine.is_editor_hint():
		var steer = Input.get_axis("steer_left", "steer_right");
		var accel = Input.get_axis("brake_reverse", "accelerate");
		
		
		var back_wheels = wheels.slice(0, 2)
		var front_wheels = wheels.slice(2, 4)
		
		# Left wheel of each set has canonical rotation
		var curr_steer_angle = front_wheels[0].rotation.y
		curr_steer_angle = clamp(curr_steer_angle - steer * STEER_DEG_PER_SEC * delta, -MAX_STEER, MAX_STEER)
		for wheel in front_wheels:
			wheel.rotation.y = curr_steer_angle
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
		
	pass
