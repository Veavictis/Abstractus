extends Node2D
## Entry scene: a placeholder title screen with Play and Exit.

const GAME_SCENE := "res://scenes/levels/test_level.tscn"


func _ready() -> void:
	print("Abstractus v%s" % Game.version)
	%Play.pressed.connect(get_tree().change_scene_to_file.bind(GAME_SCENE))
	%Exit.pressed.connect(get_tree().quit)
	%Play.grab_focus()
