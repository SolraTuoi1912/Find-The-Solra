# BookUI.gd
extends CanvasLayer

# 1. Kết nối các Node con (Dùng @onready để đảm bảo chúng đã load xong)
@onready var color_rect = $ColorRect          # Lớp nền mờ
@onready var paper_rect = $NinePatchRect      # Tờ giấy trắng (Con của ColorRect nếu ông sắp xếp như vậy)
@onready var vbox_container = $NinePatchRect/VBoxContainer # Cái 'khay' đựng nội dung
@onready var text_label = $NinePatchRect/VBoxContainer/RichTextLabel # Chữ
@onready var image_rect = $NinePatchRect/VBoxContainer/TextureRect # Ảnh
@onready var btn_back = $NinePatchRect/Back   # Nút lùi
@onready var btn_next = $NinePatchRect/Next   # Nút tiến

# 2. Các biến trạng thái
var current_book_data: BookData = null # Chứa nguyên file .tres đang đọc
var current_page: int = 0             # Trang hiện tại

func _ready():
	# 3. Lúc đầu ẩn UI đi để chơi game
	hide() 
	
	# 4. Kết nối tín hiệu nút bấm (trong Editor cũng được, nhưng code cho chắc)
	btn_back.pressed.connect(_on_back_pressed)
	btn_next.pressed.connect(_on_next_pressed)

# --- PHẦN HÀM CHÍNH ---

# 5. Hàm này sẽ được gọi từ script 'book.gd'
func open_book(data: BookData):
	if data == null or data.pages.size() == 0:
		print("Lỗi Thái ơi: Cuốn sách này rỗng tuếch! XD")
		return
		
	current_book_data = data # Lưu dữ liệu cuốn sách
	current_page = 0        # Reset về trang đầu tiên
	
	# Tự động ẩn các Node nội dung để show_page() bật lại cho đúng
	text_label.hide()
	image_rect.hide()
	
	show_page() # Hiện nội dung trang 1
	show()      # Hiện UI lên màn hình
	get_tree().paused = true # ⏸️ Tạm dừng game để đọc (Nhớ set Process Mode của BookUI là Always)
	get_viewport().set_input_as_handled()

# 6. Hàm cập nhật nội dung trang
func show_page():
	# Lấy Dictionary của trang hiện tại từ Resource
	var page_data = current_book_data.pages[current_page]
	
	# --- XỬ LÝ ẢNH GEMI/SEMAPHORE ---
	# Kiểm tra xem trang có ảnh không (phải khớp chữ 'image' với Resource nha)
	if page_data.has("image") and page_data["image"] != null:
		# Nếu là đường dẫn String: "res://..."
		if typeof(page_data["image"]) == TYPE_STRING and page_data["image"] != "":
			image_rect.texture = load(page_data["image"])
			image_rect.show()
		# Nếu ông kéo thẳng ảnh vào Dictionary (TYPE_OBJECT)
		elif typeof(page_data["image"]) == TYPE_OBJECT:
			image_rect.texture = page_data["image"]
			image_rect.show()
		else:
			image_rect.hide()
	else:
		image_rect.hide() # Ẩn đi nếu không có ảnh
		
	# --- XỬ LÝ CHỮ (RichTextLabel với BBCode) ---
	if page_data.has("text") and page_data["text"] != "":
		var final_text = page_data["text"].replace("\\n", "\n")
		text_label.text = final_text # BBCode tự nhận
		text_label.show()
	else:
		text_label.hide()
		
	# --- CẬP NHẬT NÚT LẬT TRANG ---
	# Hiện nút 'Lùi' nếu không phải trang đầu
	btn_back.visible = (current_page > 0)
	# Hiện nút 'Tiến' nếu không phải trang cuối
	btn_next.visible = (current_page < current_book_data.pages.size() - 1)
	print("Trang hien tai co chu khong: ", page_data.has("text"))
	print("Noi dung chu: ", page_data["text"])
	print("Label dang hien hay an: ", text_label.visible)

# 7. Hàm đóng sách
func close_book():
	hide()
	get_tree().paused = false # ▶️ Chơi tiếp

# --- PHẦN XỬ LÝ ĐẦU VÀO (Lật trang bằng phím) ---

func _input(event):
	# Nếu sách không mở thì không xử lý gì cả
	if not visible: return
	
	# 8. Bấm phím E (interact) hoặc ESC (ui_cancel) để đóng sách
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		# Dùng 'call_deferred' để tránh lỗi xung đột Input
		call_deferred("close_book")
		get_viewport().set_input_as_handled() # Nuốt tín hiệu
		
	# 9. Bấm phím D/Mũi tên phải để lật trang TỚI
	if event.is_action_pressed("ui_right") and btn_next.visible:
		_on_next_pressed()
		
	# 10. Bấm phím A/Mũi tên trái để lật trang LÙI
	if event.is_action_pressed("ui_left") and btn_back.visible:
		_on_back_pressed()

# --- PHẦN TÍN HIỆU NÚT BẤM UI ---

func _on_back_pressed():
	if current_page > 0:
		current_page -= 1
		show_page()

func _on_next_pressed():
	if current_page < current_book_data.pages.size() - 1:
		current_page += 1
		show_page()
