class_name Enemy
extends CharacterBody2D
## Test enemy: walks at the player and dies after `max_health` hits.
## It follows the background's navigation mesh around obstacles (straight at the player
## when there's no mesh under it) and slides along anything it still bumps. It drops one point dot
## from `drop_table` and bursts into pixels of its own colors when it dies.
## Every number here is a placeholder to tune in the Inspector.

signal killed

const DROP_SCENE := preload("res://scenes/pickups/point_drop.tscn")
const BURST_SCENE := preload("res://scenes/effects/pixel_burst.tscn")

@export var speed := 50.0
## Health can be fractional: the beat pulse does half a hit.
@export var max_health := 1.0
## Kinds of point dots this enemy can drop, picked by their weights.
@export var drop_table: Array[PointDropKind] = []

## How often the enemy works out a new path to the player, in seconds.
@export var repath_interval := 0.25

var target: Node2D
var health := max_health

var _repath_cooldown := 0.0

@onready var _sprite: ArtSprite = $Sprite
@onready var _agent: NavigationAgent2D = $Agent


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	# Spread the path updates so a wave of enemies doesn't all repath in the same frame.
	_repath_cooldown = randf() * repath_interval


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	_repath_cooldown -= delta
	if _repath_cooldown <= 0.0:
		_repath_cooldown = repath_interval
		_agent.target_position = target.global_position
	var direction := global_position.direction_to(_next_step())
	velocity = direction * speed
	move_and_slide()
	if direction.x != 0.0:
		_sprite.flip_h = direction.x < 0.0


## The next point to walk to: along the path, or straight at the player when there's no path
## (the navigation mesh hasn't loaded yet, or the enemy is off the background).
func _next_step() -> Vector2:
	if _agent.is_navigation_finished():
		return target.global_position
	var step := _agent.get_next_path_position()
	if step.distance_squared_to(global_position) < 1.0:
		return target.global_position
	return step


func hit(damage: float) -> void:
	# A shot and the beat pulse can both land in the frame it dies; count only the first.
	if is_queued_for_deletion():
		return
	health -= damage
	_sprite.modulate = Color(3, 3, 3)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.1)
	if health <= 0.0:
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
