class_name Gate
extends StaticBody2D
## Bars that block a tile until `open()` is called.

var is_open := false

@onready var _footprint: CollisionPolygon2D = $Footprint


func open() -> void:
	is_open = true
	_footprint.set_deferred("disabled", true)
	queue_redraw()


func _draw() -> void:
	var height := 2.0 if is_open else 22.0
	var color := Color("f2c14e")
	for i in 5:
		var base := Vector2(-12 + i * 6, -6 + i * 3)
		draw_line(base, base + Vector2(0, -height), color, 2.0)
	if not is_open:
		draw_line(Vector2(-12, -6 - height), Vector2(12, 6 - height), color, 2.0)
