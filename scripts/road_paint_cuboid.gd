@tool
extends MeshInstance3D

func _process(delta):
	# Sync shader parameters with the node
	var material = mesh.surface_get_material(0) as ShaderMaterial
	if material:
		material.set_shader_parameter("transform", global_transform)
