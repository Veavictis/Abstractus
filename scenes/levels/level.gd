class_name Level
extends Node2D
## Builds a playable level from a text layout, one character per tile:
##   `#` wall   `.` floor   `P` player start   `E` exit
##   `S` crystal (optional; any left over fly to the player at the end of the level)
##   `X` circle enemy (melee)   `Q` square enemy (shoots). Both drop a crystal when defeated.
##   `H` hazard patrolling along its row   `V` hazard patrolling along its column
##   `B` push block   `O` pressure plate   `G` gate (opens once every plate has a block on it)
##   `-` safe floor (enemies won't chase you there)   `W` the weapon pickup (on safe floor)
##   `T` wall switch (a wall with a target; shoot every one before `switch_time` runs out)
##   `M` where the portal appears once every switch is flipped
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
const WEAPON_SCENE := preload("res://scenes/actors/weapon_pickup.tscn")
const SWITCH_SCENE := preload("res://scenes/actors/wall_switch.tscn")
const PORTAL_SCENE := preload("res://scenes/actors/spawn_portal.tscn")
## How long the end-of-level crystal magnet runs before the level complete panel shows.
const MAGNET_TIME := 0.9
const SAFE_TILES := "-W"

@export var level_name := "Level 1"
@export_multiline var layout := ""
@export var start_with_weapon := false
## Seconds to flip every wall switch, counted from the first one hit.
@export var switch_time := 15.0
## How many enemies pour out of the portal.
@export var portal_wave := 15

var shards_total := 0
var shards_collected := 0
var deaths := 0
var elapsed := 0.0
var finished := false
var gates_open := false
var exit_portal: ExitPortal
var portal: SpawnPortal
var switches: Array[WallSwitch] = []
var switch_time_left := 0.0
var _portal_spot := Vector2.ZERO
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
	# The crosshair in the HUD stands in for the mouse cursor.
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_build()
	_player.has_weapon = start_with_weapon
	_player.died.connect(_on_player_died)
	_player.health_changed.connect(_hud.set_health)
	_hud.show_level(level_name)
	_hud.set_shards(shards_collected, shards_total)
	_hud.set_health(_player.health, Player.MAX_HEALTH)
	_hud.set_deaths(deaths)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(_delta: float) -> void:
	_player.in_safe_zone = tile_at(world_to_grid(_player.position)) in SAFE_TILES


func _process(delta: float) -> void:
	if not finished:
		elapsed += delta
		_hud.set_time(elapsed)
	if switch_time_left > 0.0:
		switch_time_left -= delta
		if switch_time_left <= 0.0:
			_reset_switches()


func _unhandled_input(event: InputEvent) -> void:
	if finished and event.is_action_pressed("accept"):
		Game.go_to_next_level(scene_file_path)
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("back"):
		Game.go_to_title()


## True if the cell is inside the map and not a wall.
func is_walkable(cell: Vector2i) -> bool:
	if cell.y < 0 or cell.y >= _rows.size() or cell.x < 0 or cell.x >= _rows[cell.y].length():
		return false
	return not _rows[cell.y][cell.x] in "#T "


func tile_at(cell: Vector2i) -> String:
	return _rows[cell.y][cell.x] if is_walkable(cell) else "#"


func _build() -> void:
	_rows = layout.strip_edges().split("\n")
	for y in _rows.size():
		_rows[y] = _rows[y].strip_edges()
	var floor_cells: Array[Vector2i] = []
	var safe_cells: Array[Vector2i] = []
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
			if tile == "T":
				var wall_switch: WallSwitch = _spawn(SWITCH_SCENE, pos)
				wall_switch.flipped.connect(_on_switch_flipped)
				switches.append(wall_switch)
				continue
			floor_cells.append(cell)
			if tile in SAFE_TILES:
				safe_cells.append(cell)
			_build_tile(tile, cell, pos)
	_floor.set_cells(floor_cells, safe_cells)
	# Crystals are optional, so the exit is open from the start (a gate may still stand in the way).
	if exit_portal:
		exit_portal.unlock()
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
			exit_portal.reached.connect(_finish)
		"H":
			_spawn_hazard(cell, Vector2i.RIGHT)
		"V":
			_spawn_hazard(cell, Vector2i.DOWN)
		"X":
			_spawn_enemy(Enemy.Kind.CIRCLE, pos)
		"Q":
			_spawn_enemy(Enemy.Kind.SQUARE, pos)
		"M":
			_portal_spot = pos
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
		"W":
			var weapon: WeaponPickup = _spawn(WEAPON_SCENE, pos)
			weapon.picked_up.connect(
				_hud.flash_message.bind("You found a weapon! Aim with the mouse, click to shoot.")
			)


func _spawn(scene: PackedScene, pos: Vector2) -> Node2D:
	var node: Node2D = scene.instantiate()
	node.position = pos
	_world.add_child(node)
	return node


func _spawn_enemy(kind: Enemy.Kind, pos: Vector2) -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.kind = kind
	enemy.position = pos
	_world.add_child(enemy)
	_track_enemy(enemy)


## Every enemy carries a crystal and drops it when defeated.
func _track_enemy(enemy: Enemy) -> void:
	enemy.defeated.connect(func(at: Vector2) -> void: _spawn_shard.call_deferred(at))
	shards_total += 1
	if _built:
		_hud.set_shards(shards_collected, shards_total)


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


func _on_switch_flipped() -> void:
	if switches.all(func(s: WallSwitch) -> bool: return s.is_on):
		switch_time_left = 0.0
		_open_portal()
	elif switch_time_left <= 0.0:
		# The clock starts on the first switch hit.
		switch_time_left = switch_time


func _reset_switches() -> void:
	switch_time_left = 0.0
	for wall_switch in switches:
		wall_switch.reset()
	_hud.flash_message("Too slow! The switches reset.")


func _open_portal() -> void:
	portal = PORTAL_SCENE.instantiate()
	portal.position = _portal_spot
	portal.wave_size = portal_wave
	portal.enemy_spawned.connect(_track_enemy)
	portal.entered.connect(_finish)
	_world.add_child(portal)
	_hud.flash_message("A portal opened!")


func _on_shard_collected() -> void:
	shards_collected += 1
	_hud.set_shards(shards_collected, shards_total)


func _on_player_died() -> void:
	deaths += 1
	_hud.set_deaths(deaths)
	_hud.flash_message("Back to the start...")


## Ends the level: every crystal still on the ground flies to the player, then the complete panel shows.
func _finish() -> void:
	if finished:
		return
	finished = true
	_player.controls_enabled = false
	for node in _world.get_children():
		if node is Shard:
			node.fly_to(_player)
	await get_tree().create_timer(MAGNET_TIME).timeout
	_hud.show_win(
		elapsed, deaths, shards_collected, shards_total, Game.has_next_level(scene_file_path)
	)
