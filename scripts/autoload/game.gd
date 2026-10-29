extends Node
## Global game state, available everywhere as `Game`.
## Also registers the input actions, so keyboard and gamepad (Steam Deck) work without editor setup.

const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const FIRST_LEVEL := "res://scenes/levels/level_01.tscn"
const STICK_DEADZONE := 0.25

var version: String = ProjectSettings.get_setting("application/config/version", "0.0.0")


func _ready() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_add_action("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_add_action("move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_add_action("move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_add_action("accept", [KEY_ENTER, KEY_KP_ENTER], [JOY_BUTTON_A])
	_add_action("attack", [KEY_J, KEY_SPACE], [JOY_BUTTON_X])
	_add_action("restart", [KEY_R], [JOY_BUTTON_Y])
	_add_action("aim_left", [], [], JOY_AXIS_RIGHT_X, -1.0)
	_add_action("aim_right", [], [], JOY_AXIS_RIGHT_X, 1.0)
	_add_action("aim_up", [], [], JOY_AXIS_RIGHT_Y, -1.0)
	_add_action("aim_down", [], [], JOY_AXIS_RIGHT_Y, 1.0)
	_add_action("shoot", [], [], JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_add_mouse_action("shoot", MOUSE_BUTTON_LEFT)
	_add_action("back", [KEY_ESCAPE], [JOY_BUTTON_START, JOY_BUTTON_B])


func start_game() -> void:
	get_tree().change_scene_to_file(FIRST_LEVEL)


func go_to_title() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)


func _add_mouse_action(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)


func _add_action(
	action: StringName,
	keys: Array[Key],
	buttons: Array[JoyButton],
	axis: JoyAxis = JOY_AXIS_INVALID,
	axis_value: float = 0.0,
) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, STICK_DEADZONE)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)
	for button in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		InputMap.action_add_event(action, event)
	if axis != JOY_AXIS_INVALID:
		var event := InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = axis_value
		InputMap.action_add_event(action, event)
