extends Node2D
## Art test level: an endless repeating background, the player, and enemies that
## spawn just off screen. Every number here is a placeholder to tune in the Inspector.

const ENEMY_SCENE := preload("res://scenes/actors/enemy.tscn")

@export var spawn_interval := 0.8
## How far from the player enemies appear. Larger than half the screen diagonal.
@export var spawn_distance := 800.0
@export var max_enemies := 150

var _kills := 0
var _time := 0.0
var _spawn_cooldown := 0.0

@onready var _player: Player = $Player
@onready var _hud: Label = $HUD/Stats


func _ready() -> void:
	_player.died.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	_player.health_changed.connect(func(_health: int) -> void: _update_hud())
	_update_hud()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	_time += delta
	_spawn_cooldown -= delta
	if _spawn_cooldown <= 0.0:
		_spawn_cooldown = spawn_interval
		if get_tree().get_node_count_in_group("enemies") < max_enemies:
			_spawn_enemy()
	_update_hud()


func _spawn_enemy() -> void:
	var spawn_position: Variant = _free_spawn_position()
	if spawn_position == null:
		return
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.position = spawn_position
	enemy.target = _player
	enemy.killed.connect(func() -> void: _kills += 1)
	add_child(enemy)


## A random point `spawn_distance` from the player that isn't inside an obstacle,
## or null when every try lands in one.
func _free_spawn_position() -> Variant:
	var query := PhysicsPointQueryParameters2D.new()
	query.collision_mask = 8
	for attempt in 8:
		query.position = _player.position + Vector2.from_angle(randf() * TAU) * spawn_distance
		if get_world_2d().direct_space_state.intersect_point(query, 1).is_empty():
			return query.position
	return null


func _update_hud() -> void:
	_hud.text = (
		"HP %d   Points %d   Kills %d   %d:%02d"
		% [_player.health, _player.points, _kills, int(_time / 60), int(_time) % 60]
	)
