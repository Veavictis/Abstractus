extends Node2D
## TEMP title screen dancer: one of the little green enemies.
## Waits off screen until `enter()`, flies up to where it was placed in the scene, then loops:
## bounce around (each hop a little bigger than the last), go back home, bob slowly, bounce again.
## The bouncing starts the moment it arrives, so it lands right when the music hits.

## How far the bob goes up and down, in pixels, and how long one bob takes.
@export var bob_height := 4.0
@export var bob_time := 1.2
## How many slow bobs before each round of bouncing.
@export var bobs := 3
## How many hops in a round of bouncing, how far each can go, and how long each takes.
## The hops grow from small up to `hop_reach` over the round.
@export var hops := 6
@export var hop_reach := Vector2(36, 24)
@export var hop_time := 0.22
## How long the flight up onto the screen takes.
@export var enter_time := 1.2

var _home := Vector2.ZERO


func _ready() -> void:
	_home = position
	visible = false


## Flies up from below the screen after `delay` seconds, then starts dancing.
func enter(delay := 0.0) -> void:
	position = Vector2(_home.x, get_viewport_rect().size.y + 40.0)
	visible = true
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, "position", _home, enter_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	_dance()


func _dance() -> void:
	while is_inside_tree():
		var tween := create_tween()
		for i in hops:
			# Each hop reaches a little further than the one before.
			var reach := hop_reach * float(i + 1) / hops
			var spot := _home + Vector2(randf_range(-1, 1) * reach.x, -randf_range(0.3, 1.0) * reach.y)
			tween.tween_property(self, "position", spot, hop_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", _home, hop_time * 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		for i in bobs:
			tween.tween_property(self, "position:y", _home.y - bob_height, bob_time / 2.0).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "position:y", _home.y, bob_time / 2.0).set_trans(Tween.TRANS_SINE)
		await tween.finished
