class_name WallSwitch
extends Wall
## A wall block with a target on it. Shoot it to flip it on; the level resets it if time runs out.

signal flipped

var is_on := false


func hit() -> void:
	if is_on:
		return
	is_on = true
	queue_redraw()
	flipped.emit()


func reset() -> void:
	is_on = false
	queue_redraw()


func _draw() -> void:
	super()
	var center := Vector2(0, -HEIGHT - 2)
	var color := Color("7cf29c") if is_on else Color("e8485f")
	draw_circle(center, 5.0, Color("1b1b2a"))
	draw_circle(center, 4.0, color)
	draw_circle(center, 1.5, Color("1b1b2a") if not is_on else Color("eaffef"))
