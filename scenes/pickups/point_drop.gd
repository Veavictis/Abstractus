class_name PointDrop
extends Area2D
## A glowing point dot. Once the player comes within its `pickup_radius`, the dot floats
## into the player, speeding up, and is collected on touch.

## Placeholder dot size in pixels, used until the kind's PNG exists.
const PLACEHOLDER_SIZE := 7
## Room around the art for its glow, in pixels.
const GLOW_PADDING := 3
## How fast a pulled-in dot speeds up, in pixels per second per second.
const PULL_ACCELERATION := 600.0

var kind: PointDropKind

var _player: Player
var _pull_speed := 0.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	var texture: Texture2D
	if ResourceLoader.exists(kind.art_path):
		texture = load(kind.art_path)
	else:
		texture = ImageTexture.create_from_image(_placeholder_image())
	_sprite.texture = PixelGlow.padded(texture, GLOW_PADDING)
	# Each kind pulses by its own amount, so give this dot its own copy of the glow.
	_sprite.material = _sprite.material.duplicate()
	_sprite.material.set_shader_parameter("pulse_amount", kind.glow_pulse)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _player == null:
		var player := get_tree().get_first_node_in_group("player") as Player
		if player and global_position.distance_to(player.global_position) <= player.pickup_radius:
			_player = player
			_pull_speed = player.pickup_speed
		return
	if not is_instance_valid(_player):
		return
	_pull_speed += PULL_ACCELERATION * delta
	global_position = global_position.move_toward(_player.global_position, _pull_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_queued_for_deletion():
		body.add_points(kind.points)
		queue_free()


func _placeholder_image() -> Image:
	var image := Image.create_empty(PLACEHOLDER_SIZE, PLACEHOLDER_SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(PLACEHOLDER_SIZE, PLACEHOLDER_SIZE) / 2.0
	for y in PLACEHOLDER_SIZE:
		for x in PLACEHOLDER_SIZE:
			if Vector2(x + 0.5, y + 0.5).distance_to(center) <= PLACEHOLDER_SIZE / 2.0:
				image.set_pixel(x, y, kind.placeholder_color)
	return image
