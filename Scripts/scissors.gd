extends Area2D

@export var max_speed: float = 200.0
@export var min_speed: float = 80.0
@export var slowdown_radius: float = 300.0
@export var rotation_speed: float = 8.0

# Agent này sẽ giúp kéo đọc bản đồ xanh mà ông vừa vẽ
@onready var nav_agent = $NavigationAgent2D 

var target_player: Node2D = null

func _process(delta):
	if target_player:
		# 1. Cập nhật vị trí người chơi cho bộ não AI
		nav_agent.target_position = target_player.global_position
		
		# 2. Lấy vị trí tiếp theo trên đường đi để né tường
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = (next_path_pos - global_position).normalized()
		
		# 3. Tính khoảng cách thực tế tới Player để làm chậm (Dung thứ)
		var distance = global_position.distance_to(target_player.global_position)
		var current_speed = max_speed
		
		if distance < slowdown_radius:
			var t = distance / slowdown_radius
			# Dùng Quadratic Ease-In cho mượt [cite: 3]
			current_speed = lerp(min_speed, max_speed, t * t) 
		
		current_speed = max(current_speed, min_speed)
		
		# 4. Di chuyển theo hướng né vật cản
		position += direction * current_speed * delta
		
		# 5. Xoay lưỡi kéo theo hướng di chuyển (offset = 0 như ông chỉnh) [cite: 2]
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, delta * rotation_speed)

func start_chasing(player):
	target_player = player
