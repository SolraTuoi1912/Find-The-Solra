# res://Scripts/UI/SolraCameoIcon.gd
extends Button

var character_resource: SolraCameoResource
signal icon_clicked(res: SolraCameoResource) # Tín hiệu khi người chơi nhấn vào

@onready var icon_display = $IconDisplay
@onready var locked_overlay = $LockedOverlay

func setup(res: SolraCameoResource):
	character_resource = res
	
	# 1. Kiểm tra xem đã thu thập chưa từ GameState
	var is_collected = GameState.is_collected(res.id)
	
	# 2. Hiển thị hình ảnh
	if is_collected:
		icon_display.texture = res.icon_texture
		locked_overlay.hide()
		tooltip_text = res.display_name # Hiện tên khi di chuột vào
	else:
		icon_display.texture = res.icon_texture
		icon_display.modulate = Color(0, 0, 0, 1) # Biến thành bóng đen
		locked_overlay.show()
		tooltip_text = "???"

# Khi người chơi nhấn nút
func _pressed():
	emit_signal("icon_clicked", character_resource)
