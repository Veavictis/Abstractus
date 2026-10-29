class_name Hazard
extends Area2D
## Patrols back and forth between two points and hurts the player on touch.

const SPEED := 45.0

var point_a := Vector2.ZERO
var point_b := Vector2.ZERO
var _target := Vector2.ZERO
var _spin := 0.0


func setup(start: Vector2, a: Vector2, b: Vector2) -> void:
	position = start
	point_a = a
	point_b = b
	_target = b


func _physics_process(delta: float) -> void:
	position = position.move_toward(_target, SPEED * delta)
	if position.is_equal_approx(_target):
		_target = point_a if _target == point_b else point_b
	_spin += delta * 4.0
	# Checked every frame (not just on enter) so standing in it after the hit blink still hurts.
	for body in get_overlapping_bodies():
		if body is Player:
			body.take_hit(global_position)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2(0, -10), _spin)
	var spikes := PackedVector2Array()
	for i in 8:
		var radius := 8.0 if i % 2 == 0 else 4.0
		spikes.append(Vector2.from_angle(i * TAU / 8.0) * radius)
	draw_colored_polygon(spikes, Color("e8485f"))
	draw_circle(Vector2.ZERO, 2.0, Color("ffd0d6"))
