extends ColorRect
class_name UIBlackOverlay

signal faded_out
signal faded_in

@onready var animation_player : AnimationPlayer = %AnimationPlayer

func fade_in(callback = null):
	animation_player.queue("fade_in")
	if callback:
		await faded_in
		(callback as Callable).call()
	
func fade_out(callback = null):
	animation_player.queue("fade_out")
	if callback:
		await faded_out
		(callback as Callable).call()


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			faded_in.emit()
		"fade_out":
			faded_out.emit()
