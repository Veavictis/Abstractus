class_name Enemy
extends CharacterBody2D
## Test enemy: walks straight at the player and dies after `max_health` hits.
## It slides along obstacles instead of walking through them, and drops one point dot
## from `drop_table` and bursts into pixels of its own colors when it dies.
## Every number here is a placeholder to tune in the Inspector.

signal killed

const DROP_SCENE := preload("res://scenes/pickups/point_drop.tscn")
const BURST_SCENE := preload("res://scenes/effects/pixel_burst.tscn")

@export var speed := 50.0
@export var max_health := 2
## Kinds of point dots this enemy can drop, picked by their weights.
@export var drop_table: Array[PointDropKind] = []

var target: Node2D
var health := max_health

@onready var _sprite: ArtSprite = $Sprite


func _ready() -> void:
	health = max_health
	add_to_group("enemies")


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		return
	var direction := global_position.direction_to(target.global_position)
	velocity = direction * speed
	move_and_slide()
	if direction.x != 0.0:
		_sprite.flip_h = direction.x < 0.0


func hit(damage: int) -> void:
	health -= damage
	_sprite.modulate = Color(3, 3, 3)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.1)
	if health <= 0:
		killed.emit()
		_drop_points()
		_burst()
		queue_free()


func _drop_points() -> void:
	var total := 0.0
	for kind in drop_table:
		total += kind.weight
	var roll := randf() * total
	for kind in drop_table:
		roll -= kind.weight
		if roll < 0.0:
			var drop: PointDrop = DROP_SCENE.instantiate()
			drop.kind = kind
			drop.position = position
			# Deferred: this runs inside a physics callback, where areas can't be added.
			get_parent().add_child.call_deferred(drop)
			return


func _burst() -> void:
	var burst: PixelBurst = BURST_SCENE.instantiate()
	burst.position = position
	get_parent().add_child(burst)
	burst.burst_from(_sprite.texture)
