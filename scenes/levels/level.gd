class_name Level
extends Node2D
## Builds a playable level from a text layout, one character per tile:
##   `#` wall   `.` floor   `P` player start   `E` exit (opens once every shard is collected)
##   `S` shard   `X` enemy (drops a shard when defeated)
##   `H` hazard patrolling along its row   `V` hazard patrolling along its column
##   `B` push block   `O` pressure plate   `G` gate (opens once every plate has a block on it)
## Edit the `layout` property in the Inspector (or in the .tscn) to change the map.

const TILE_SIZE := Vector2(32, 16)
const WALL_SCENE := preload("res://scenes/actors/wall.tscn")
const SHARD_SCENE := preload("res://scenes/actors/shard.tscn")
const HAZARD_SCENE := preload("res://scenes/actors/hazard.tscn")
const EXIT_SCENE := preload("res://scenes/actors/exit_portal.tscn")
const ENEMY_SCENE := preload("res://scenes/actors/enemy.tscn")
const BLOCK_SCENE := preload("res://scenes/actors/push_block.tscn")
const PLATE_SCENE := preload("res://scenes/actors/pressure_plate.tscn")
const GATE_SCENE := preload("res://scenes/actors/gate.tscn")

@export var level_name := "Level 1"
@export_multiline var layout := ""

var shards_total := 0
var shards_collected := 0
var deaths := 0
var elapsed := 0.0
var finished := false
var gates_open := false
var exit_portal: ExitPortal
var _built := false
var _rows: PackedStringArray
var _blocks := {}  # Vector2i -> PushBlock
var _plates := {}  # Vector2i -> PressurePlate
var _gates: Array[Gate] = []

@onready var _floor: Node2D = $Floor
@onready var _world: Node2D = $World
@onready var _player: Player = $World/Player
@onready var _hud: Hud = $Hud


static func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2((cell.x - cell.y) * TILE_SIZE.x / 2.0, (cell.x + cell.y) * TILE_SIZE.y / 2.0)


static func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		roundi(pos.x / TILE_SIZE.x + pos.y / TILE_SIZE.y),
		roundi(pos.y / TILE_SIZE.y - pos.x / TILE_SIZE.x)
	)


## Snaps a screen-space direction to the nearest single grid step.
static func screen_dir_to_grid(dir: Vector2) -> Vector2i:
	var gx := dir.x / TILE_SIZE.x + dir.y / TILE_SIZE.y
	var gy := dir.y / TILE_SIZE.y - dir.x / TILE_SIZE.x
	if is_zero_approx(gx) and is_zero_approx(gy):
		return Vector2i.ZERO
	return Vector2i(int(signf(gx)), 0) if absf(gx) >= absf(gy) else Vector2i(0, int(signf(gy)))


func _ready() -> void:
	_build()
	_player.died.connect(_on_player_died)
	_player.health_changed.connect(_hud.set_health)
	_hud.show_level(level_name)
	_hud.set_shards(shards_collected, shards_total)
	_hud.set_health(_player.health, Player.MAX_HEALTH)
	_hud.set_deaths(deaths)


func _process(delta: float) -> void:
	if not finished:
		elapsed += delta
		_hud.set_time(elapsed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") or (finished and event.is_action_pressed("accept")):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("back"):
		Game.go_to_title()


## True if the cell is inside the map and not a wall.
func is_walkable(cell: Vector2i) -> bool:
	if cell.y < 0 or cell.y >= _rows.size() or cell.x < 0 or cell.x >= _rows[cell.y].length():
		return false
	return _rows[cell.y][cell.x] != "#" and _rows[cell.y][cell.x] != " "


func tile_at(cell: Vector2i) -> String:
	return _rows[cell.y][cell.x] if is_walkable(cell) else "#"


func _build() -> void:
	_rows = layout.strip_edges().split("\n")
	for y in _rows.size():
		_rows[y] = _rows[y].strip_edges()
	var floor_cells: Array[Vector2i] = []
	for y in _rows.size():
		for x in _rows[y].length():
			var cell := Vector2i(x, y)
			var tile := _rows[y][x]
			var pos := grid_to_world(cell)
			if tile == " ":
				continue
			if tile == "#":
				_spawn(WALL_SCENE, pos)
				continue
			floor_cells.append(cell)
			_build_tile(tile, cell, pos)
	_floor.set_cells(floor_cells)
	_update_exit()
	_built = true


func _build_tile(tile: String, cell: Vector2i, pos: Vector2) -> void:
	match tile:
		"P":
			_player.position = pos
			_player.spawn_point = pos
		"S":
			_spawn_shard(pos)
		"E":
			exit_portal = _spawn(EXIT_SCENE, pos)
			exit_portal.reached.connect(_on_exit_reached)
		"H":
			_spawn_hazard(cell, Vector2i.RIGHT)
		"V":
			_spawn_hazard(cell, Vector2i.DOWN)
		"X":
			var enemy: Enemy = _spawn(ENEMY_SCENE, pos)
			enemy.defeated.connect(func(at: Vector2) -> void: _spawn_shard.call_deferred(at))
			shards_total += 1
		"B":
			var block: PushBlock = _spawn(BLOCK_SCENE, pos)
			block.cell = cell
			block.push_requested.connect(_on_block_push_requested)
			_blocks[cell] = block
		"O":
			# Plates sit flat on the floor, so they go under the Y-sorted world.
			var plate: PressurePlate = PLATE_SCENE.instantiate()
			plate.position = pos
			_floor.add_child(plate)
			_plates[cell] = plate
		"G":
			_gates.append(_spawn(GATE_SCENE, pos))


func _spawn(scene: PackedScene, pos: Vector2) -> Node2D:
	var node: Node2D = scene.instantiate()
	node.position = pos
	_world.add_child(node)
	return node


func _spawn_shard(pos: Vector2) -> void:
	var shard: Shard = _spawn(SHARD_SCENE, pos)
	shard.collected.connect(_on_shard_collected)
	# Shards dropped by enemies were already counted when the enemy spawned.
	if not _built:
		shards_total += 1


func _spawn_hazard(cell: Vector2i, axis: Vector2i) -> void:
	var a := cell
	while is_walkable(a - axis):
		a -= axis
	var b := cell
	while is_walkable(b + axis):
		b += axis
	var hazard: Hazard = _spawn(HAZARD_SCENE, grid_to_world(cell))
	hazard.setup(grid_to_world(cell), grid_to_world(a), grid_to_world(b))


## Moves a block one tile, if the tile is free.
func _on_block_push_requested(block: PushBlock, dir: Vector2i) -> void:
	var target := block.cell + dir
	if not is_walkable(target) or _blocks.has(target):
		return
	if tile_at(target) == "G" and not gates_open:
		return
	_blocks.erase(block.cell)
	_blocks[target] = block
	block.slide_to(target, grid_to_world(target))
	_update_plates()


func _update_plates() -> void:
	var all_pressed := not _plates.is_empty()
	for cell: Vector2i in _plates:
		_plates[cell].pressed = _blocks.has(cell)
		all_pressed = all_pressed and _blocks.has(cell)
	if all_pressed and not gates_open:
		gates_open = true
		for gate in _gates:
			gate.open()
		_hud.flash_message("A gate opened!")


func _update_exit() -> void:
	if exit_portal and shards_collected >= shards_total and not exit_portal.unlocked:
		exit_portal.unlock()
		if _built:
			_hud.flash_message("The exit is open!")


func _on_shard_collected() -> void:
	shards_collected += 1
	_hud.set_shards(shards_collected, shards_total)
	_update_exit()


func _on_player_died() -> void:
	deaths += 1
	_hud.set_deaths(deaths)
	_hud.flash_message("Back to the start...")


func _on_exit_reached() -> void:
	if finished:
		return
	finished = true
	_player.controls_enabled = false
	_hud.show_win(elapsed, deaths)
