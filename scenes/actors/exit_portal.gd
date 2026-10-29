class_name ExitPortal
extends Area2D
## The level goal. Stays locked until `unlock()` is called, then ends the level when the player steps on it.

signal reached

var unlocked := false
var _time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func unlock() -> void:
	unlocked = true
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if unlocked and body is Player:
		reached.emit()


func _draw() -> void:
	var diamond := PackedVector2Array(
		[Vector2(0, -8), Vector2(16, 0), Vector2(0, 8), Vector2(-16, 0)]
	)
	if not unlocked:
		draw_colored_polygon(diamond, Color("3b3b4f"))
		draw_polyline(diamond + PackedVector2Array([diamond[0]]), Color("6a6a85"))
		return
	var glow := 0.6 + 0.4 * sin(_time * 4.0)
	draw_colored_polygon(diamond, Color(0.55, 1.0, 0.6, glow))
	for i in 3:
		var y := -fmod(_time * 12.0 + i * 8.0, 24.0)
		draw_line(Vector2(-6 + i * 6, y), Vector2(-6 + i * 6, y - 4), Color("c8ffd0"))
