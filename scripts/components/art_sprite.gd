class_name ArtSprite
extends Sprite2D
## Shows the PNG at `art_path` if it exists, otherwise a plain placeholder box.
##
## A PNG wider than `frame_size` is read as a horizontal strip of frames
## (Aseprite: File > Export Sprite Sheet, Layout "Horizontal Strip") and loops at `fps`.

@export_file("*.png") var art_path: String
@export var frame_size := Vector2i(48, 48)
@export var placeholder_color := Color(0.8, 0.8, 0.8)
@export var fps := 8.0

var _time := 0.0


func _ready() -> void:
	if ResourceLoader.exists(art_path):
		texture = load(art_path)
		hframes = maxi(1, texture.get_width() / frame_size.x)
	else:
		texture = ImageTexture.create_from_image(_placeholder_image())
		hframes = 1
	set_process(hframes > 1)


func _process(delta: float) -> void:
	_time += delta
	frame = int(_time * fps) % hframes


func _placeholder_image() -> Image:
	var image := Image.create_empty(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	image.fill(placeholder_color.darkened(0.5))
	image.fill_rect(Rect2i(Vector2i.ONE, frame_size - Vector2i(2, 2)), placeholder_color)
	return image
