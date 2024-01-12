@tool
extends Node
class_name LevelPortComponent

@export var target_level : String:
	get: return target_level
	set(value):
		target_level = value
		update_configuration_warnings()
		
var queued := false

func _get_configuration_warnings() -> PackedStringArray:
	if target_level.is_empty():
		return ["Target level not set on LevelPortComponent"]
	return []

func go():
	prepare()
	SceneManager.switch()

func prepare():
	if not queued:
		SceneManager.queue(target_level)
		SceneManager.preload_queued()
		queued = true
