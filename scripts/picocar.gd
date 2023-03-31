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
@onready var wheels : Array[Node3D] = [
	$wheel_bl as Node3D,
	$wheel_br as Node3D,
	$wheel_fl as Node3D,
	$wheel_fr as Node3D
]

enum Wheel {
	BACK_L,
	BACK_R,
	FRONT_L,
	FRONT_R
}

const MAX_STEER : float = deg_to_rad(40.0)
const STEER_PER_SEC : float = deg_to_rad(120.0)

const MAX_SPEED_PER_SEC : float = 10
const ACCEL_PER_SEC : float = 20
const FRICTION_PER_SEC : float = 0.6

var z_velocity : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_node3d_midpoint(a : Array[Node3D]):
	return a.map(func(x : Node3D): return x.transform.origin).reduce(func(a, b): return a + b) / a.size()

func _physics_process(delta):
	# We need to consider the forces on each wheel (acceleration on front
	# wheels, in the direction they're going, friction preventing tyres
	# from sliding against the ground) and integrate these to give the motion
	# of the car as a whole.
	
	# Apply correct visual rotation to the front wheels
	if not Engine.is_editor_hint():
		var steer = Input.get_axis("steer_left", "steer_right")
		var accel = Input.get_axis("brake_reverse", "accelerate")
		
		
		var back_wheels = wheels.slice(0, 2)
		var front_wheels = wheels.slice(2, 4)
		
		# Left wheel of each set has canonical rotation
		var curr_steer_angle = front_wheels[0].rotation.y
		curr_steer_angle = clamp(curr_steer_angle - steer * STEER_PER_SEC * delta, -MAX_STEER, MAX_STEER)
		
		# Set visual rotation of front wheels
		for wheel in front_wheels:
			wheel.rotation.y = curr_steer_angle
			
		# Calculate updated rotation of car as a whole. This is based
		# on a simple 2-wheel "bicycle" physics model as elaborated nicely
		# here: http://engineeringdotnet.blogspot.com/2010/04/simple-2d-car-physics-in-games.html
		# The 4-wheel model involves integrating forces on all 4 wheels but
		# I don't believe it adds much to the feeling of steering the car.
		
		# The method is to find the midpoint of the front and back wheels,
		# move them both by the desired velocity, then rotate and move the
		# car to match the 2 new positions. The distance does not remain
		# equal between front and back in this process - you can prove this
		# fairly easily by imagining 2 perpendicular lines of length l:
		#
		#  ^
		#  |
		#  |
		#  |
		#  a<---b
		# 
		# Here ||b - a|| = l
		# Moving halfway along each of these lines gives:
		#
		#  ^
		#  |
		#  a'
		#  |
		#  <-b'-
		#
		# Here ||b' - a'|| = sqrt(2 * (l/2)^2) != l
		#
		# However this doesn't really matter as we only use
		# this to give a new position and rotation for the next frame
		# and then start again.
		var back_midpoint = get_node3d_midpoint(back_wheels)
		var front_midpoint = get_node3d_midpoint(front_wheels) as Vector3
		back_midpoint = Vector2(back_midpoint.x, back_midpoint.z)
		front_midpoint = Vector2(front_midpoint.x, front_midpoint.z)
		var old_pos_rel = (front_midpoint + back_midpoint)/2
		
		# TODO: Special behaviour for accelerate/brake/reverse. If the car
		# is currently moving forwards, pressing backwards will brake
		# until the car stops. There should be a delay once the car has
		# come to a complete stop before the car starts reversing.
		
		# Move the front/back wheels of the "bicycle" by the desired
		# amount in the direction they are facing. Note this is done
		# relative to the transform of the car node itself.
		z_velocity = min(MAX_SPEED_PER_SEC, z_velocity + accel * ACCEL_PER_SEC * delta)
		z_velocity *= pow(FRICTION_PER_SEC, delta)
		var v = z_velocity * delta
		
		back_midpoint.y += v
		# Must be a more succinct way of doing this, but using sin/cos
		# for now
		front_midpoint.x += sin(curr_steer_angle) * v
		front_midpoint.y += cos(curr_steer_angle) * v
		
		# Calculate new body rotation delta - this assumes the original
		# vector between back and front bicycle wheel was y axis vector.
		# We treat the new line between back and front bicycle wheel and
		# y axis as a right-angled triangle and calculate the delta in
		# rotation from this (using inverse tangent)
		var new_bike_dir = front_midpoint - back_midpoint
		var new_body_rot = atan(new_bike_dir.x/new_bike_dir.y)
		rotate(Vector3.UP, new_body_rot)
		
		# Because our bike wheel's positions are relative to car body
		# node here, our velocity for this physics update is just the
		# delta between the old midpoint of the bicycle wheels and the
		# new one. 
		var new_pos_rel = (front_midpoint + back_midpoint) / 2
		var pos_delta = new_pos_rel - old_pos_rel
		
		# Velocity is independent of delta, but our calculated delta is
		# already multiplied by our delta, so undo this.
		# We multiply the movement delta by the basis rotation to move in
		# the direction the car is facing.
		#
		# Note use of get_rotation_quaternion because basis of the car also
		# encodes scale, and we want to apply rotation independent of scale.
		velocity = basis.get_rotation_quaternion() * Vector3(pos_delta.x, 0, pos_delta.y) * (1/delta)
		
		move_and_slide()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
		
	pass
