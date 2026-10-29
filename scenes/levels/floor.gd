extends Node2D
## Draws the floor diamonds for a level in one pass, under everything that Y-sorts.

const LIGHT := Color("2e2a45")
const DARK := Color("27233b")
const EDGE := Color("37325a")
const SAFE_LIGHT := Color("2a4038")
const SAFE_DARK := Color("243830")

var cells: Array[Vector2i] = []
var safe_cells := {}  # Vector2i -> true


func set_cells(new_cells: Array[Vector2i], new_safe_cells: Array[Vector2i] = []) -> void:
	cells = new_cells
	safe_cells.clear()
	for cell in new_safe_cells:
		safe_cells[cell] = true
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
		var even := (cell.x + cell.y) % 2 == 0
		if safe_cells.has(cell):
			draw_colored_polygon(diamond, SAFE_LIGHT if even else SAFE_DARK)
		else:
			draw_colored_polygon(diamond, LIGHT if even else DARK)
		draw_polyline(PackedVector2Array([diamond[3], diamond[0], diamond[1]]), EDGE)
