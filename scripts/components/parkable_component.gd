extends Node3D
class_name ParkableComponent

# Simple component that indicates this object can be parked
# This provides methods to query whether the object is parked
# and signals for when it becomes parked

signal parked_status_changed(parked : bool)

var parked : bool:
	get: return parked
	set(value):
		var status_changed := parked != value
		parked = value
		if status_changed:
			parked_status_changed.emit(parked)

func is_parked() -> bool:
	return parked

func set_is_parked(parked_ : bool):
	parked = parked_
