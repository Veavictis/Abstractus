extends SceneTree
## Turns the shapes in a background painting into obstacle hitboxes.
##
## Everything you can reach from the painting's edges through near-black pixels is open
## floor. Everything else (each outlined shape, with its inside) becomes one
## CollisionPolygon2D under `Obstacles` in `background_chunk.tscn`. Old hitboxes there
## are replaced.
##
## Run it from the project folder after changing the painting:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://scripts/tools/bake_obstacles.gd

const CHUNK_SCENE := "res://scenes/levels/background_chunk.tscn"
## A pixel whose brightest channel is below this counts as open floor.
const FLOOR_MAX := 0.06
## How far (in pixels) the traced outline may stray from the shape. Higher = fewer points.
const EPSILON := 1.5


func _initialize() -> void:
	var packed: PackedScene = load(CHUNK_SCENE)
	var chunk := packed.instantiate()
	var image := Image.load_from_file(ProjectSettings.globalize_path(chunk.art_path))
	var solid := _solid_mask(image)
	var polygons := solid.opaque_to_polygons(Rect2i(Vector2i.ZERO, image.get_size()), EPSILON)

	var obstacles: Node = chunk.get_node("Obstacles")
	for child in obstacles.get_children():
		obstacles.remove_child(child)
		child.free()
	for i in polygons.size():
		var shape := CollisionPolygon2D.new()
		shape.name = "Obstacle%d" % (i + 1)
		shape.polygon = polygons[i]
		obstacles.add_child(shape)
		shape.owner = chunk

	packed.pack(chunk)
	ResourceSaver.save(packed, CHUNK_SCENE)
	print("Baked %d obstacles into %s" % [polygons.size(), CHUNK_SCENE])
	chunk.free()
	quit()


## Flood-fills open floor in from the edges; whatever the fill can't reach is solid.
func _solid_mask(image: Image) -> BitMap:
	var size := image.get_size()
	var open := BitMap.new()
	open.create(size)
	var stack: Array[Vector2i] = []
	for x in size.x:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, size.y - 1))
	for y in size.y:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(size.x - 1, y))
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= size.x or p.y >= size.y or open.get_bitv(p):
			continue
		var c := image.get_pixelv(p)
		if maxf(c.r, maxf(c.g, c.b)) >= FLOOR_MAX:
			continue
		open.set_bitv(p, true)
		stack.append(p + Vector2i.RIGHT)
		stack.append(p + Vector2i.LEFT)
		stack.append(p + Vector2i.DOWN)
		stack.append(p + Vector2i.UP)

	var solid := BitMap.new()
	solid.create(size)
	for y in size.y:
		for x in size.x:
			solid.set_bit(x, y, not open.get_bit(x, y))
	return solid
