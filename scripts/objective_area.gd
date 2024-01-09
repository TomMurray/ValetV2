extends Node3D
class_name ObjectiveArea


func _on_area_body_entered(body):
	print("Body entered", body)


func _on_area_body_exited(body):
	print("Body exited", body)
