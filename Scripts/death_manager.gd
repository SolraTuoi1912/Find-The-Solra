extends Node

const FLOOR_LIMBO_SCENE = "res://Scenes/Limbo/floor_limbo.tscn"
signal show_death_options()

func _ready():
	GameState.player_died.connect(_on_player_died)

# Khi người chơi chết
func _on_player_died():
	if GameState.get_first_death_status():
		handle_first_death()
	else:
		get_tree().paused = true
		emit_signal("show_death_options")

# Chết lần đầu trong file save
func handle_first_death():
	GameState.set_first_death_status(false)
	get_tree().change_scene_to_file(FLOOR_LIMBO_SCENE)

# Hồi sinh tại checkpoint đã lưu
func respawn_at_checkpoint():
	var data = GameState.get_respawn_data()
	get_tree().change_scene_to_file(data["scene_path"])
	get_tree().paused = false

# Hồi sinh tại Limbo
func go_to_limbo():
	get_tree().change_scene_to_file(FLOOR_LIMBO_SCENE)
	get_tree().paused = false
