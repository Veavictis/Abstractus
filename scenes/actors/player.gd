class_name Player
extends CharacterBody2D
## The player. Input moves in screen space with the vertical axis halved,
## so diagonal input runs exactly along the 2:1 isometric grid.
## The player faces the cursor once the mouse moves, or wherever the right stick points,
## and with the weapon, shoots that way.
## Placeholder art is drawn in `_draw()`; swap it for a Sprite2D or AnimatedSprite2D later.

signal health_changed(health: int, max_health: int)
signal died

const SPEED := 90.0
const MAX_HEALTH := 3
const INVULNERABLE_TIME := 1.0
const KNOCKBACK := 160.0
const ATTACK_COOLDOWN := 0.35
const ATTACK_SHOW_TIME := 0.12
const ATTACK_REACH := 12.0
const ATTACK_RADIUS := 14.0
const PUSH_DELAY := 0.08
## 2 shots a second while the shoot button is held.
const FIRE_COOLDOWN := 0.5
const BULLET_SCENE := preload("res://scenes/actors/bullet.tscn")

var controls_enabled := true
var has_weapon := false
## Set by the level while the player stands on safe floor. Enemies stop chasing there.
var in_safe_zone := false
var spawn_point := Vector2.ZERO
var facing := Vector2.DOWN
var health := MAX_HEALTH
var _invulnerable_left := 0.0
var _attack_cooldown_left := 0.0
var _fire_cooldown_left := 0.0
var _aim_with_mouse := false
var _attack_show_left := 0.0
var _push_time := 0.0
var _knockback := Vector2.ZERO


func _ready() -> void:
	add_to_group("player")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_aim_with_mouse = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		_aim_with_mouse = false


func _physics_process(delta: float) -> void:
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)
	_attack_cooldown_left = maxf(_attack_cooldown_left - delta, 0.0)
	_fire_cooldown_left = maxf(_fire_cooldown_left - delta, 0.0)
	_attack_show_left = maxf(_attack_show_left - delta, 0.0)
	var input := Vector2.ZERO
	if controls_enabled:
		input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_pressed("attack"):
			attack()
	var stick_aim := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if controls_enabled and stick_aim != Vector2.ZERO:
		_aim_with_mouse = false
		facing = stick_aim.normalized()
	elif controls_enabled and _aim_with_mouse:
		var aim := _mouse_aim()
		if aim != Vector2.ZERO:
			facing = Vector2(aim.x, aim.y * 2.0).normalized()
	elif input != Vector2.ZERO:
		facing = input.normalized()
	if controls_enabled and Input.is_action_pressed("shoot"):
		shoot()
	velocity = Vector2(input.x, input.y * 0.5) * SPEED + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, KNOCKBACK * 6.0 * delta)
	move_and_slide()
	_handle_push(input, delta)
	# Blink while invulnerable after a hit.
	visible = _invulnerable_left <= 0.0 or int(_invulnerable_left * 10.0) % 2 == 0
	queue_redraw()


## Swings at whatever is just in front of the player.
func attack() -> void:
	if _attack_cooldown_left > 0.0:
		return
	_attack_cooldown_left = ATTACK_COOLDOWN
	_attack_show_left = ATTACK_SHOW_TIME
	var point := global_position + _ground_facing() * ATTACK_REACH
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(point) <= ATTACK_RADIUS:
			enemy.take_hit(global_position, Enemy.MELEE_DAMAGE)


## Fires one triangle toward the cursor (or straight ahead without a mouse), if the weapon is ready.
func shoot() -> void:
	if not has_weapon or _fire_cooldown_left > 0.0:
		return
	_fire_cooldown_left = FIRE_COOLDOWN
	var bullet: Bullet = BULLET_SCENE.instantiate()
	bullet.direction = _ground_facing()
	bullet.position = position + bullet.direction * 6.0
	get_parent().add_child(bullet)


## Called by hazards and enemies. At zero health the player starts over at the spawn point.
func take_hit(from: Vector2) -> void:
	if _invulnerable_left > 0.0:
		return
	health -= 1
	_invulnerable_left = INVULNERABLE_TIME
	if health <= 0:
		health = MAX_HEALTH
		position = spawn_point
		_knockback = Vector2.ZERO
		died.emit()
	else:
		_knockback = (global_position - from).normalized() * KNOCKBACK
	health_changed.emit(health, MAX_HEALTH)


func _ground_facing() -> Vector2:
	return Vector2(facing.x, facing.y * 0.5).normalized()


## Ground direction from the player to the point under the cursor. Bullets fly at weapon height,
## so aim at the ground just below the cursor for the shot to pass through it.
func _mouse_aim() -> Vector2:
	var target := get_global_mouse_position() + Vector2(0, Bullet.HEIGHT)
	return (target - global_position).normalized()


func _handle_push(input: Vector2, delta: float) -> void:
	if input != Vector2.ZERO:
		for i in get_slide_collision_count():
			var block := get_slide_collision(i).get_collider() as PushBlock
			if block and input.dot(block.global_position - global_position) > 0.0:
				_push_time += delta
				if _push_time >= PUSH_DELAY:
					_push_time = 0.0
					block.push(Level.screen_dir_to_grid(Vector2(input.x, input.y * 0.5)))
				return
	_push_time = 0.0


func _draw() -> void:
	# Shadow at the feet (the node origin is the feet, which is what Y-sorting uses).
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO)
	# Body and head, about 28 px tall.
	draw_rect(Rect2(-5, -18, 10, 16), Color("e8c170"))
	draw_rect(Rect2(-5, -6, 10, 4), Color("a8743a"))
	draw_circle(Vector2(0, -23), 5.5, Color("f4e3c1"))
	var eye := Vector2(round(facing.x * 2.0), -23 + round(facing.y))
	draw_rect(Rect2(eye + Vector2(-1, -1), Vector2(2, 2)), Color("1b1b2a"))
	if has_weapon:
		# Placeholder weapon: a triangle held toward the facing direction.
		draw_set_transform(
			Vector2(0, -Bullet.HEIGHT) + _ground_facing() * 7.0, _ground_facing().angle()
		)
		draw_colored_polygon(
			PackedVector2Array([Vector2(-3, 2), Vector2(4, 0), Vector2(-3, -2)]), Color("fff3c4")
		)
		draw_set_transform(Vector2.ZERO)
	if _attack_show_left > 0.0:
		var center := _ground_facing() * ATTACK_REACH + Vector2(0, -8)
		var angle := _ground_facing().angle()
		draw_arc(center, ATTACK_RADIUS * 0.7, angle - 1.2, angle + 1.2, 8, Color("fff3c4"), 2.0)
