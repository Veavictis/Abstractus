class_name BeatPulse
extends Node
## Listens to the Music bus, works out the song's tempo, and keeps a steady beat in time
## with it, so any track works. On each beat it starts a ring of color that spreads out
## from `center` (the player), drawn by the background shader.
##
## How it hears a beat: the bus's SpectrumAnalyzer effect (default_bus_layout.tres) reports
## how loud each frequency is. Kick drums live in the low end, so this tracks the loudness
## of that band and counts a "hit" when it jumps well above its recent average.
##
## How it keeps the beat steady: raw hits are uneven (some kicks are missed, other sounds
## sneak in). The hits of the last few seconds are lined up on an even grid of beats, and
## the rings fire on that grid, so they come at a steady pace even when kicks are missed.
##
## Shader values it sets every frame (declared in project.godot):
## `beat_origin` (world position of the rings' center), `beat_ages` (seconds since each of
## the last 4 rings started; large means none) and `beat_color_0`..`beat_color_3`.

signal beat

const RING_SLOTS := 4
## An age past every ring's lifetime, for empty slots.
const NO_RING := 1000.0
## Seconds of hits used to find the tempo.
const TEMPO_WINDOW := 8.0
## Hits in a row that don't fit the tempo before it looks for a new one (a new song).
const MISFITS_BEFORE_RETEMPO := 12

## The rings spread out from this node. Leave empty for the screen center.
@export var center: Node2D
## Low end of the song to listen to, in Hz. Kick drums sit around 40-150.
@export var low_hz := 40.0
@export var high_hz := 150.0
## How far above the recent average counts as a hit. Lower catches more.
@export var sensitivity := 1.4
## Tempo range to look for, in beats per minute.
@export var min_bpm := 80.0
@export var max_bpm := 180.0
## Colors to step through, one per beat.
@export var colors: Array[Color] = [
	Color(0.37, 0.89, 0.94),
	Color(0.62, 0.36, 0.95),
	Color(0.36, 0.95, 0.5),
	Color(0.95, 0.76, 0.31),
]

var _analyzer: AudioEffectSpectrumAnalyzerInstance
var _time := 0.0
var _average := 0.0
var _last_hit := -1.0
## Times of the hits in the last TEMPO_WINDOW seconds.
var _hits: Array[float] = []
## Seconds per beat. 0 until the tempo is known; until then each hit is a beat.
var _period := 0.0
## When a beat falls (any beat on the grid) and when the last one fired.
var _grid_start := 0.0
var _last_beat := -1.0
var _misfits := 0
var _ages := PackedFloat32Array()
var _slot := 0
var _color_index := -1


func _ready() -> void:
	# Keeps going while paused, since the music keeps playing then too.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bus := AudioServer.get_bus_index("Music")
	if bus != -1 and AudioServer.get_bus_effect_count(bus) > 0:
		_analyzer = AudioServer.get_bus_effect_instance(bus, 0) as AudioEffectSpectrumAnalyzerInstance
	_ages.resize(RING_SLOTS)
	_ages.fill(NO_RING)


func _process(delta: float) -> void:
	_time += delta
	for i in RING_SLOTS:
		_ages[i] = minf(_ages[i] + delta, NO_RING)
	if _analyzer != null:
		var level := _analyzer.get_magnitude_for_frequency_range(low_hz, high_hz).length()
		# The average follows the level slowly (about the last half second).
		_average = lerpf(_average, level, minf(delta * 2.0, 1.0))
		var min_gap := 60.0 / max_bpm * 0.5
		if level > _average * sensitivity and level > 0.002 and _time - _last_hit >= min_gap:
			_on_hit()
	if _period > 0.0:
		# The latest beat on the grid. Fire it once; the half-beat check stops a grid
		# update from firing the same beat twice.
		var beat_time := _grid_start + floorf((_time - _grid_start) / _period) * _period
		if beat_time > _last_beat + _period * 0.5:
			_last_beat = beat_time
			_on_beat()
	_send_to_shader()


func _on_hit() -> void:
	_last_hit = _time
	_hits.append(_time)
	while _time - _hits[0] > TEMPO_WINDOW:
		_hits.pop_front()
	if _hits.size() < 6:
		# Until the tempo is known, every hit is a beat.
		if _period <= 0.0:
			_on_beat()
		return
	if _period > 0.0:
		if _fit_grid(_period):
			_misfits = 0
			return
		# A quiet or busy part of the song can blur the beat for a while. Keep the tempo
		# through it, and only look for a new one after many hits that don't fit.
		_misfits += 1
		if _misfits < MISFITS_BEFORE_RETEMPO:
			return
	if _fit_grid(_score_tempo()):
		_misfits = 0
	elif _period <= 0.0:
		_on_beat()


## Finds a rough tempo. Every beat length in the tempo range is scored by how many gaps of
## one or two beats between hits (not just neighbours) fit that length. Off-beat sounds
## fit no length well, so they barely count.
func _score_tempo() -> float:
	var best_period := 0.0
	var best_score := 0.0
	var length := 60.0 / max_bpm
	while length <= 60.0 / min_bpm:
		var score := 0.0
		for i in _hits.size():
			for j in range(i + 1, _hits.size()):
				var gap := _hits[j] - _hits[i]
				if gap > 2.5 * length:
					break
				var miss := absf(gap - roundf(gap / length) * length)
				score += exp(-pow(miss / 0.03, 2.0))
		if score > best_score:
			best_score = score
			best_period = length
		length += 0.002
	return best_period


## Lines the recent hits up on a grid of beats `guess` apart, then fits the straight line
## through them (least squares), which gives the exact beat length and where the beats
## fall. Hits far from the grid (off-beat sounds) are left out. Returns false when too few
## hits fit, meaning the guess is wrong.
func _fit_grid(guess: float) -> bool:
	if guess <= 0.0:
		return false
	var anchor := _hits[-1]
	var n := 0.0
	var sum_k := 0.0
	var sum_t := 0.0
	var sum_kk := 0.0
	var sum_kt := 0.0
	for hit in _hits:
		var beats := (hit - anchor) / guess
		var k := roundf(beats)
		if absf(beats - k) > 0.2:
			continue
		n += 1.0
		sum_k += k
		sum_t += hit
		sum_kk += k * k
		sum_kt += k * hit
	var spread := n * sum_kk - sum_k * sum_k
	if n < maxf(5.0, _hits.size() * 0.5) or spread <= 0.0:
		return false
	var length := (n * sum_kt - sum_k * sum_t) / spread
	if absf(length - guess) > guess * 0.1:
		return false
	_period = length
	_grid_start = (sum_t - length * sum_k) / n
	return true

func _on_beat() -> void:
	_slot = (_slot + 1) % RING_SLOTS
	_ages[_slot] = 0.0
	if not colors.is_empty():
		_color_index = (_color_index + 1) % colors.size()
		RenderingServer.global_shader_parameter_set("beat_color_%d" % _slot, colors[_color_index])
	beat.emit()


func _send_to_shader() -> void:
	var origin := get_viewport().get_camera_2d().get_screen_center_position() \
		if get_viewport().get_camera_2d() != null else Vector2.ZERO
	if is_instance_valid(center):
		origin = center.global_position
	RenderingServer.global_shader_parameter_set("beat_origin", origin)
	RenderingServer.global_shader_parameter_set(
		"beat_ages", Vector4(_ages[0], _ages[1], _ages[2], _ages[3])
	)
