extends Control

@onready var level_black_overlay : UIBlackOverlay = $level_black_overlay

func _ready():
	level_black_overlay.fade_out()


func _on_level_logic_complete(success):
	level_black_overlay.fade_in()
