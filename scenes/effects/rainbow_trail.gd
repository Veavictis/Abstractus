class_name RainbowTrail
extends CPUParticles2D
## Leaves rainbow pixels behind its parent while the parent moves.

var _last_position := Vector2.ZERO


func _ready() -> void:
	_last_position = global_position


func _physics_process(_delta: float) -> void:
	emitting = not global_position.is_equal_approx(_last_position)
	_last_position = global_position


## Lets the trail fade out on its own when its parent is about to be freed.
func detach() -> void:
	var level := get_tree().current_scene
	if level == null:
		return
	reparent(level)
	set_physics_process(false)
	emitting = false
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
