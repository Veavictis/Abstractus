class_name PixelBurst
extends CPUParticles2D
## One-shot burst of pixels in a sprite's dominant colors, for when an enemy dies.
## Frees itself when the pixels have faded.

## How many of the sprite's most common colors the pixels use.
const COLOR_COUNT := 4

## Dominant colors per texture, so each sprite is only analysed once.
static var _palette_cache := {}


## Starts the burst using the most common colors of `texture`.
func burst_from(texture: Texture2D) -> void:
	var colors := dominant_colors(texture)
	var ramp := Gradient.new()
	ramp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	ramp.offsets = PackedFloat32Array()
	ramp.colors = PackedColorArray()
	for i in colors.size():
		ramp.add_point(float(i) / colors.size(), colors[i])
	color_initial_ramp = ramp
	emitting = true
	finished.connect(queue_free)


static func dominant_colors(texture: Texture2D) -> Array[Color]:
	if _palette_cache.has(texture):
		return _palette_cache[texture]
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	# Group similar colors into buckets, then keep the average color of the biggest ones.
	var buckets := {}
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				continue
			var key := Vector3i(int(color.r * 7.99), int(color.g * 7.99), int(color.b * 7.99))
			var entry: Array = buckets.get(key, [0, Color(0, 0, 0, 0)])
			entry[0] += 1
			entry[1] += color
			buckets[key] = entry
	var entries := buckets.values()
	entries.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	var colors: Array[Color] = []
	for entry: Array in entries.slice(0, COLOR_COUNT):
		var average: Color = entry[1] / float(entry[0])
		average.a = 1.0
		colors.append(average)
	if colors.is_empty():
		colors.append(Color.WHITE)
	_palette_cache[texture] = colors
	return colors
