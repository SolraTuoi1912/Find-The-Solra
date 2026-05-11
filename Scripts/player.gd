extends CharacterBody2D

# Khai báo

@onready var sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Thực thi

# res://Scripts/player.gd

func _ready():
	var current_room = get_tree().current_scene
	var current_scene_path = current_room.scene_file_path
	var spawn_id_from_portal = GameState.get_next_spawn_point_id()
	var spawn_node_from_portal = current_room.find_child(spawn_id_from_portal, true, false)
	
	var final_spawn_position = global_position # Mặc định: Vị trí đặt trong Editor
	var final_marker_id = "" 

	var respawn_data = GameState.get_respawn_data()
	var checkpoint_found = false

	# ƯU TIÊN 1: Hồi sinh tại Checkpoint nếu đúng scene hiện tại
	if respawn_data["marker_id"] != "" and respawn_data["scene_path"] == current_scene_path:
		var checkpoint_node = current_room.find_child(respawn_data["marker_id"], true, false)
		if checkpoint_node:
			final_spawn_position = checkpoint_node.global_position
			final_marker_id = respawn_data["marker_id"]
			checkpoint_found = true
		else:
			# Fallback: Nếu mất Marker, dùng tọa độ Vector2 đã lưu
			final_spawn_position = respawn_data["position"]
			final_marker_id = respawn_data["marker_id"]
			checkpoint_found = true

	# ƯU TIÊN 2: Nếu không có checkpoint, thử spawn từ Portal (điểm đến)
	if not checkpoint_found:
		if spawn_node_from_portal and spawn_node_from_portal is Marker2D:
			final_spawn_position = spawn_node_from_portal.global_position
			final_marker_id = spawn_id_from_portal
		else:
			# ƯU TIÊN 3: Nếu không có gì cả, tự tìm Marker đầu tiên trong scene làm checkpoint
			var markers_in_scene = current_room.find_children("*", "Marker2D", true, false)
			if not markers_in_scene.is_empty():
				final_marker_id = markers_in_scene[0].name

	# Thực hiện đặt vị trí cho Player
	global_position = final_spawn_position

	# QUAN TRỌNG: Cập nhật ngay lập tức GameState để checkpoint luôn đúng với scene hiện tại
	GameState.set_respawn_point(global_position, current_scene_path, final_marker_id)
	
	# Reset ID portal sau khi dùng
	GameState.set_next_spawn_point_id("")

func _physics_process(delta: float) -> void:
	# Trọng lực
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Nhảy
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Di chuyển trái phải
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		if (direction > 0):
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
		sprite.play("Running")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play("Idle")

	move_and_slide()

func _update_nearest_checkpoint():
	var markers = get_tree().current_scene.find_children("*", "Marker2D")
	for marker in markers:
		if global_position.distance_to(marker.global_position) < 100:
			GameState.set_respawn_point(marker.global_position, get_tree().current_scene.scene_file_path, marker.name)
