class_name PixelGlow
extends RefCounted
## Helpers for `assets/shaders/pixel_glow.gdshader`.


## Returns `texture` with `padding` transparent pixels on every side, so the glow
## around the art has room to draw. The art stays centered.
static func padded(texture: Texture2D, padding: int) -> Texture2D:
	var source := texture.get_image()
	if source.is_compressed():
		source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var size := source.get_size() + Vector2i(padding, padding) * 2
	var image := Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i(padding, padding))
	return ImageTexture.create_from_image(image)
