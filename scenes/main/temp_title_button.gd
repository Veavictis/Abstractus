extends Button
## TEMP title menu button: replace with the real menu later.
## Hides the normal button look and draws its text with a TempTitleLogo instead, so it glows in
## the logo's colors. While hovered (or selected with the keyboard or a gamepad) it glows
## 50% brighter and gives off the player's rainbow pixel trail in all directions.

const TRAIL_SCENE := preload("res://scenes/effects/rainbow_trail.tscn")

## How bright the text gets while hovered.
@export var hover_brightness := 1.5
## Seconds to fade between normal and hovered.
@export var fade_time := 0.15
@export var label_font_size := 22

var _label: TempTitleLogo
var _trail: CPUParticles2D
var _tween: Tween


func _ready() -> void:
	# Draw the text ourselves; keep the button for clicks, focus and keyboard/gamepad.
	_label = TempTitleLogo.new()
	_label.text = text
	_label.font_size = label_font_size
	_label.glow_size = 4
	_label.letter_spacing = 1.0
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_label)
	text = ""
	flat = true
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	custom_minimum_size.y = label_font_size + 14

	# The player's trail, but standing still and spraying from the whole word.
	_trail = TRAIL_SCENE.instantiate()
	_trail.set_script(null)
	_trail.emitting = false
	_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	# The scene puts it below everything (behind the player); here it only goes behind the text.
	_trail.z_index = 0
	# Faster than on the player, so the pixels fly out from the word instead of hanging on it.
	_trail.initial_velocity_min = 20.0
	_trail.initial_velocity_max = 50.0
	_trail.lifetime = 0.8
	add_child(_trail)
	move_child(_trail, 0)

	# Hovering selects the button, so the mouse and the keyboard never light up two at once.
	mouse_entered.connect(grab_focus)
	focus_entered.connect(_set_hovered.bind(true))
	focus_exited.connect(_set_hovered.bind(false))
	resized.connect(_fit_trail)
	_fit_trail()


func _fit_trail() -> void:
	_trail.position = size / 2.0
	_trail.emission_rect_extents = Vector2(_label.text_width() / 2.0, label_font_size * 0.35)


func _set_hovered(hovered: bool) -> void:
	_trail.emitting = hovered
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_label, "brightness", hover_brightness if hovered else 1.0, fade_time)
