extends Area2D

@export_file("*.tscn") var target_scene: String # Kéo file .tscn vào đây
@export var target_spawn_id: String = "spawn_entrance" # Tên Marker2D ở scene đích

var _is_player_inside: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		_is_player_inside = true
		# Hiện gợi ý "Press E" nếu bạn có UI gợi ý
		print("Press E to enter!")

func _on_body_exited(body):
	if body.name == "Player":
		_is_player_inside = false

func _input(event):
	if _is_player_inside and event.is_action_pressed("interact"): # "interact" là phím E bạn cài trong Input Map
		_teleport()

func _teleport():
	if target_scene == "": 
		printerr("Error: Not selecting portal goal")
		return
		
	# Ghi nhớ điểm spawn cho GameState
	GameState.set_next_spawn_point_id(target_spawn_id)
	
	# Chuyển cảnh
	get_tree().change_scene_to_file(target_scene)
