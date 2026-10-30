class_name Enemy
extends Area2D
## Test enemy: walks straight at the player and dies after `max_health` hits.
## Every number here is a placeholder to tune in the Inspector.

signal killed

@export var speed := 50.0
@export var max_health := 2

var target: Node2D
var health := max_health

@onready var _sprite: ArtSprite = $Sprite


func _ready() -> void:
	health = max_health
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var direction := global_position.direction_to(target.global_position)
	position += direction * speed * delta
	if direction.x != 0.0:
		_sprite.flip_h = direction.x < 0.0


func hit(damage: int) -> void:
	health -= damage
	_sprite.modulate = Color(3, 3, 3)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.1)
	if health <= 0:
		killed.emit()
		queue_free()
