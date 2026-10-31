extends Node2D
## TEMP title screen dancer: one of the little green enemies.
## Waits off screen until `enter()`, flies up to where it was placed in the scene, then dances
## for as long as the title screen is open: it never stops bouncing, and wanders the screen
## from one random spot to the next while it bounces.

## How high each bounce goes, in pixels, and how many bounces per second.
@export var bounce_height := 14.0
@export var bounces_per_second := 2.5
## How far it leans side to side while bouncing, in degrees.
@export var sway_degrees := 12.0
## How fast it wanders between spots, in pixels per second.
@export var wander_speed := 70.0
## Keeps the wandering this far from the screen edges, in pixels.
@export var edge_margin := 40.0
## How long the flight up onto the screen takes.
@export var enter_time := 1.2

var _home := Vector2.ZERO
var _dancing := false
var _time := 0.0
var _target := Vector2.ZERO

@onready var _sprite: Node2D = $Sprite


func _ready() -> void:
	_home = position
	visible = false
	set_process(false)


## Flies up from below the screen after `delay` seconds, then starts dancing.
func enter(delay := 0.0) -> void:
	position = Vector2(_home.x, get_viewport_rect().size.y + 40.0)
	visible = true
	# Bounce on the way up too, so it's dancing from the moment it shows.
	set_process(true)
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, "position", _home, enter_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	_target = _random_spot()
	_dancing = true


func _process(delta: float) -> void:
	_time += delta
	# Bounce: the sprite hops up and lands again and again (abs of a sine wave), leaning
	# the other way on each hop.
	var phase := _time * bounces_per_second * PI
	_sprite.position.y = -absf(sin(phase)) * bounce_height
	_sprite.rotation_degrees = sin(phase * 0.5) * sway_degrees
	if not _dancing:
		return
	# Wander: head for the target spot, and pick a new one on arrival.
	position = position.move_toward(_target, wander_speed * delta)
	if position.is_equal_approx(_target):
		_target = _random_spot()


func _random_spot() -> Vector2:
	var screen := get_viewport_rect().size
	return Vector2(randf_range(edge_margin, screen.x - edge_margin), randf_range(edge_margin, screen.y - edge_margin))
