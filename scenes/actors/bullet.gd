class_name Bullet
extends Area2D
## A triangle shot from the player's weapon. Flies straight, hurts the first enemy it hits,
## and breaks on walls, crates and closed gates.

const SPEED := 220.0
const LIFETIME := 1.2
## How high above its ground position the bullet is drawn, roughly the weapon's height.
const HEIGHT := 10.0

var direction := Vector2.RIGHT
var _life := LIFETIME


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_hit(global_position - direction, Enemy.SHOT_DAMAGE)
	queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 2.5, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -HEIGHT), direction.angle())
	var points := PackedVector2Array([Vector2(4, 0), Vector2(-3, -3), Vector2(-3, 3)])
	draw_colored_polygon(points, Color("fff3c4"))
