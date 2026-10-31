extends Node2D
## TEMP title screen background: the first level's background chunks, drifting slowly.
## Holds a 3x3 ChunkGrid (no camera here, so the grid stays put) and slides it, wrapping
## every chunk so the scroll never ends.

## Pixels per second, and the direction of the drift.
@export var scroll_velocity := Vector2(-54.0, -30.0)
@export var chunk_size := 1024

var _offset := Vector2.ZERO


func _process(delta: float) -> void:
	_offset = (_offset + scroll_velocity * delta).posmodv(Vector2.ONE * chunk_size)
	# Keep the shown part inside the 3x3 grid: start one chunk in, then slide by the offset.
	position = -Vector2.ONE * chunk_size + _offset
