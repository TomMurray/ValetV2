@tool
extends Node
class_name ColourOverrideComponent

@export var target_mesh : MeshInstance3D = null:
	set(value):
		if target_mesh:
			target_mesh.set_surface_override_material(material_slot, null)
		target_mesh = value
		if target_mesh:
			_setup_colour()

@export var material_slot : int = 0
@export var target_colour : Color = Color.WHITE:
	set(value):
		target_colour = value
		# Also change the visual appearance in the editor
		if target_mesh:
			_setup_colour()

func _setup_colour():
	# Reset to base material
	target_mesh.set_surface_override_material(material_slot, null)
	var base_material = target_mesh.get_active_material(material_slot) as BaseMaterial3D
	if not base_material:
		return
	var new_mtl := base_material.duplicate() as BaseMaterial3D
	new_mtl.albedo_color = target_colour
	target_mesh.set_surface_override_material(material_slot, new_mtl)
