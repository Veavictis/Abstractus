class_name Player
extends CharacterBody2D
## Test player: moves, auto-fires at the nearest enemy, loses health on contact.
## Every number here is a placeholder to tune in the Inspector.

signal health_changed(health: int)
signal died

const SHOT_SCENE := preload("res://scenes/actors/player_shot.tscn")

@export var speed := 120.0
@export var max_health := 10
@export var fire_interval := 0.6
## Seconds between contact hits while an enemy is touching the player.
@export var hurt_interval := 0.5

var health := max_health
var _fire_cooldown := 0.0
var _hurt_cooldown := 0.0

@onready var _sprite: ArtSprite = $Sprite
@onready var _hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	if direction.x != 0.0:
		_sprite.flip_h = direction.x < 0.0

	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0:
		var target := _nearest_enemy()
		if target:
			_fire_at(target.global_position)
			_fire_cooldown = fire_interval

	_hurt_cooldown -= delta
	if _hurt_cooldown <= 0.0 and _hurtbox.has_overlapping_bodies():
		_take_hit(1)
		_hurt_cooldown = hurt_interval


func _nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var best := INF
	for enemy: Node2D in get_tree().get_nodes_in_group("enemies"):
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < best:
			best = distance
			nearest = enemy
	return nearest


func _fire_at(target: Vector2) -> void:
	var shot: PlayerShot = SHOT_SCENE.instantiate()
	shot.global_position = global_position
	shot.direction = global_position.direction_to(target)
	get_parent().add_child(shot)


func _take_hit(amount: int) -> void:
	health = maxi(0, health - amount)
	health_changed.emit(health)
	_sprite.modulate = Color(1, 0.4, 0.4)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.2)
	if health == 0:
		died.emit()
