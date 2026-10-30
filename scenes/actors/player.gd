class_name Player
extends CharacterBody2D
## Test player: moves, auto-fires toward the aim direction (mouse cursor, or the right stick
## on a gamepad), faces where it aims, and loses health on contact.
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
## Unit vector the player aims and faces along.
var aim_direction := Vector2.RIGHT
## True while the right stick aims; moving the mouse switches back to the cursor.
var aiming_with_stick := false
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

	_update_aim()
	if aim_direction.x != 0.0:
		_sprite.flip_h = aim_direction.x < 0.0

	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0:
		_fire()
		_fire_cooldown = fire_interval

	_hurt_cooldown -= delta
	if _hurt_cooldown <= 0.0 and _hurtbox.has_overlapping_bodies():
		_take_hit(1)
		_hurt_cooldown = hurt_interval


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aiming_with_stick = false


func _update_aim() -> void:
	var stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick != Vector2.ZERO:
		aiming_with_stick = true
		aim_direction = stick.normalized()
	elif not aiming_with_stick:
		var to_mouse := global_position.direction_to(get_global_mouse_position())
		if to_mouse != Vector2.ZERO:
			aim_direction = to_mouse


func _fire() -> void:
	var shot: PlayerShot = SHOT_SCENE.instantiate()
	shot.global_position = global_position
	shot.direction = aim_direction
	get_parent().add_child(shot)


func _take_hit(amount: int) -> void:
	health = maxi(0, health - amount)
	health_changed.emit(health)
	_sprite.modulate = Color(1, 0.4, 0.4)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.2)
	if health == 0:
		died.emit()
