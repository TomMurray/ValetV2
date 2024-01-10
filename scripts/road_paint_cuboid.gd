@tool
extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Duplicate the material on load - we want to uniquely pass on the uniforms
	set_surface_override_material(0, mesh.surface_get_material(0).duplicate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("process called in editor")
	# Sync shader parameters with the node
	var material = get_surface_override_material(0) as ShaderMaterial
	if material:
		material.set_shader_parameter("transform", transform)
