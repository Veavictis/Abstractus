class_name WeaponPickup
extends Area2D
## The triangle weapon, waiting on the floor. Touching it lets the player shoot.

signal picked_up

var _time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.has_weapon = true
		picked_up.emit()
		queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -14 + round(sin(_time * 3.0) * 2.0)))
	# Placeholder: a few triangles. The real art replaces this.
	draw_colored_polygon(
		PackedVector2Array([Vector2(-7, 3), Vector2(7, 0), Vector2(-7, -3)]), Color("fff3c4")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-7, 3), Vector2(-2, 3), Vector2(-5, 8)]), Color("e8c170")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-7, -3), Vector2(-3, -3), Vector2(-7, -7)]), Color("e8c170")
	)
