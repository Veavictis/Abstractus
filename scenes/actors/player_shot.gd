class_name PlayerShot
extends Area2D
## Test auto-attack shot: flies straight, hits the first enemy it touches.
## It disappears when it hits an obstacle.
## The art is drawn facing right; the shot rotates to its direction. `Glow` is a turquoise
## copy of the art behind it, and the rainbow trail fades out after the shot is gone.

## Collision layer 4, "obstacles".
const OBSTACLE_MASK := 8

@export var speed := 300.0
@export var damage := 1
@export var lifetime := 2.0

var direction := Vector2.RIGHT

@onready var _trail: RainbowTrail = $RainbowTrail


func _ready() -> void:
	rotation = direction.angle()
	$Glow.texture = $Sprite.texture
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(_destroy)


func _physics_process(delta: float) -> void:
	var start := global_position
	position += direction * speed * delta
	# A ray along this frame's step finds obstacles, even thin ones a fast shot would skip.
	var ray := PhysicsRayQueryParameters2D.create(start, global_position, OBSTACLE_MASK)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		_destroy()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and not is_queued_for_deletion():
		body.hit(damage)
		_destroy()


func _destroy() -> void:
	if is_queued_for_deletion():
		return
	_trail.detach()
	queue_free()
