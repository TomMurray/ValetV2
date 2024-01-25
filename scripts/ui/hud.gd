@tool
extends Control
class_name HUD

@export var link_tree_node : LinkTreeNode = null:
	set(value):
		link_tree_node = value
		update_configuration_warnings()

@export var level_logic : LevelLogic = null:
	set(value):
		level_logic = value
		update_configuration_warnings()

@onready var pause_screen : PauseScreen = %pause_screen
@onready var end_game_panel : EndGamePanel = %end_game_panel

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if not link_tree_node:
		warnings.append("No LinkTreeNode set on HUD")
	if not level_logic:
		warnings.append("No LevelLogic set on HUD")
	return warnings

func _ready():
	if not Engine.is_editor_hint():
		pause_screen.link_tree_node = link_tree_node
		end_game_panel.link_tree_node = link_tree_node
		end_game_panel.level_logic = level_logic
	
