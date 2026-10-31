@tool
class_name TempTitleLogo
extends Control
## TEMP title logo: replace with the real logo art later.
## Draws "ABSTRACTUS" one letter at a time, each in its own color. Every letter has a soft
## glow around its edges, and its inside pulses between a dim and a bright shade of its color.
## @tool makes it animate in the editor too, so you can see changes without running the game.

@export var text := "ABSTRACTUS"
@export var font_size := 72
## Leave empty to use Orbitron (assets/fonts) at `weight`.
@export var font: Font
## Orbitron's thickness when `font` is empty: 400 regular, 700 bold, 900 black.
@export_range(400, 900, 100) var weight := 700
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

const ORBITRON := preload("res://assets/fonts/Orbitron-Variable.ttf")

var _time := 0.0
var _orbitron: FontVariation
var _orbitron_weight := 0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# A "\n" in `text` starts a new line; each line is centered on its own.
	var lines := text.split("\n")
	var font := _font()
	var line_height := font.get_height(font_size)
	# The baseline of the first line sits so the whole block is vertically centered.
	var baseline := (size.y - line_height * lines.size()) / 2.0 + font.get_ascent(font_size)
	var i := 0
	for line in lines:
		var x := (size.x - _line_width(line)) / 2.0
		for letter in line:
			_draw_letter(font, letter, Vector2(x, baseline), i)
			x += _letter_width(letter) + letter_spacing
			i += 1
		baseline += line_height


## Draws letter number `i` (counted across all lines, for its color and pulse).
func _draw_letter(font: Font, letter: String, pos: Vector2, i: int) -> void:
	var color := letter_colors[i % letter_colors.size()]
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


## Width of the widest line, letter spacing included.
func text_width() -> float:
	var widest := 0.0
	for line in text.split("\n"):
		widest = maxf(widest, _line_width(line))
	return widest


func _line_width(line: String) -> float:
	var total := 0.0
	for letter in line:
		total += _letter_width(letter)
	return total + letter_spacing * maxf(line.length() - 1, 0)


func _letter_width(letter: String) -> float:
	return _font().get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


func _font() -> Font:
	if font:
		return font
	if _orbitron == null or _orbitron_weight != weight:
		# Orbitron is a variable font: one file, any weight, picked through its "wght" axis.
		_orbitron = FontVariation.new()
		_orbitron.base_font = ORBITRON
		_orbitron.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
		_orbitron_weight = weight
	return _orbitron
