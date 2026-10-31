@tool
class_name TempTitleLogo
extends Control
## TEMP title logo: replace with the real logo art later.
## Draws "ABSTRACTUS" one letter at a time, each in its own color. Every letter has a soft
## glow around its edges, and its inside pulses between a dim and a bright shade of its color.
## @tool makes it animate in the editor too, so you can see changes without running the game.

@export var text := "ABSTRACTUS"
@export var font_size := 72
## Leave empty to use Godot's default font.
@export var font: Font
## Placeholder colors, one per letter (they repeat if there are more letters than colors).
@export var letter_colors: Array[Color] = [
	Color("ff4d6d"), Color("ff9f43"), Color("ffd93d"), Color("6bff6b"), Color("3dffd0"),
	Color("3dc8ff"), Color("5b7cff"), Color("a35bff"), Color("ff5bd8"), Color("ff6b9d"),
]
## Extra space between letters, in pixels.
@export var letter_spacing := 4.0
## How far the glow reaches past each letter's edge, in pixels.
@export var glow_size := 12
## Pulses per second.
@export var pulse_speed := 0.8
## Each letter's pulse starts a little after the one before it, so a wave runs across the word.
@export var pulse_wave := 0.35
## Multiplies the glow and the brightness of the inside. The menu buttons go to 1.5 on hover.
@export var brightness := 1.0

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var font := _font()
	var widths := _letter_widths()
	var total := text_width()
	# Center the word in this control. The baseline sits so the capitals are vertically centered.
	var x := (size.x - total) / 2.0
	var baseline := (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0

	for i in text.length():
		var letter := text[i]
		var color := letter_colors[i % letter_colors.size()]
		var pos := Vector2(x, baseline)
		# 0 to 1 and back, offset per letter.
		var pulse := 0.5 + 0.5 * sin(TAU * (_time * pulse_speed) - i * pulse_wave)

		# Glow: the letter's outline drawn several times, wide and faint to thin and strong.
		var layers := 5
		for layer in layers:
			var t := float(layer) / (layers - 1)
			var outline := int(lerpf(glow_size * 2.0, 2.0, t))
			var glow := color
			glow.a = minf(lerpf(0.1, 0.5, t) * (0.7 + 0.3 * pulse) * brightness, 1.0)
			draw_string_outline(font, pos, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline, glow)
		# Bright edge, then the pulsing inside.
		draw_string_outline(font, pos, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 2, color.lightened(0.5))
		var inside := color.darkened(0.55).lerp(color.lightened(0.15), pulse)
		inside = Color(inside.r * brightness, inside.g * brightness, inside.b * brightness)
		draw_string(font, pos, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, inside)

		x += widths[i] + letter_spacing


## Width of the whole word, letter spacing included.
func text_width() -> float:
	var total := 0.0
	for w in _letter_widths():
		total += w
	return total + letter_spacing * maxf(text.length() - 1, 0)


func _letter_widths() -> Array[float]:
	var widths: Array[float] = []
	for letter in text:
		widths.append(_font().get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
	return widths


func _font() -> Font:
	return font if font else get_theme_default_font()
