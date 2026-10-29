class_name Shard
extends Area2D
## A collectible. The level counts these; collecting all of them opens the exit.

signal collected

var _time := randf() * TAU


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collected.emit()
		queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 5.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO)
	var lift := Vector2(0, -14 + round(sin(_time * 3.0) * 2.0))
	var gem := PackedVector2Array([Vector2(0, -7), Vector2(5, 0), Vector2(0, 7), Vector2(-5, 0)])
	for i in gem.size():
		gem[i] += lift
	draw_colored_polygon(gem, Color("5ee2f0"))
	draw_line(gem[0], gem[2], Color("d8fbff"))
