extends CanvasLayer
## Temporary pause menu. Escape (or Start on a gamepad) opens and closes it.

const TITLE_SCENE := "res://scenes/main/main.tscn"

@onready var _resume: Button = %Resume


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	%Resume.pressed.connect(_close)
	%QuitToTitle.pressed.connect(_quit_to_title)
	%ExitGame.pressed.connect(get_tree().quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	visible = true
	get_tree().paused = true
	_resume.grab_focus()


func _close() -> void:
	visible = false
	get_tree().paused = false


func _quit_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)
