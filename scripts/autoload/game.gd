extends Node
## Global game state, available everywhere as `Game`.

const SETTINGS_PATH := "user://settings.cfg"
## Music starts 15% below full volume until the player changes it.
const DEFAULT_MUSIC_VOLUME := 0.85

var version: String = ProjectSettings.get_setting("application/config/version", "0.0.0")
## 0.0 (silent) to 1.0 (full). Change it with set_music_volume so it's applied and saved.
var music_volume := DEFAULT_MUSIC_VOLUME


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		music_volume = config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
	_apply_music_volume()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_music_volume()
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "music_volume", music_volume)
	config.save(SETTINGS_PATH)


## Sets the Music bus (default_bus_layout.tres). Bus volume is in decibels,
## so the 0-1 value is converted; 0 mutes the bus instead.
func _apply_music_volume() -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus == -1:
		return
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(music_volume, 0.0001)))
	AudioServer.set_bus_mute(bus, music_volume <= 0.0)
