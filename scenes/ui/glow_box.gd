@tool
class_name GlowBox
extends PanelContainer
## A black box whose border glows in the title logo's colors, flowing slowly around the edge.
## Used by the pause menu. Put the contents inside it like any PanelContainer.

## Same colors as the title logo (scenes/main/temp_title_logo.gd).
@export var colors: Array[Color] = [
	Color("ff4d6d"), Color("ff9f43"), Color("ffd93d"), Color("6bff6b"), Color("3dffd0"),
	Color("3dc8ff"), Color("5b7cff"), Color("a35bff"), Color("ff5bd8"), Color("ff6b9d"),
]
@export var background := Color.BLACK
## Room between the border and the contents.
@export var padding := 20
## How far the glow reaches outside the border, in pixels.
@export var glow_size := 8
## How many times per second the colors travel all the way around the border.
@export var flow_speed := 0.1
## Length of each piece of border drawn in one color, in pixels. Smaller is smoother.
@export var segment := 4.0

var _time := 0.0


func _ready() -> void:
	var style := StyleBoxEmpty.new()
	style.set_content_margin_all(padding)
	add_theme_stylebox_override("panel", style)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, background)
	# Walk around the border; each step gets the color for its place along the edge.
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, 0), rect.end, Vector2(0, rect.end.y)]
	var perimeter := 2.0 * (size.x + size.y)
	var walked := 0.0
	for side in 4:
		var from := corners[side]
		var to := corners[(side + 1) % 4]
		var length := from.distance_to(to)
		var steps := maxi(1, ceili(length / segment))
		for s in steps:
			var a := from.lerp(to, float(s) / steps)
			var b := from.lerp(to, float(s + 1) / steps)
			var color := _color_at(fposmod((walked + length * (s + 0.5) / steps) / perimeter - _time * flow_speed, 1.0))
			# Glow: wide and faint first, then the bright line on top.
			for layer in 3:
				var glow := color
				glow.a = 0.12 + 0.12 * layer
				draw_line(a, b, glow, glow_size * (3 - layer) * 0.7)
			draw_line(a, b, color.lightened(0.3), 2.0)
		walked += length


## Color at a point 0-1 of the way around the border, blending between neighbouring colors.
func _color_at(t: float) -> Color:
	var scaled := t * colors.size()
	var i := int(scaled) % colors.size()
	return colors[i].lerp(colors[(i + 1) % colors.size()], scaled - floorf(scaled))
