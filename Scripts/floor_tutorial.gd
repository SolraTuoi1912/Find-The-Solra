extends Node2D

# Khai báo

@onready var camera = $Others/Camera2D
@onready var player = $Others/Player
@onready var horizontal_line = get_viewport_rect().size.x
@onready var vertical_line = get_viewport_rect().size.y

func _ready() -> void:
	pass

# Điều chỉnh Camera, nhân vật.
func _process(delta: float) -> void:
	# Điều chỉnh vị trí Camera, nhạc và nhân vật.
	var player_pos = player.global_position
	var room_index_x : int = player_pos.x / horizontal_line
	var room_index_y : int = player_pos.y / vertical_line
	camera.position.x = horizontal_line * room_index_x + horizontal_line / 2
	camera.position.y = vertical_line * room_index_y + vertical_line / 2
	if (player_pos.y < 0):
		camera.position.y -= vertical_line
	if (player_pos.x < 0):
		camera.position.x -= horizontal_line
