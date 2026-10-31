class_name TempLevelIntro
extends CanvasLayer
## TEMP level intro: replace later. The title screen adds this to the root just before it
## changes to the level, so it survives the scene change. Once the level is in, it:
## 1. fades the level and its music up from black and silence over FADE_TIME seconds,
## 2. shows "Time to paint this canvas..." in the title's glowing letters,
## 3. smashes "WITH RAINBOW BLOOD" onto the screen, which blows the first line into pixels,
## 4. blows "WITH RAINBOW BLOOD" into pixels too, then lets the game start and frees itself.
## The game stays paused (and input is ignored) until step 4.

const FADE_TIME := 5.0
const LINE_ONE := "Time to paint\nthis canvas..."
const LINE_TWO := "WITH RAINBOW\nBLOOD"
## Seconds "Time to paint" shows before the smash, and "RAINBOW BLOOD" before it explodes.
const LINE_ONE_HOLD := 3.0
const LINE_TWO_HOLD := 1.5
## How long the smash takes to land, and how big the words start.
const SMASH_TIME := 0.18
const SMASH_START_SCALE := 4.0
## How hard and how long the screen shakes when the words land.
const SHAKE_PIXELS := 10.0
const SHAKE_TIME := 1.5
## Every this many pixels of the words becomes one particle.
const PIXEL_STEP := 3

## The developer's voice lines: one when "Time to paint" appears, one as the smash flies in.
const PAINT_VOICE := preload("res://assets/audio/voice/Paint_This_Canvas_Voice.ogg")
const BLOOD_VOICE := preload("res://assets/audio/voice/With_Rainbow_Blood_Voice.ogg")
## Copies of "With Rainbow Blood" played together: [delay in seconds, pitch, volume in dB].
## The extra copies start a moment late and a little lower, so the line sounds bigger.
const BLOOD_LAYERS := [[0.0, 1.0, 0.0], [0.03, 0.94, -4.0], [0.06, 0.88, -6.0]]
const VOICE_BUS := &"Voice"
## Echo delay in milliseconds, how long the echo rings after the voice ends, and bass boost.
const VOICE_ECHO_MS := 220.0
const VOICE_ECHO_TAIL := 0.6
const VOICE_BASS_DB := 6.0

var _voices_playing := 0
var _black: ColorRect
var _music: AudioStreamPlayer


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_black)
	get_tree().scene_changed.connect(_run, CONNECT_ONE_SHOT)


## Swallows every click and key press until the intro is over.
func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func _run() -> void:
	var tree := get_tree()
	# Let the level run two physics frames first (under the black), so the background chunks
	# move into place around the camera. Then freeze it.
	await tree.physics_frame
	await tree.physics_frame
	tree.paused = true
	# The player auto-fires, so those two frames left a shot sitting on it. Clear it away;
	# the next one comes once the game starts.
	for node in tree.current_scene.get_children():
		if node is PlayerShot:
			node.free()
	# Fade the level's music up with the picture. Volume is in decibels, so fade a 0-1 amount instead.
	_music = tree.current_scene.get_node_or_null("Music") as AudioStreamPlayer
	_set_music_level(0.0)
	var fade := create_tween().set_parallel()
	fade.tween_property(_black, "modulate:a", 0.0, FADE_TIME)
	fade.tween_method(_set_music_level, 0.0, 1.0, FADE_TIME)
	await fade.finished
	_black.visible = false

	var line_one := _make_words(LINE_ONE)
	_say(PAINT_VOICE, 0.0, 1.0, 0.0)
	await _wait(LINE_ONE_HOLD)

	# The smash: big and see-through, slamming down to normal size. The voice is layered
	# on itself (see BLOOD_LAYERS) so it hits harder.
	for layer_settings in BLOOD_LAYERS:
		_say(BLOOD_VOICE, layer_settings[0], layer_settings[1], layer_settings[2])
	var line_two := _make_words(LINE_TWO)
	line_two.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	line_two.scale = Vector2.ONE * SMASH_START_SCALE
	line_two.modulate.a = 0.0
	var smash := create_tween().set_parallel()
	smash.tween_property(line_two, "scale", Vector2.ONE, SMASH_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	smash.tween_property(line_two, "modulate:a", 1.0, SMASH_TIME * 0.5)
	await smash.finished
	await _explode(line_one)
	_shake()
	await _wait(LINE_TWO_HOLD)
	await _explode(line_two)

	tree.paused = false
	set_process_input(false)
	await _wait(2.0)
	# Don't cut off a voice (or its echo) that's still going.
	while _voices_playing > 0:
		await _wait(0.25)
	await _wait(VOICE_ECHO_TAIL)
	queue_free()


## Plays `stream` on the Voice bus after `delay` seconds, at `pitch` and `volume_db`.
func _say(stream: AudioStream, delay: float, pitch: float, volume_db: float) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = _voice_bus()
	player.pitch_scale = pitch
	player.volume_db = volume_db
	add_child(player)
	_voices_playing += 1
	if delay > 0.0:
		await _wait(delay)
	player.play()
	await player.finished
	_voices_playing -= 1
	player.queue_free()


## The Voice bus: echo and a little bass on the voice lines. It goes straight to Master, so the
## music volume slider doesn't turn it down. Made here in code (once per run of the game)
## instead of in default_bus_layout.tres, so it's easy to find while this intro is temporary.
func _voice_bus() -> StringName:
	if AudioServer.get_bus_index(VOICE_BUS) != -1:
		return VOICE_BUS
	AudioServer.add_bus()
	var bus := AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus, VOICE_BUS)
	AudioServer.set_bus_send(bus, &"Master")
	# A little bass: lift the two lowest bands of a 6-band EQ.
	var eq := AudioEffectEQ6.new()
	eq.set_band_gain_db(0, VOICE_BASS_DB)
	eq.set_band_gain_db(1, VOICE_BASS_DB * 0.6)
	AudioServer.add_bus_effect(bus, eq)
	# Echo: two repeats, each quieter, without feedback so it dies out cleanly.
	var echo := AudioEffectDelay.new()
	echo.tap1_active = true
	echo.tap1_delay_ms = VOICE_ECHO_MS
	echo.tap1_level_db = -8.0
	echo.tap2_active = true
	echo.tap2_delay_ms = VOICE_ECHO_MS * 2.0
	echo.tap2_level_db = -14.0
	echo.feedback_active = false
	AudioServer.add_bus_effect(bus, echo)
	return VOICE_BUS


func _set_music_level(amount: float) -> void:
	if _music:
		_music.volume_db = linear_to_db(maxf(amount, 0.0001))


func _wait(seconds: float) -> void:
	# The timer must keep running while the game is paused.
	await get_tree().create_timer(seconds, true).timeout


func _make_words(text: String) -> TempTitleLogo:
	var words := TempTitleLogo.new()
	words.text = text
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(words)
	return words


## Swaps `words` for a burst of particles, one per few pixels of the letters, in their colors.
func _explode(words: TempTitleLogo) -> void:
	var image := await _snapshot(words.text)
	words.queue_free()
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	for y in range(0, image.get_height(), PIXEL_STEP):
		for x in range(0, image.get_width(), PIXEL_STEP):
			var color := image.get_pixel(x, y)
			# Only the letters themselves, not their faint glow.
			if color.a < 0.6:
				continue
			color.a = 1.0
			points.append(Vector2(x, y))
			colors.append(color)
	if points.is_empty():
		return
	var burst := CPUParticles2D.new()
	burst.amount = points.size()
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.lifetime = 1.4
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	burst.emission_points = points
	burst.emission_colors = colors
	burst.direction = Vector2.ZERO
	burst.spread = 180.0
	burst.gravity = Vector2(0, 120)
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 260.0
	burst.damping_min = 60.0
	burst.damping_max = 120.0
	burst.scale_amount_min = 2.0
	burst.scale_amount_max = 3.0
	var fade_out := Gradient.new()
	fade_out.set_color(0, Color.WHITE)
	fade_out.set_color(1, Color(1, 1, 1, 0))
	burst.color_ramp = fade_out
	add_child(burst)
	burst.emitting = true
	burst.finished.connect(burst.queue_free)


## Draws the words once, alone on a see-through background, and returns that picture.
## Its pixels line up with the screen, since both are the same size.
func _snapshot(text: String) -> Image:
	var view := SubViewport.new()
	view.size = get_viewport().get_visible_rect().size
	view.transparent_bg = true
	# A SubViewport only draws when shown on screen, unless told to always draw.
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var words := TempTitleLogo.new()
	words.text = text
	words.size = Vector2(view.size)
	view.add_child(words)
	add_child(view)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image := view.get_texture().get_image()
	view.queue_free()
	return image


func _shake() -> void:
	var shake := create_tween()
	var steps := int(SHAKE_TIME * 30.0)
	for i in steps:
		var strength := SHAKE_PIXELS * (1.0 - float(i) / steps)
		shake.tween_property(self, "offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, SHAKE_TIME / steps)
	shake.tween_property(self, "offset", Vector2.ZERO, SHAKE_TIME / steps)
