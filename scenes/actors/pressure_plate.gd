class_name PressurePlate
extends Node2D
## A floor switch. The level marks it pressed while a block sits on its tile.

var pressed := false:
	set(value):
		pressed = value
		queue_redraw()


func _draw() -> void:
	var diamond := PackedVector2Array(
		[Vector2(0, -5), Vector2(10, 0), Vector2(0, 5), Vector2(-10, 0)]
	)
	draw_colored_polygon(diamond, Color("f2c14e") if pressed else Color("7a6a3a"))
	draw_polyline(diamond + PackedVector2Array([diamond[0]]), Color("fff0b0"))
