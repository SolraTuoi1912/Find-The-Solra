# Script gắn tại CanvasLayer (Solrapedia)
extends CanvasLayer

func open_pedia():
	$Root.show()
	$Root.populate_pedia()

func close_pedia():
	$Root.hide()


func _on_close_button_pressed() -> void:
	close_pedia()
	get_tree().paused = false
