@tool
extends RichTextLabel
class_name ObstaclesCounter

@export var level_logic : LevelLogic

func update_text():
	if is_ready() and level_logic:
		var limit := level_logic.get_max_obstacles_hit()
		var curr := mini(level_logic.get_obstacles_hit(), limit)
		text = "%d/%d" % [curr, limit]
		# Make the text increasingly red as it approaches the limit
		var ratio : float = float(curr) / float(limit)
		add_theme_color_override("default_color", lerp(Color.WHITE, Color.RED, ratio))
		

func _ready():
	update_text()

func _on_level_logic_objectives_progress_changed():
	update_text()

func _get_configuration_warnings():
	if not level_logic:
		return ["No LevelLogic attached to ObstaclesCounter"]
	return []
