# res://Scripts/UI/Solrapedia.gd
extends Control

@export var icon_template_scene: PackedScene
@onready var grid_container = $"MainLayout/LeftPanel/ScrollContainer/SolraList"
@onready var search_bar = $MainLayout/LeftPanel/Header/SearchBar

# Đảm bảo đường dẫn các node này chính xác 100% trong Scene của ông
@onready var detail_name = $MainLayout/RightPanel/CharName
@onready var detail_diff = $MainLayout/RightPanel/Difficulty
@onready var detail_loc = $MainLayout/RightPanel/Location
@onready var detail_desc = $MainLayout/RightPanel/Description
@onready var detail_icon = $MainLayout/RightPanel/BigIcon
@onready var detail_diff_label = $MainLayout/RightPanel/DifficultyLevel # Nhớ tạo thêm node này nhé

var current_sort_mode = 0

func _ready():
	_clear_grid()
	populate_pedia()
	if search_bar:
		search_bar.text_changed.connect(_on_search_bar_text_changed)
	
	# Kết nối OptionButton (SortMenu)
	var sort_menu = $MainLayout/LeftPanel/Header/OptionButton
	sort_menu.clear()
	sort_menu.add_item("Tên (A-Z)")
	sort_menu.add_item("Độ khó (Tăng dần)")
	sort_menu.add_item("Độ khó (Giảm dần)")
	sort_menu.item_selected.connect(_on_sort_menu_item_selected)

func _clear_grid():
	for child in grid_container.get_children():
		child.queue_free()
		
func _on_sort_menu_item_selected(index: int):
	current_sort_mode = index
	populate_pedia(search_bar.text) # Nạp lại danh sách với chế độ sort mới

func populate_pedia(filter_text: String = ""):
	_clear_grid()
	
	var all_resources = GameState._solra_cameo_resources.values()
	
	# --- ĐOẠN PHÁP THUẬT SORTING NẰM Ở ĐÂY ---
	if current_sort_mode == 0:
		all_resources.sort_custom(func(a, b): return a.display_name.to_lower() < b.display_name.to_lower())
	elif current_sort_mode == 1:
		all_resources.sort_custom(func(a, b): return a.difficulty < b.difficulty)
	elif current_sort_mode == 2:
		all_resources.sort_custom(func(a, b): return a.difficulty > b.difficulty)
	# ----------------------------------------
	
	for res in all_resources:
		# Kiểm tra biến res có phải là Resource không, tránh lỗi base String
		if not res is SolraCameoResource: continue
		
		if filter_text != "" and not filter_text.to_lower() in res.display_name.to_lower():
			continue
			
		var new_icon = icon_template_scene.instantiate()
		grid_container.add_child(new_icon)
		
		new_icon.setup(res)
		# Quan trọng: Đảm bảo tín hiệu truyền đúng Object
		if not new_icon.icon_clicked.is_connected(_on_character_selected):
			new_icon.icon_clicked.connect(_on_character_selected)

func _on_character_selected(res: SolraCameoResource):
	# Kiểm tra an toàn lần nữa
	if res == null: return
	
	if GameState.is_collected(res.id):
		detail_name.text = res.display_name
		detail_diff.value = res.difficulty
		detail_loc.text = "Vị trí: " + res.location_hint
		detail_desc.text = res.description
		detail_icon.texture = res.icon_texture
		detail_diff_label.text = "Độ khó: " + str(res.difficulty) + " / 1000"
	else:
		detail_name.text = res.display_name
		detail_diff.value = res.difficulty
		detail_loc.text = "Vị trí: Chưa xác định"
		detail_desc.text = res.description
		detail_icon.texture = null
		detail_diff_label.text = "Độ khó: " + str(res.difficulty) + " / 1000"

func _on_search_bar_text_changed(new_text: String):
	populate_pedia(new_text)

# Thêm hàm này nếu MainHUD của ông gọi nó để đóng/mở
func toggle_pedia():
	if visible:
		hide()
	else:
		show()
		populate_pedia()
