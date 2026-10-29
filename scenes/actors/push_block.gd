class_name PushBlock
extends AnimatableBody2D
## A crate the player shoves one tile at a time by walking into it.
## The level decides whether the move is allowed, so blocks stay on the grid.

signal push_requested(block: PushBlock, dir: Vector2i)

const SLIDE_TIME := 0.15

var cell := Vector2i.ZERO
var moving := false


## `dir` is one grid step, e.g. `Vector2i.RIGHT` for +x.
func push(dir: Vector2i) -> void:
	if not moving and dir != Vector2i.ZERO:
		push_requested.emit(self, dir)


func slide_to(new_cell: Vector2i, target: Vector2) -> void:
	cell = new_cell
	moving = true
	var tween := create_tween()
	tween.tween_property(self, "position", target, SLIDE_TIME)
	tween.tween_callback(func() -> void: moving = false)


func _draw() -> void:
	var up := Vector2(0, -14)
	var left := Vector2(-13, 0)
	var bottom := Vector2(0, 6.5)
	var right := Vector2(13, 0)
	var top := Vector2(0, -6.5)
	draw_colored_polygon(
		PackedVector2Array([left, bottom, bottom + up, left + up]), Color("b07a3c")
	)
	draw_colored_polygon(
		PackedVector2Array([bottom, right, right + up, bottom + up]), Color("8a5a2b")
	)
	draw_colored_polygon(
		PackedVector2Array([top + up, right + up, bottom + up, left + up]), Color("d9a05b")
	)
	draw_line(left + up, right + up, Color("8a5a2b"))
