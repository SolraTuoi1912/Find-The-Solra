extends CanvasLayer
@onready var solrapedia_ui_scene = preload("res://Scenes/solrapedia.tscn")
@onready var main_menu_scene = preload("res://Scenes/MainMenu.tscn")
var solrapedia_ui

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solrapedia_ui = solrapedia_ui_scene.instantiate()
	add_child(solrapedia_ui)
	DeathManager.show_death_options.connect(_on_show_death_options)
	solrapedia_ui.hide()
	self.hide()
	GameState.game_started.connect(_on_game_started)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_started():
	self.show()

func _on_button_pressed() -> void:
	$CodeBlock/Control.show_global_code_ui()


func _on_death_button_pressed() -> void:
	$DeathConfirm.popup_centered()

func _on_show_death_options():
	# Tùy biến text nút trước khi hiện
	$DeathOptionsPopup.ok_button_text = "Checkpoint"
	$DeathOptionsPopup.cancel_button_text = "Limbo"
	$DeathOptionsPopup.popup_centered()

func _on_death_confirm_confirmed() -> void:
	GameState.player_died_event()
	print("Người chơi đã reset")
	
func _on_death_options_popup_confirmed() -> void:
	DeathManager.respawn_at_checkpoint()

func _on_death_options_popup_canceled() -> void:
	DeathManager.go_to_limbo()

func _on_solrapedia_button_pressed() -> void:
	# solrapedia_ui ở đây là cái CanvasLayer có gắn script solrapedia_root.gd
	if not solrapedia_ui.visible:
		solrapedia_ui.show()        # Hiện cái CanvasLayer lên
		solrapedia_ui.open_pedia()  # Gọi hàm mở trong solrapedia_root.gd
		get_tree().paused = true    # Dừng game cho khứa súc sinh tập trung xem Pedia
	else:
		solrapedia_ui.close_pedia() # Gọi hàm đóng
		solrapedia_ui.hide()        # Ẩn cái CanvasLayer đi
		get_tree().paused = false
