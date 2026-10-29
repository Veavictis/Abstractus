class_name Bullet
extends Area2D
## A triangle bullet. Flies straight and breaks on walls, crates and closed gates.
## The player's bullets hurt enemies and flip wall switches; hostile (enemy) bullets hurt the player.

const SPEED := 220.0
const LIFETIME := 1.2
## How high above its ground position the bullet is drawn, roughly the weapon's height.
const HEIGHT := 10.0
## Walls, gates and switches (layer 1) and crates (layer 4).
const WORLD_MASK := 1 | 8
const ENEMY_LAYER := 4
const PLAYER_LAYER := 2

var direction := Vector2.RIGHT
var hostile := false
var _life := LIFETIME


func _ready() -> void:
	collision_mask = WORLD_MASK | (PLAYER_LAYER if hostile else ENEMY_LAYER)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if hostile and body is Player:
		body.take_hit(global_position - direction)
	elif not hostile and body is Enemy:
		body.take_hit(global_position - direction, Enemy.SHOT_DAMAGE)
	elif not hostile and body is WallSwitch:
		body.hit()
	queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 2.5, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -HEIGHT), direction.angle())
	var points := PackedVector2Array([Vector2(4, 0), Vector2(-3, -3), Vector2(-3, 3)])
	draw_colored_polygon(points, Color("ff6b6b") if hostile else Color("fff3c4"))
