extends Node2D
## The aiming target that replaces the mouse cursor inside a level. Hidden while aiming with a gamepad.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		visible = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		visible = false


func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position().round()
	queue_redraw()


func _draw() -> void:
	var color := Color("fff3c4")
	draw_arc(Vector2.ZERO, 4.0, 0.0, TAU, 12, color, 1.0)
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(dir * 6.0, dir * 8.0, color, 1.0)
	draw_rect(Rect2(-0.5, -0.5, 1, 1), color)
