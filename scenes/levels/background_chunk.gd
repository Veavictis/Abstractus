@tool
extends Node2D
## One 1024x1024 background chunk: the painting plus the obstacle hitboxes traced over it.
##
## The hitboxes are CollisionPolygon2D children of `Obstacles`, baked from the painting by
## `scripts/tools/bake_obstacles.gd` or traced by hand in the editor over the painting.
##
## When the game runs, each chunk also gets a navigation mesh: the walkable floor around
## those hitboxes, which enemies follow to find their way around obstacles. It's built from
## the hitboxes when the first chunk loads, so it always matches them.

const SIZE := 1024

@export_file("*.png") var art_path := "res://assets/art/backgrounds/test_chunk.png"
## How far enemy paths keep from obstacles, in pixels. A bit more than the enemy's radius (16).
@export var path_clearance := 18.0

## Every chunk is the same painting, so they all share one navigation mesh.
static var _navigation_polygon: NavigationPolygon

@onready var _art: Sprite2D = $Art


func _ready() -> void:
	_art.centered = false
	if not Engine.is_editor_hint():
		_add_navigation()
	if ResourceLoader.exists(art_path):
		_art.texture = load(art_path)
	else:
		_art.texture = ImageTexture.create_from_image(_placeholder_image())


func _add_navigation() -> void:
	if _navigation_polygon == null:
		_navigation_polygon = _bake_navigation()
	var region := NavigationRegion2D.new()
	region.navigation_polygon = _navigation_polygon
	add_child(region)


## Bakes the floor of one chunk minus its hitboxes. The chunk repeats, so the hitboxes of
## the eight chunks around it are added too, and the bake covers a margin past the chunk
## edges. `border_size` then cuts that margin off again, so neighboring chunks' meshes meet
## edge to edge and enemies can path from one chunk into the next.
func _bake_navigation() -> NavigationPolygon:
	var margin := path_clearance * 4.0
	var polygon := NavigationPolygon.new()
	polygon.agent_radius = path_clearance
	polygon.baking_rect = Rect2(-margin, -margin, SIZE + margin * 2.0, SIZE + margin * 2.0)
	polygon.border_size = margin
	var source := NavigationMeshSourceGeometryData2D.new()
	source.add_traversable_outline(
		PackedVector2Array(
			[
				Vector2(-margin, -margin),
				Vector2(SIZE + margin, -margin),
				Vector2(SIZE + margin, SIZE + margin),
				Vector2(-margin, SIZE + margin),
			]
		)
	)
	for shape in $Obstacles.get_children():
		if not shape is CollisionPolygon2D:
			continue
		var outline: PackedVector2Array = shape.transform * shape.polygon
		for y in range(-1, 2):
			for x in range(-1, 2):
				source.add_obstruction_outline(Transform2D(0.0, Vector2(x, y) * SIZE) * outline)
	NavigationServer2D.bake_from_source_geometry_data(polygon, source)
	return polygon


func _placeholder_image() -> Image:
	var image := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.1, 0.12))
	for i in range(0, SIZE, 64):
		image.fill_rect(Rect2i(i, 0, 1, SIZE), Color(0.16, 0.16, 0.19))
		image.fill_rect(Rect2i(0, i, SIZE, 1), Color(0.16, 0.16, 0.19))
	# Thick lines on the chunk edges, so you can see where one chunk ends.
	image.fill_rect(Rect2i(0, 0, 3, SIZE), Color(0.3, 0.3, 0.36))
	image.fill_rect(Rect2i(0, 0, SIZE, 3), Color(0.3, 0.3, 0.36))
	return image
