class_name PlayerShot
extends Area2D
## Test auto-attack shot: flies straight, hits the first enemy it touches.
## The art is drawn facing right; the shot rotates to its direction.

@export var speed := 300.0
@export var damage := 1
@export var lifetime := 2.0

var direction := Vector2.RIGHT


func _ready() -> void:
	rotation = direction.angle()
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is Enemy and not is_queued_for_deletion():
		area.hit(damage)
		queue_free()
