extends Node3D
class_name ObjectiveArea

signal objective_reached

var did_it := false

func _on_area_body_entered(body):
	if !did_it:
		did_it = true
		objective_reached.emit()
