extends Node3D
class_name Area3DFullyContained

var in_exclusion_area : Dictionary
var in_inclusion_area : Dictionary
var tracked : Dictionary

signal body_entered(body: Node3D)
signal body_exited(body: Node3D)

func update_tracked(body : Node3D):
	if tracked.has(body):
		if in_exclusion_area.has(body) or !in_inclusion_area.has(body):
			body_exited.emit(body)
			tracked.erase(body)
	else:
		if !in_exclusion_area.has(body) and in_inclusion_area.has(body):
			body_entered.emit(body)
			tracked[body] = true

func _on_exclusion_area_body_entered(body):
	in_exclusion_area[body] = true
	update_tracked(body)

func _on_exclusion_area_body_exited(body):
	in_exclusion_area.erase(body)
	update_tracked(body)

func _on_inclusion_area_body_entered(body):
	in_inclusion_area[body] = true
	update_tracked(body)

func _on_inclusion_area_body_exited(body):
	in_inclusion_area.erase(body)
	update_tracked(body)
