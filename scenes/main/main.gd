extends Control
## Entry scene: the TEMP title screen (replace later). Glowing logo, then Play, Options and Exit.
## Options is a placeholder panel with the music volume until we decide what goes in it.
##
## Title music: select the `Music` node in main.tscn and drag a track onto its Stream
## (for an .ogg, turn on Loop in its Import tab). It plays on the Music bus, so the
## volume slider controls it.

const GAME_SCENE := "res://scenes/levels/test_level.tscn"


func _ready() -> void:
	print("Abstractus v%s" % Game.version)
	%Play.pressed.connect(get_tree().change_scene_to_file.bind(GAME_SCENE))
	%Options.pressed.connect(_open_options)
	%Exit.pressed.connect(get_tree().quit)
	%Back.pressed.connect(_close_options)
	%MusicVolume.value = Game.music_volume
	%MusicVolume.value_changed.connect(Game.set_music_volume)
	%OptionsPanel.visible = false
	%Play.grab_focus()
	if %Music.stream:
		%Music.play()


func _unhandled_input(event: InputEvent) -> void:
	# Escape (or B) backs out of Options.
	if %OptionsPanel.visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		_close_options()
		get_viewport().set_input_as_handled()


func _open_options() -> void:
	%Menu.visible = false
	%OptionsPanel.visible = true
	%MusicVolume.grab_focus()


func _close_options() -> void:
	%OptionsPanel.visible = false
	%Menu.visible = true
	%Options.grab_focus()
