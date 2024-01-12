extends Node3D
class_name ParkingArea

signal parked

var have_parked := false

func on_park():
	if not have_parked:
		have_parked = true
		parked.emit()

func handle_parked_status_changed(parked : bool):
	if parked:
		on_park()

func _on_area_body_entered(body):
	# Can only park if the body has a ParkableComponent
	var parkable_component := Utils.get_child_of_type(body, ParkableComponent) as ParkableComponent
	if parkable_component:
		if parkable_component.is_parked():
			on_park()
		else:
			parkable_component.parked_status_changed.connect(handle_parked_status_changed)



func _on_area_body_exited(body):
	var parkable_component := Utils.get_child_of_type(body, ParkableComponent)
	if parkable_component:
		
		var s : Signal = parkable_component.parked_status_changed
		if s.is_connected(handle_parked_status_changed):
			s.disconnect(handle_parked_status_changed)
