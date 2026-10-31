extends Control
## Entry scene: the TEMP title screen (replace later). Glowing logo, then Play, Options and Exit.
## Options is a placeholder panel with the music volume until we decide what goes in it.
##
## Title music: select the `Music` node in main.tscn and drag a track onto its Stream
## (for an .ogg, turn on Loop in its Import tab). It plays on the Music bus, so the
## volume slider controls it.

const GAME_SCENE := "res://scenes/levels/test_level.tscn"
## The screen fades up from black for this long, and nothing can be clicked or pressed until it ends.
const FADE_TIME := 5.0

## After the first two dancers, two more fly in every DANCER_INTERVAL seconds, up to MAX_DANCERS.
const DANCER_INTERVAL := 4.0
const MAX_DANCERS := 20
## After Play, the screen and the music fade out for this long before the level starts.
const FADE_OUT_TIME := 3.0
const BURST_SCENE := preload("res://scenes/effects/pixel_burst.tscn")

var _fading := true
var _dancers := 0


func _ready() -> void:
	print("Abstractus v%s" % Game.version)
	%Play.pressed.connect(_play)
	%Options.pressed.connect(_open_options)
	%Exit.pressed.connect(get_tree().quit)
	%Back.pressed.connect(_close_options)
	%MusicVolume.value = Game.music_volume
	%MusicVolume.value_changed.connect(Game.set_music_volume)
	%OptionsPanel.visible = false
	# The music starts at full volume with the fade.
	if %Music.stream:
		%Music.play()
	var tween := create_tween()
	tween.tween_property(%FadeIn, "modulate:a", 0.0, FADE_TIME)
	tween.finished.connect(_on_fade_finished)


## Blows up every dancer, fades the screen and music out, then starts the level with its intro.
func _play() -> void:
	_fading = true
	for dancer: Node2D in get_tree().get_nodes_in_group("title_dancers"):
		if dancer.visible:
			var burst: PixelBurst = BURST_SCENE.instantiate()
			burst.position = dancer.position
			# Bigger than an in-game death: lasts 3x longer and flies 3x further
			# (3x the speed and 3x the slowing down covers 3x the distance).
			burst.lifetime *= 3.0
			burst.initial_velocity_min *= 3.0
			burst.initial_velocity_max *= 3.0
			burst.damping_min *= 3.0
			burst.damping_max *= 3.0
			add_child(burst)
			burst.burst_from(dancer.get_node("Sprite").texture)
		dancer.queue_free()
	%FadeIn.visible = true
	var start_db: float = %Music.volume_db
	var fade := create_tween().set_parallel()
	fade.tween_property(%FadeIn, "modulate:a", 1.0, FADE_OUT_TIME)
	# Volume is in decibels, so fade a 0-1 amount and convert it.
	fade.tween_method(func(amount: float) -> void: %Music.volume_db = start_db + linear_to_db(maxf(amount, 0.0001)), 1.0, 0.0, FADE_OUT_TIME)
	await fade.finished
	# The intro lives on the root so it survives the scene change, then runs over the level.
	get_tree().root.add_child(TempLevelIntro.new())
	get_tree().change_scene_to_file(GAME_SCENE)


## Swallows every click and key press while the screen is fading (up, or out after Play).
func _input(_event: InputEvent) -> void:
	if _fading:
		get_viewport().set_input_as_handled()


func _on_fade_finished() -> void:
	_fading = false
	%FadeIn.visible = false
	%Play.grab_focus()
	%DancerLeft.enter()
	%DancerRight.enter(0.3)
	_dancers = 2
	var timer := Timer.new()
	timer.wait_time = DANCER_INTERVAL
	timer.timeout.connect(_add_dancers.bind(timer))
	add_child(timer)
	timer.start()


## Two more dancers fly up at random spots along the bottom, until there are MAX_DANCERS.
func _add_dancers(timer: Timer) -> void:
	if _fading:
		return
	var screen := get_viewport_rect().size
	for i in 2:
		var dancer: Node2D = %DancerLeft.duplicate()
		dancer.position = Vector2(randf_range(60.0, screen.x - 60.0), randf_range(screen.y * 0.4, screen.y - 60.0))
		# Next to the first two, so it stays behind the logo and buttons.
		%DancerRight.add_sibling(dancer)
		dancer.enter(i * 0.3)
	_dancers += 2
	if _dancers >= MAX_DANCERS:
		timer.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Escape (or B) backs out of Options.
	if %OptionsPanel.visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		_close_options()
		get_viewport().set_input_as_handled()


func _open_options() -> void:
	%Menu.visible = false
	%OptionsPanel.visible = true
	%MusicVolume.grab_focus()


func _close_options() -> void:
	%OptionsPanel.visible = false
	%Menu.visible = true
	%Options.grab_focus()
