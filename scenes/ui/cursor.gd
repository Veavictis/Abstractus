extends Sprite2D
## In-game mouse cursor. Drawn in the game's pixel space, so it scales with the art.
## Uses the PNG at `art_path` if it exists (its center is the aim point), otherwise a
## placeholder crosshair.

@export_file("*.png") var art_path := "res://assets/art/ui/cursor.png"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if ResourceLoader.exists(art_path):
		texture = load(art_path)
	else:
		texture = ImageTexture.create_from_image(_placeholder_image())


func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()


func _placeholder_image() -> Image:
	var image := Image.create_empty(15, 15, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(7, 0, 1, 5), Color.WHITE)
	image.fill_rect(Rect2i(7, 10, 1, 5), Color.WHITE)
	image.fill_rect(Rect2i(0, 7, 5, 1), Color.WHITE)
	image.fill_rect(Rect2i(10, 7, 5, 1), Color.WHITE)
	return image
