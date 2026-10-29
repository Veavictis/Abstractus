class_name Wall
extends StaticBody2D
## One isometric wall block. The collision footprint is the tile diamond; the block is drawn rising above it.

const HEIGHT := 18.0

@export var top_color := Color("6b5b95")
@export var left_color := Color("4a3f6b")
@export var right_color := Color("3a3154")


func _draw() -> void:
	var up := Vector2(0, -HEIGHT)
	var left := Vector2(-16, 0)
	var bottom := Vector2(0, 8)
	var right := Vector2(16, 0)
	var top := Vector2(0, -8)
	draw_colored_polygon(PackedVector2Array([left, bottom, bottom + up, left + up]), left_color)
	draw_colored_polygon(PackedVector2Array([bottom, right, right + up, bottom + up]), right_color)
	draw_colored_polygon(
		PackedVector2Array([top + up, right + up, bottom + up, left + up]), top_color
	)
