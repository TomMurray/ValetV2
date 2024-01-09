@tool
extends Node3D
class_name XYZCubeFadeUp;

@onready var instance := %Cube
@export var base_colour := Color.WHITE:
	get: return base_colour
	set(value):
		base_colour = value
		if is_node_ready():
			setup_base_colour()
		
func setup_base_colour():
	var shader_mat := (instance.get_surface_override_material(0) as ShaderMaterial)
	var c := base_colour
	var to_uniform := Vector4(c.r, c.g, c.b, c.a)
	shader_mat.set_shader_parameter("base_colour", to_uniform)
		
func _ready():
	setup_base_colour()
