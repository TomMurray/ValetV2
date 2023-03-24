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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# Here is where we deal with input and manage driving the car
	# when using CharacterBody3D to control the car.
	
	# We are going to implement our car's motion 2-dimensionally for
	# the learning experience. 2-dimensionally meaning x/z axes as this
	# is a top-down game.
	
	# We want the motion of the car to mirror that of a real car. I will
	# not (at least initially) implement anything like drift etc. So the
	# motion wanted is where either the front wheels pull or the back
	# wheels push, and the car's front moves in the direction the front
	# wheels are pointed, and the car's back slowly converges to that
	# direction also.
	
	# I guess we can think of the maths for this initially like a series
	# of discrete steps where we move the front of the car in the direction
	# of the front wheels, and then move the back of the car to line up
	# with this and maintain the length of the car. Considering this in
	# ever finer time steps should lead us to some formula for x/y.
	# Even now I'm aware this probably does not give the motion we want
	# because the back wheels will spin more or less depending on the
	# direction of steering. The forces on each wheel need to be
	# reconciled all together to produce the final rotation/position of
	# the car each physics step.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
