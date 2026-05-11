# res://Scripts/Hazards/hazard_area.gd
extends Area2D

func _ready():
	# Kết nối tín hiệu va chạm của Area2D với chính nó
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Kiểm tra xem thứ vừa chạm vào có phải là Player không
	if body.name == 'Player':
		print("Oẳng! Chạm phải đồ nguy hiểm rồi!")
		
		# Gọi hàm chết trong GameState mà ông đã viết sẵn
		GameState.player_died_event()
