extends Node
## Headless smoke test for level 2. Run with:
##   godot --headless res://tests/test_level_02.tscn
## Checks the wall switch timer, the portal wave, and the way out to level 3.

var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var level: Level = load("res://scenes/levels/level_02.tscn").instantiate()
	add_child(level)
	await _frames(5)
	var player: Player = level.get_node("World/Player")
	var world := level.get_node("World")
	# Keep the player out of the fight; this test drives everything directly.
	player.controls_enabled = false
	player.position = Vector2(0, -2000)

	_check(player.has_weapon, "player starts level 2 with the weapon")
	_check(level.switches.size() == 4, "one switch on each of the 4 walls")
	var squares := get_tree().get_nodes_in_group("enemies").filter(
		func(e: Enemy) -> bool: return e.kind == Enemy.Kind.SQUARE
	)
	_check(squares.size() == 6, "level 2 has 6 square enemies")
	_check(get_tree().get_nodes_in_group("enemies").size() == squares.size(), "and only squares")
	var square: Enemy = squares[0]
	for i in 3:
		_check(is_instance_valid(square), "square survives %d shot(s)" % i)
		_shoot(world, square)
	await _frames(2)
	_check(not is_instance_valid(square), "3 shots defeat a square")

	# A square with a clear line to the player shoots, and its bullet hurts.
	var shooter: Enemy = squares[1]
	shooter.position = Level.grid_to_world(Vector2i(4, 3))
	shooter.home = shooter.position
	player.position = Level.grid_to_world(Vector2i(8, 3))
	await get_tree().create_timer(Enemy.SHOOT_COOLDOWN + 1.0).timeout
	_check(player.health < Player.MAX_HEALTH, "a square shoots the player")
	player.position = Vector2(0, -2000)
	shooter.queue_free()

	# Timer: flip 3, let the clock run out, and they all reset.
	level.switch_time = 0.5
	for i in 3:
		_shoot(world, level.switches[i])
	_check(level.switch_time_left > 0.0, "the clock starts on the first switch hit")
	await get_tree().create_timer(0.7).timeout
	_check(level.switches.all(func(s: WallSwitch) -> bool: return not s.is_on), "switches reset")
	_check(level.portal == null, "no portal without all 4 switches")

	# Flip all 4 in time: the portal opens and pours out 15 circles.
	level.switch_time = 15.0
	for wall_switch in level.switches:
		_shoot(world, wall_switch)
	_check(level.portal != null, "flipping all 4 switches opens the portal")
	var before := level.shards_total
	await get_tree().create_timer(SpawnPortal.SPAWN_INTERVAL * 16 + 0.3).timeout
	var circles := get_tree().get_nodes_in_group("enemies").filter(
		func(e: Enemy) -> bool: return e.kind == Enemy.Kind.CIRCLE
	)
	_check(circles.size() == 15, "15 circle enemies pour out of the portal")
	_check(level.shards_total == before + 15, "each portal enemy carries a crystal")
	_check(not level.portal.is_open, "the portal stays shut while they're alive")
	for enemy: Enemy in circles:
		for i in 3:
			enemy.take_hit(enemy.global_position + Vector2(-1, 0))
	await _frames(3)
	_check(level.portal.is_open, "defeating all 15 opens the portal")

	level.portal._on_body_entered(player)
	_check(level.finished, "stepping into the open portal completes the level")
	_check(not Game.has_next_level(level.scene_file_path), "level 2 is the last level built so far")

	print("%s: %d failure(s)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	get_tree().quit(1 if _failures else 0)


## Fires a player bullet straight into `body`, the same as a hit in play.
func _shoot(world: Node, body: Node2D) -> void:
	var bullet: Bullet = load("res://scenes/actors/bullet.tscn").instantiate()
	world.add_child(bullet)
	bullet._on_body_entered(body)


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	print("%s %s" % ["ok  " if ok else "FAIL", what])
	if not ok:
		_failures += 1
