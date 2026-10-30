class_name RepeatingBackground
extends Sprite2D
## Repeats one seamless chunk forever in every direction around the camera.
##
## Uses the PNG at `art_path` if it exists, otherwise a placeholder grid so movement is visible.

## Chunks drawn across and down. 3 covers any screen smaller than one chunk.
const CHUNKS := 3

@export_file("*.png") var art_path := "res://assets/art/backgrounds/test_chunk.png"
@export var chunk_size := 1024


func _ready() -> void:
	z_index = -100
	centered = false
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_enabled = true
	region_rect = Rect2(0, 0, chunk_size * CHUNKS, chunk_size * CHUNKS)
	if ResourceLoader.exists(art_path):
		texture = load(art_path)
		chunk_size = texture.get_width()
		region_rect = Rect2(0, 0, chunk_size * CHUNKS, chunk_size * CHUNKS)
	else:
		texture = ImageTexture.create_from_image(_placeholder_image())


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var cell := (camera.get_screen_center_position() / chunk_size).floor()
	global_position = (cell - Vector2.ONE) * chunk_size


func _placeholder_image() -> Image:
	var image := Image.create_empty(chunk_size, chunk_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.1, 0.12))
	for i in range(0, chunk_size, 64):
		image.fill_rect(Rect2i(i, 0, 1, chunk_size), Color(0.16, 0.16, 0.19))
		image.fill_rect(Rect2i(0, i, chunk_size, 1), Color(0.16, 0.16, 0.19))
	# Thick lines on the chunk edges, so you can see where one chunk ends.
	image.fill_rect(Rect2i(0, 0, 3, chunk_size), Color(0.3, 0.3, 0.36))
	image.fill_rect(Rect2i(0, 0, chunk_size, 3), Color(0.3, 0.3, 0.36))
	return image
