class_name SpawnPortal
extends Area2D
## Appears once every wall switch is flipped. Pours out a wave of enemies in all directions,
## then shines brighter once they're all defeated and takes the player to the next level.

signal enemy_spawned(enemy: Enemy)
signal entered

const ENEMY_SCENE := preload("res://scenes/actors/enemy.tscn")
const SPAWN_INTERVAL := 0.25
## Portal enemies hunt the player from across the room.
const SPAWN_SIGHT_RANGE := 260.0

var wave_size := 15
var is_open := false
var _to_spawn := 0
var _spawn_left := 0.0
var _alive := 0
var _time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_to_spawn = wave_size


func _process(delta: float) -> void:
	_time += delta
	if _to_spawn > 0:
		_spawn_left -= delta
		if _spawn_left <= 0.0:
			_spawn_left = SPAWN_INTERVAL
			_spawn_enemy()
	queue_redraw()


func _spawn_enemy() -> void:
	var index := wave_size - _to_spawn
	_to_spawn -= 1
	_alive += 1
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.kind = Enemy.Kind.CIRCLE
	enemy.position = position
	enemy.sight_range = SPAWN_SIGHT_RANGE
	enemy.defeated.connect(_on_enemy_defeated.unbind(1))
	# Spread the wave evenly around the circle so it pours out in every direction.
	var angle := index * TAU / wave_size + randf_range(-0.2, 0.2)
	get_parent().add_child(enemy)
	enemy.launch(Vector2.from_angle(angle) * Vector2(1.0, 0.5) * 1.5)
	enemy_spawned.emit(enemy)


func _on_enemy_defeated() -> void:
	_alive -= 1
	if _alive <= 0 and _to_spawn <= 0:
		is_open = true
		for body in get_overlapping_bodies():
			_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if is_open and body is Player:
		entered.emit()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * (6.0 if is_open else 3.0))
	var radius := 12.0 if is_open else 9.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, radius + 2.0, Color(0.2, 0.9, 1.0, 0.25 + 0.35 * pulse))
	draw_circle(Vector2.ZERO, radius, Color("1b1b2a"))
	var ring := Color("c8f6ff") if is_open else Color(0.45, 0.6, 0.8)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, ring, 2.0 if is_open else 1.0)
	draw_set_transform(Vector2.ZERO)
	if is_open:
		for i in 3:
			var y := -fmod(_time * 16.0 + i * 8.0, 26.0)
			draw_line(Vector2(-6 + i * 6, y), Vector2(-6 + i * 6, y - 5), Color("c8f6ff"))
