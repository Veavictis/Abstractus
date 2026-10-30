class_name ChunkGrid
extends Node2D
## Repeats a background chunk scene forever in every direction around the camera.
## Keeps a 3x3 block of chunks and moves it as the camera crosses chunk edges.

@export var chunk_scene: PackedScene = preload("res://scenes/levels/background_chunk.tscn")
@export var chunk_size := 1024


func _ready() -> void:
	for y in 3:
		for x in 3:
			var chunk: Node2D = chunk_scene.instantiate()
			chunk.position = Vector2(x, y) * chunk_size
			add_child(chunk)


func _physics_process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var cell := (camera.get_screen_center_position() / chunk_size).floor()
	global_position = (cell - Vector2.ONE) * chunk_size
