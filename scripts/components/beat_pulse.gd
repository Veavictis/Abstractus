class_name BeatPulse
extends Node
## Listens to the Music bus and finds the beats while the song plays, so any track works.
## On each beat it picks the next color and sets two global shader values that every
## shader can read: `beat_pulse` (1.0 on the beat, fading to 0) and `beat_color`.
##
## How it hears a beat: the bus's SpectrumAnalyzer effect (default_bus_layout.tres) reports
## how loud each frequency is. Kick drums live in the low end, so this tracks the loudness
## of that band and calls it a beat when it jumps well above its recent average.

signal beat

## Low end of the song to listen to, in Hz. Kick drums sit around 40-150.
@export var low_hz := 40.0
@export var high_hz := 150.0
## How far above the recent average counts as a beat. Lower catches more beats.
@export var sensitivity := 1.4
## Shortest time between beats, in seconds, so one kick doesn't count twice.
@export var min_gap := 0.2
## How fast the flash fades after a beat. Higher is a shorter flash.
@export var fade_speed := 4.0
## Colors to step through, one per beat.
@export var colors: Array[Color] = [
	Color(0.37, 0.89, 0.94),
	Color(0.62, 0.36, 0.95),
	Color(0.36, 0.95, 0.5),
	Color(0.95, 0.76, 0.31),
]

var _analyzer: AudioEffectSpectrumAnalyzerInstance
var _average := 0.0
var _since_beat := 0.0
var _pulse := 0.0
var _color_index := -1


func _ready() -> void:
	# Keeps reacting while paused, since the music keeps playing then too.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bus := AudioServer.get_bus_index("Music")
	if bus != -1 and AudioServer.get_bus_effect_count(bus) > 0:
		_analyzer = AudioServer.get_bus_effect_instance(bus, 0) as AudioEffectSpectrumAnalyzerInstance
	RenderingServer.global_shader_parameter_set("beat_pulse", 0.0)


func _process(delta: float) -> void:
	_since_beat += delta
	_pulse = maxf(_pulse - fade_speed * delta, 0.0)
	if _analyzer != null:
		var level := _analyzer.get_magnitude_for_frequency_range(low_hz, high_hz).length()
		# The average follows the level slowly (about the last half second).
		_average = lerpf(_average, level, minf(delta * 2.0, 1.0))
		if level > _average * sensitivity and level > 0.002 and _since_beat >= min_gap:
			_on_beat()
	RenderingServer.global_shader_parameter_set("beat_pulse", _pulse)


func _on_beat() -> void:
	_since_beat = 0.0
	_pulse = 1.0
	if not colors.is_empty():
		_color_index = (_color_index + 1) % colors.size()
		RenderingServer.global_shader_parameter_set("beat_color", colors[_color_index])
	beat.emit()
