extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	GameState.game_started.emit()
	
	var respawn_data = GameState.get_respawn_data()
	var target_scene = respawn_data["scene_path"]
	
	# Nếu chưa có checkpoint nào (lần đầu chơi), mới dùng mặc định
	if target_scene == "" or target_scene.contains("MainMenu"):
		target_scene = "res://Scenes/Floor01/floor_01.tscn"
		
	get_tree().change_scene_to_file(target_scene)
