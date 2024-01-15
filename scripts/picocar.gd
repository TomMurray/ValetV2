@tool
extends CharacterBody3D
class_name PicoCar

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

@export_category("wheels")
@export var wheel_front_right : Node3D
@export var wheel_front_left : Node3D
@export var wheel_back_right : Node3D
@export var wheel_back_left : Node3D

@export_category("lights")
@export var brake_lights : Array[OmniLight3D]

@export_category("General motion")
@export var max_steer_angle : float = 40.0
@export var steer_per_sec : float = 120.0
@export var friction_per_sec : float = 0.6
@export var secs_to_change_dir : float = 1.0

@export_category("Forward motion")
@export var max_speed_per_sec_fwd : float = 8
@export var accel_per_sec_fwd : float = 5

@export_category("Backward motion")
@export var max_speed_per_sec_bwd : float = 3
@export var accel_per_sec_bwd : float = 5

@export_category("Braking")
@export var brake_decel_per_sec : float = 15

signal parked_status_changed(parked : bool)

# Array of wheel nodes accessible by flattened 2-d index
# [y, x] e.g. front-right = (1, 1) flattened index = 3
@onready var wheels : Array[Node3D] = [
	wheel_back_left,
	wheel_back_right,
	wheel_front_left,
	wheel_front_right
]

@onready var wheel_radius : float = wheels[0].scale.y

var prev_accel_dir : float = 0.0
var change_dir_timer : SceneTreeTimer = null

func get_node3d_midpoint(a : Array[Node3D]):
	return a.map(func(x : Node3D): return x.transform.origin).reduce(func(a, b): return a + b) / a.size()

func _physics_process(delta):
	# Apply correct visual rotation to the front wheels
	if not Engine.is_editor_hint():
		var steer := Input.get_axis("steer_left", "steer_right")
		var accel := Input.get_axis("brake_reverse", "accelerate")
		
		var back_wheels = wheels.slice(0, 2)
		var front_wheels = wheels.slice(2, 4)
		
		# Left wheel of each set has canonical rotation
		var curr_steer_angle = front_wheels[0].rotation.y
		var max_steer_rads = deg_to_rad(max_steer_angle)
		curr_steer_angle = clamp(curr_steer_angle - steer * deg_to_rad(steer_per_sec) * delta, -max_steer_rads, max_steer_rads)
			
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
		
		# Calculate current velocity in the direction the car is facing.
		# 'basis' is not facing in the direction of 'velocity' when
		# turning the car unless going straight ahead, so we're simplifying
		# just to get a signed velocity so we know whether we're reversing or
		# travelling forwards.
		var prev_forward_velocity := signf(velocity.dot(basis.z)) * velocity.length()
		
		# Firstly, use a different accel/max speed for reversing the car
		var accel_fwd := accel >= 0.0
		var is_braking := !is_zero_approx(prev_forward_velocity) and (prev_forward_velocity >= 0.0) != accel_fwd
		var accel_per_sec = accel_per_sec_fwd if accel_fwd else accel_per_sec_bwd
		if is_braking:
			# Scale brake deceleration by how close to 0 velocity we are to smooth it out
			# FIXME: Magic numbers, what does '5.0' velocity mean really?
			var factor := maxf(0.3, minf(5.0, absf(prev_forward_velocity)) / 5.0)
			accel_per_sec = brake_decel_per_sec * factor
		
		for light in brake_lights:
			light.light_energy = 0.5 if is_braking else 0.1
	
		# Apply acceleration
		var velocity_delta = accel * accel_per_sec * delta
		
		# If we're in the process of changing direction and the player is still acceleration in the
		# 'brake' direction, do not apply any acceleration
		if change_dir_timer != null:
			if prev_accel_dir != accel or change_dir_timer.time_left <= 0.0:
				change_dir_timer = null
			else:
				velocity_delta = 0.0
			
		var forward_velocity = prev_forward_velocity + velocity_delta
		
		# If acceleration brings the car to a stop, and we're braking, introduce
		# a little pause before starting to move in the other direction.
		if is_braking and (!is_zero_approx(prev_forward_velocity)
							and (is_zero_approx(forward_velocity)
							or sign(prev_forward_velocity) != sign(forward_velocity))):
			# Start timeout
			change_dir_timer = get_tree().create_timer(secs_to_change_dir, false, true)
			prev_accel_dir = accel
			# Come to a full stop
			forward_velocity = 0.0
		
		# Clamp to max speed depending on direction of acceleration
		if accel >= 0.0:
			forward_velocity = min(forward_velocity, max_speed_per_sec_fwd)
		else:
			forward_velocity = max(forward_velocity, -max_speed_per_sec_bwd)
			
		# Apply friction
		forward_velocity *= pow(friction_per_sec, delta)
		
		var was_moving := !is_zero_approx(prev_forward_velocity)
		var is_moving := !is_zero_approx(forward_velocity)
		if was_moving != is_moving:
			parked_status_changed.emit(!is_moving)
		
		# Move the front/back wheels of the "bicycle" by the desired
		# amount in the direction they are facing. Note this is done
		# relative to the transform of the car node itself.
		var forward_velocity_d = forward_velocity * delta
		back_midpoint.y += forward_velocity_d
		front_midpoint.x += sin(curr_steer_angle) * forward_velocity_d
		front_midpoint.y += cos(curr_steer_angle) * forward_velocity_d
		
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
		
		# Set visual rotation of all wheels.
		# If a wheel rotates by an angle (in radians) 'a' the distance it
		# travels is d = a * r, so to find 'a' by which to rotate the wheel
		# from d simply use a = d/r.
		var visual_rotation = (forward_velocity * delta) / wheel_radius
		for wheel in wheels:
			# We should first rotate around x axis, then for front wheels
			# rotate around y axis
			wheel.rotation.x += visual_rotation
		
		# Set visual steer of front wheels.
		for wheel in front_wheels:
			wheel.rotation.y = curr_steer_angle
		
		# Velocity is independent of delta, but our calculated delta is
		# already multiplied by delta, hence the division to undo this.
		# We multiply the movement delta by the basis rotation to move in
		# the direction the wheels are facing.
		#
		# Note use of get_rotation_quaternion because basis of the car also
		# encodes scale, and we want to apply rotation independent of scale.
		var motion := (basis.get_rotation_quaternion() * Vector3(pos_delta.x, 0, pos_delta.y))
		
		# The following allows us to react to collisions without impeding the
		# motion of the vehicle:
		
		# The behaviour we want for our car is:
		#  - Report collisions with RigidBody but acts with essentially infinite mass (push them away)
		#  - Collide and slide with StaticBody (e.g. walls and other static props) 
		#  - Stick to starting plane, i.e. movement is 2D in the X/Z plane
		#
		# To achieve this we use move_and_collide directly and differentiate between responses to
		# moveable obstacles and immoveable ones.
		var prev_pos := position
		const test_only = false
		const recovery_as_collision = true
		const margin := 0.001
		var ignored_nodes := []
		const max_retries := 50
		var retries := 0
		while true:
			var result := move_and_collide(motion, test_only, margin, recovery_as_collision, 6)
			if not result:
				break
			var c := result.get_collider(0)
			var r := c as RigidBody3D
			if r:
				# If colliding with a RigidBody, undo travel & try again ignoring the RigidBody
				position = prev_pos
				add_collision_exception_with(c)
				ignored_nodes.push_back(c)
			else:
				# Move out of collision (I believe because we enabled recovery_as_collision)
				# We don't want to ever move vertically however, we'll rely on
				position += result.get_normal(0) * result.get_depth()
				# For now just stop dead - it actually seems reasonable because the car's tyres should
				# stop it from sliding left/right very much - maybe we can allow a bit of slip for
				# when the car is mostly parallel with a wall for instance
				motion = Vector3.ZERO
			
			# Check if the node we're colliding with has an ObstacleComponent and notify it if so
			var oc := Utils.get_child_of_type(c, ObstacleComponent) as ObstacleComponent
			if oc:
				oc.hit(Hit.new(self, result.get_normal(0), result.get_depth()))
			
			prev_pos = position
			result = move_and_collide(motion, test_only, margin, recovery_as_collision, 6)
			retries += 1
			if retries >= max_retries or not result or result.get_collision_count() == 0:
				break
				
		# We want to receive collisions with RigidBodies in the next frame,
		# so remove the collision exceptions once handling is complete
		for n in ignored_nodes:
			remove_collision_exception_with(n)
		
		# Setup velocity for the next frame, rather than directly using the velocity applied
		# to move the car this frame because otherwise we lose velocity when turning the car
		# due to the approximation higher up which feels bad man.
		if motion != Vector3.ZERO:
			velocity = basis.get_rotation_quaternion() * (Vector3.BACK * forward_velocity)
		else:
			velocity = Vector3.ZERO
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
		
	pass
