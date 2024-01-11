extends Node3D
class_name ParkingArea

signal parked

var have_parked := false

func _on_area_body_entered(body):
	if !have_parked:
		have_parked = true
		parked.emit()
