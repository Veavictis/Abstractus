extends Node2D
## Draws the floor diamonds for a level in one pass, under everything that Y-sorts.

const LIGHT := Color("2e2a45")
const DARK := Color("27233b")
const EDGE := Color("37325a")

var cells: Array[Vector2i] = []


func set_cells(new_cells: Array[Vector2i]) -> void:
	cells = new_cells
	queue_redraw()


func _draw() -> void:
	for cell in cells:
		var center := Level.grid_to_world(cell)
		var diamond := PackedVector2Array(
			[
				center + Vector2(0, -8),
				center + Vector2(16, 0),
				center + Vector2(0, 8),
				center + Vector2(-16, 0)
			]
		)
		draw_colored_polygon(diamond, LIGHT if (cell.x + cell.y) % 2 == 0 else DARK)
		draw_polyline(PackedVector2Array([diamond[3], diamond[0], diamond[1]]), EDGE)
