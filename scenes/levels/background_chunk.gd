@tool
extends Node2D
## One 1024x1024 background chunk: the painting plus the obstacle hitboxes traced over it.
##
## Open `background_chunk.tscn` and add CollisionPolygon2D children to `Obstacles` to
## trace hitboxes. The painting shows in the editor so you can trace right on it.

const SIZE := 1024

@export_file("*.png") var art_path := "res://assets/art/backgrounds/test_chunk.png"

@onready var _art: Sprite2D = $Art


func _ready() -> void:
	_art.centered = false
	if ResourceLoader.exists(art_path):
		_art.texture = load(art_path)
	else:
		_art.texture = ImageTexture.create_from_image(_placeholder_image())


func _placeholder_image() -> Image:
	var image := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.1, 0.12))
	for i in range(0, SIZE, 64):
		image.fill_rect(Rect2i(i, 0, 1, SIZE), Color(0.16, 0.16, 0.19))
		image.fill_rect(Rect2i(0, i, SIZE, 1), Color(0.16, 0.16, 0.19))
	# Thick lines on the chunk edges, so you can see where one chunk ends.
	image.fill_rect(Rect2i(0, 0, 3, SIZE), Color(0.3, 0.3, 0.36))
	image.fill_rect(Rect2i(0, 0, SIZE, 3), Color(0.3, 0.3, 0.36))
	# Matches the ExampleObstacle hitbox. Delete both once your painting is in.
	image.fill_rect(Rect2i(640, 640, 128, 128), Color(0.35, 0.3, 0.3))
	return image
