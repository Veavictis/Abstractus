class_name Shard
extends Area2D
## A crystal. Optional: the level counts them, and any left on the ground fly to the player at the end.

signal collected

const MAGNET_SPEED := 60.0
const MAGNET_ACCEL := 600.0

var _time := randf() * TAU
var _magnet_target: Node2D
var _magnet_speed := MAGNET_SPEED


func _ready() -> void:
	body_entered.connect(_on_body_entered)


## Pulls the crystal to the target like a magnet; it counts as collected when it arrives.
func fly_to(target: Node2D) -> void:
	_magnet_target = target


func _process(delta: float) -> void:
	_time += delta
	if _magnet_target:
		_magnet_speed += MAGNET_ACCEL * delta
		position = position.move_toward(_magnet_target.position, _magnet_speed * delta)
		if position.distance_to(_magnet_target.position) < 2.0:
			_collect()
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_collect()


func _collect() -> void:
	if is_queued_for_deletion():
		return
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
