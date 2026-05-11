extends Area2D

func _ready():
	# Kết nối tín hiệu va chạm của Area2D với chính nó
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == 'Player':
		# Đánh thức tất cả các cây kéo trong phòng
		get_tree().call_group("Scissors", "start_chasing", body)
		# Xóa cái trigger này đi để không gọi lại nhiều lần
		queue_free()
