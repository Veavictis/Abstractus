class_name Enemy
extends CharacterBody2D
## A basic enemy. Wanders near home, comes for the player when close, and drops whatever the level
## hooks up to `defeated` (a crystal).
## Circles (placeholder art) are melee only and hurt on contact.
## Squares (placeholder art) keep their distance and shoot when they have a clear line to the player.

signal defeated(at: Vector2)

enum Kind { CIRCLE, SQUARE }

## Health is in points so melee and bullets can do different damage.
## Circles: 3 melee hits or 4 shots. Squares: 3 melee hits or 3 shots.
const CIRCLE_HEALTH := 12
const SQUARE_HEALTH := 9
const MELEE_DAMAGE := 4
const SHOT_DAMAGE := 3
const CHASE_SPEED := 40.0
const WANDER_SPEED := 18.0
const SIGHT_RANGE := 110.0
const CONTACT_RANGE := 11.0
const KNOCKBACK := 180.0
const STUN_TIME := 0.3
## Squares stop closing in at this distance and shoot from there.
const SHOOT_RANGE := 90.0
const SHOOT_COOLDOWN := 1.5
const BULLET_SCENE := preload("res://scenes/actors/bullet.tscn")

@export var kind := Kind.CIRCLE

var max_health := CIRCLE_HEALTH
var health := CIRCLE_HEALTH
var home := Vector2.ZERO
## Enemies poured out of a portal hunt from further away.
var sight_range := SIGHT_RANGE
var _wander_target := Vector2.ZERO
var _wander_wait := 0.0
var _stun_left := 0.0
var _flash_left := 0.0
var _shoot_left := SHOOT_COOLDOWN
var _knockback := Vector2.ZERO


func _ready() -> void:
	add_to_group("enemies")
	max_health = SQUARE_HEALTH if kind == Kind.SQUARE else CIRCLE_HEALTH
	health = max_health
	home = position
	_wander_target = position


## Sends the enemy flying in a direction, e.g. out of a portal.
func launch(direction: Vector2) -> void:
	_knockback = direction * KNOCKBACK


func _physics_process(delta: float) -> void:
	_stun_left = maxf(_stun_left - delta, 0.0)
	_flash_left = maxf(_flash_left - delta, 0.0)
	_shoot_left = maxf(_shoot_left - delta, 0.0)
	var player := _find_player()
	var hunting := player != null and not player.in_safe_zone and _sees(player)
	var move := Vector2.ZERO
	if _stun_left <= 0.0:
		if hunting:
			move = _hunt(player)
		else:
			move = _wander(delta)
	velocity = move + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, KNOCKBACK * 5.0 * delta)
	move_and_slide()
	if (
		kind == Kind.CIRCLE
		and player
		and not player.in_safe_zone
		and global_position.distance_to(player.global_position) <= CONTACT_RANGE
	):
		player.take_hit(global_position)
	queue_redraw()


func take_hit(from: Vector2, damage := MELEE_DAMAGE) -> void:
	health -= damage
	_flash_left = 0.1
	_stun_left = STUN_TIME
	_knockback = (global_position - from).normalized() * KNOCKBACK
	if health <= 0:
		defeated.emit(global_position)
		queue_free()


func _hunt(player: Player) -> Vector2:
	var to_player := player.global_position - global_position
	if kind == Kind.CIRCLE:
		return to_player.normalized() * CHASE_SPEED
	if _shoot_left <= 0.0 and to_player.length() <= SHOOT_RANGE * 1.3 and _clear_shot(player):
		_shoot(to_player.normalized())
	if to_player.length() > SHOOT_RANGE:
		return to_player.normalized() * CHASE_SPEED
	return Vector2.ZERO


func _shoot(direction: Vector2) -> void:
	_shoot_left = SHOOT_COOLDOWN
	var bullet: Bullet = BULLET_SCENE.instantiate()
	bullet.hostile = true
	bullet.direction = direction
	bullet.position = position + direction * 8.0
	get_parent().add_child(bullet)


## True if no wall, gate or crate stands between this enemy and the player.
func _clear_shot(player: Player) -> bool:
	var query := PhysicsRayQueryParameters2D.create(
		global_position, player.global_position, Bullet.WORLD_MASK
	)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _wander(delta: float) -> Vector2:
	if global_position.distance_to(_wander_target) < 2.0:
		_wander_wait -= delta
		if _wander_wait <= 0.0:
			_wander_wait = randf_range(0.5, 1.5)
			_wander_target = home + Vector2(randf_range(-24, 24), randf_range(-12, 12))
		return Vector2.ZERO
	return (_wander_target - global_position).normalized() * WANDER_SPEED


func _sees(player: Player) -> bool:
	return global_position.distance_to(player.global_position) <= sight_range


func _find_player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 8.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO)
	if kind == Kind.SQUARE:
		var body := Color.WHITE if _flash_left > 0.0 else Color("f28c38")
		draw_rect(Rect2(-7, -16, 14, 14), body)
		draw_rect(Rect2(-7, -4, 14, 2), Color("a0521c"))
	else:
		var body := Color.WHITE if _flash_left > 0.0 else Color("9b5de5")
		# Circle body with a darker rim along the bottom.
		draw_circle(Vector2(0, -8), 7.0, Color("5a2f8f"))
		draw_circle(Vector2(0, -9), 7.0, body)
	draw_rect(Rect2(-4, -12, 2, 3), Color("ffe066"))
	draw_rect(Rect2(2, -12, 2, 3), Color("ffe066"))
	draw_rect(Rect2(-6, -21, 12, 2), Color("3a1d4f"))
	draw_rect(Rect2(-6, -21, round(12.0 * health / max_health), 2), Color("e8485f"))
