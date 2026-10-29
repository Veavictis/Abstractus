extends Control
## Title screen with placeholder story. Accept starts level 1, Back quits.

var _time := 0.0

@onready var _prompt: Label = $Prompt
@onready var _version: Label = $Version


func _ready() -> void:
	_version.text = "v%s" % Game.version


func _process(delta: float) -> void:
	_time += delta
	_prompt.visible = fmod(_time, 1.2) < 0.8


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") or event.is_action_pressed("attack"):
		Game.start_game()
	elif event.is_action_pressed("back"):
		get_tree().quit()
