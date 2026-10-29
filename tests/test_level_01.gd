extends Node
## Headless smoke test for level 1. Run with:
##   godot --headless res://tests/test_level_01.tscn
## Plays the level through by calling the same hooks the physics would, and exits non-zero on failure.

var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var level: Level = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(level)
	await _frames(5)
	var player: Player = level.get_node("World/Player")
	var world := level.get_node("World")

	_check(level.shards_total == 15, "level 1 has 15 crystals (6 placed, 9 from enemies)")
	_check(not level.exit_portal.unlocked, "exit starts locked")
	_check(_reachable(level), "every shard, enemy, block, plate and the exit is reachable")

	var start := player.position
	Input.action_press("move_right")
	await _frames(20, true)
	Input.action_release("move_right")
	_check(player.position.x > start.x + 10.0, "player moves right with input")

	# Weapon: no shooting before the pickup, then 4 shots defeat an enemy.
	_check(not player.has_weapon, "player starts without the weapon")
	player.shoot()
	await _frames(1)
	_check(_first(world, Bullet) == null, "can't shoot before finding the weapon")
	var weapon: WeaponPickup = _first(world, WeaponPickup)
	_check(
		level.tile_at(Level.world_to_grid(weapon.position)) == "W",
		"the weapon sits in the safe room"
	)
	weapon._on_body_entered(player)
	_check(player.has_weapon, "touching the weapon picks it up")
	var target: Enemy = get_tree().get_nodes_in_group("enemies")[0]
	# A real shot: line up 4 tiles apart along an open row, face the enemy, fire, and let it fly.
	target.set_physics_process(false)
	target.position = Level.grid_to_world(Vector2i(35, 5))
	player.position = Level.grid_to_world(Vector2i(31, 5))
	# Facing is in input space (vertical doubled), so this aims straight down the row.
	player.facing = Vector2(1, 1).normalized()
	player.shoot()
	await _frames(30, true)
	_check(
		target.health == Enemy.MAX_HEALTH - Enemy.SHOT_DAMAGE,
		"a fired bullet flies and hits the enemy"
	)
	target.health = Enemy.MAX_HEALTH
	for i in 4:
		_check(is_instance_valid(target), "enemy survives %d shot(s)" % i)
		var bullet: Bullet = load("res://scenes/actors/bullet.tscn").instantiate()
		world.add_child(bullet)
		bullet._on_body_entered(target)
	await _frames(2)
	_check(not is_instance_valid(target), "4 shots defeat an enemy")

	# Back to the safe room, so no enemy dies on top of the player and drops a crystal into their hands.
	player.position = Level.grid_to_world(Vector2i(21, 9))

	# Puzzle: push the block 4 tiles along +x onto the plate.
	var block: PushBlock = _first(world, PushBlock)
	for i in 4:
		block.push(Vector2i.RIGHT)
		await get_tree().create_timer(PushBlock.SLIDE_TIME + 0.1).timeout
	_check(level.gates_open, "pushing the block onto the plate opens the gate")

	# Combat: each enemy takes 3 melee hits and drops a crystal.
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies").duplicate():
		for i in 3:
			enemy.take_hit(enemy.global_position + Vector2(-1, 0))
	await _frames(3)
	_check(get_tree().get_nodes_in_group("enemies").is_empty(), "enemies can be defeated")

	var shards := world.get_children().filter(func(n: Node) -> bool: return n is Shard)
	_check(shards.size() == 15, "all 15 crystals exist once enemies drop theirs")
	for shard: Shard in shards:
		shard._on_body_entered(player)
	await _frames(2)
	_check(
		level.shards_collected == 15 and level.exit_portal.unlocked,
		"collecting every crystal opens the exit"
	)

	level.exit_portal._on_body_entered(player)
	_check(level.finished, "stepping on the open exit completes the level")

	print("%s: %d failure(s)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	get_tree().quit(1 if _failures else 0)


func _reachable(level: Level) -> bool:
	var start := Level.world_to_grid(level.get_node("World/Player").spawn_point)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + dir
			if level.is_walkable(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	var rows := level.layout.strip_edges().split("\n")
	for y in rows.size():
		var row := rows[y].strip_edges()
		for x in row.length():
			if row[x] in "SXBOEW" and not seen.has(Vector2i(x, y)):
				return false
	return true


func _first(parent: Node, type: Variant) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null


func _frames(count: int, physics := false) -> void:
	for i in count:
		await (get_tree().physics_frame if physics else get_tree().process_frame)


func _check(ok: bool, what: String) -> void:
	print("%s %s" % ["ok  " if ok else "FAIL", what])
	if not ok:
		_failures += 1
