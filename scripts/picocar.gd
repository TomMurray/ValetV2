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
const STEER_SPEED : float = 5.0

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
		
		# Take front wheels
		var front_wheels = wheels.slice(2, 4)
		
		for wheel in front_wheels:
			# TODO: Fix car scene so that the car is facing forwards
			# rather than backwards...
			# Take the difference, rotate wheel smoothly
			var target_rotation_y = -steer * MAX_STEER
			var diff = target_rotation_y - wheel.rotation.y
			var rotate_amount = diff * delta * STEER_SPEED
			if abs(diff) < 0.1:
				rotate_amount = diff
			wheel.rotation.y += rotate_amount
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
		
	pass
