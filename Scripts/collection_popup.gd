extends CanvasLayer

@onready var main_box = $MainBox
@onready var char_icon = $MainBox/CharIcon
@onready var title_label = $MainBox/Title
@onready var char_name_label = $MainBox/CharName
@onready var sfx = $SFX
@onready var hardsfx = $HardSFX
@onready var crazysfx = $CrazySFX


func display(res: SolraCameoResource):
	# 1. Thiết lập nội dung
	char_icon.texture = res.icon_texture
	char_name_label.text = res.display_name
	# 2. Đổi màu viền (Border) dựa trên Loại
	var style_box = main_box.get_theme_stylebox("panel").duplicate()
	if res.item_type == res.ItemType.SOLRA:
		style_box.border_color = Color.GOLD # Màu vàng cho Solra
	else:
		style_box.border_color = Color.CYAN # Màu xanh lơ cho Cameo
	main_box.add_theme_stylebox_override("panel", style_box)

	# 3. Đổi màu chữ theo độ khó
	var difficulty_color = Color.WHITE
	var diff = res.difficulty
	
	if diff <= 100: difficulty_color = Color.GREEN          # Dễ
	elif diff <= 300: difficulty_color = Color.YELLOW       # Trung bình
	elif diff <= 500: difficulty_color = Color.ORANGE       # Khó
	elif diff <= 700: difficulty_color = Color.RED          # Rất khó
	elif diff <= 900: difficulty_color = Color.DARK_MAGENTA # Điên vcl
	else: difficulty_color = Color.AQUA                     # ???

	char_name_label.add_theme_color_override("font_color", difficulty_color)
	
	# 3.5. SFX
	if diff <= 300: sfx.play()
	elif diff <= 700: hardsfx.play()
	else: crazysfx.play()

	# 4. Hiệu ứng xuất hiện và tự biến mất
	_play_animation()

# Code hoạt ảnh
func _play_animation():
	show()
	main_box.modulate.a = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(main_box, "modulate:a", 1.0, 0.3)
	
	await get_tree().create_timer(3.0).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(main_box, "modulate:a", 0.0, 0.5)
	fade_out.finished.connect(queue_free)
