class_name Enemy
extends CharacterBody2D
## A basic melee enemy (placeholder art: a circle). Wanders near home, chases the player when close, and hurts on contact.
## Drops whatever the level hooks up to `defeated` (level 1 drops a shard).

signal defeated(at: Vector2)

const MAX_HEALTH := 3
const CHASE_SPEED := 40.0
const WANDER_SPEED := 18.0
const SIGHT_RANGE := 110.0
const CONTACT_RANGE := 11.0
const KNOCKBACK := 180.0
const STUN_TIME := 0.3

var health := MAX_HEALTH
var home := Vector2.ZERO
var _wander_target := Vector2.ZERO
var _wander_wait := 0.0
var _stun_left := 0.0
var _flash_left := 0.0
var _knockback := Vector2.ZERO


func _ready() -> void:
	add_to_group("enemies")
	home = position
	_wander_target = position


func _physics_process(delta: float) -> void:
	_stun_left = maxf(_stun_left - delta, 0.0)
	_flash_left = maxf(_flash_left - delta, 0.0)
	var player := _find_player()
	var move := Vector2.ZERO
	if _stun_left <= 0.0:
		if player and global_position.distance_to(player.global_position) <= SIGHT_RANGE:
			move = (player.global_position - global_position).normalized() * CHASE_SPEED
		else:
			move = _wander(delta)
	velocity = move + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, KNOCKBACK * 5.0 * delta)
	move_and_slide()
	if player and global_position.distance_to(player.global_position) <= CONTACT_RANGE:
		player.take_hit(global_position)
	queue_redraw()


func take_hit(from: Vector2) -> void:
	health -= 1
	_flash_left = 0.1
	_stun_left = STUN_TIME
	_knockback = (global_position - from).normalized() * KNOCKBACK
	if health <= 0:
		defeated.emit(global_position)
		queue_free()


func _wander(delta: float) -> Vector2:
	if global_position.distance_to(_wander_target) < 2.0:
		_wander_wait -= delta
		if _wander_wait <= 0.0:
			_wander_wait = randf_range(0.5, 1.5)
			_wander_target = home + Vector2(randf_range(-24, 24), randf_range(-12, 12))
		return Vector2.ZERO
	return (_wander_target - global_position).normalized() * WANDER_SPEED


func _find_player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 8.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO)
	var body := Color.WHITE if _flash_left > 0.0 else Color("9b5de5")
	# Circle body with a darker rim along the bottom.
	draw_circle(Vector2(0, -8), 7.0, Color("5a2f8f"))
	draw_circle(Vector2(0, -9), 7.0, body)
	draw_rect(Rect2(-4, -12, 2, 3), Color("ffe066"))
	draw_rect(Rect2(2, -12, 2, 3), Color("ffe066"))
	for i in health:
		draw_rect(Rect2(-5 + i * 4, -21, 3, 2), Color("e8485f"))
