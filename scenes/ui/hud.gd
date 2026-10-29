class_name Hud
extends CanvasLayer
## In-level overlay: health, shard counter, timer, deaths, short messages, and the level complete panel.

var _deaths := 0
var _time := 0.0
var _message_tween: Tween

@onready var _shards: Label = $Shards
@onready var _health: Label = $Health
@onready var _stats: Label = $Stats
@onready var _message: Label = $Message
@onready var _win_panel: Control = $WinPanel
@onready var _win_text: Label = $WinPanel/Text


func _ready() -> void:
	_win_panel.hide()
	_message.modulate.a = 0.0


func show_level(level_name: String) -> void:
	flash_message(level_name)


func set_shards(collected: int, total: int) -> void:
	_shards.text = "Crystals %d / %d" % [collected, total]


func set_health(health: int, max_health: int) -> void:
	_health.text = "Health %d / %d" % [health, max_health]


func set_deaths(deaths: int) -> void:
	_deaths = deaths
	_update_stats()


func set_time(seconds: float) -> void:
	_time = seconds
	_update_stats()


func flash_message(text: String) -> void:
	_message.text = text
	if _message_tween:
		_message_tween.kill()
	_message.modulate.a = 1.0
	_message_tween = create_tween()
	_message_tween.tween_interval(1.5)
	_message_tween.tween_property(_message, "modulate:a", 0.0, 0.5)


func show_win(seconds: float, deaths: int) -> void:
	_win_text.text = (
		"Level complete!\n\nTime %s    Deaths %d\n\nEnter / (A): play again\nEsc / (B): title screen"
		% [_format_time(seconds), deaths]
	)
	_win_panel.show()


func _update_stats() -> void:
	_stats.text = "%s   Deaths %d" % [_format_time(_time), _deaths]


func _format_time(seconds: float) -> String:
	return "%d:%04.1f" % [int(seconds) / 60, fmod(seconds, 60.0)]
