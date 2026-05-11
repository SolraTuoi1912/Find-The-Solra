# res://Scripts/UI/code_block_ui.gd
extends Control

# Tín hiệu phát ra khi người chơi nhập mã cho một nhân vật cụ thể (Local)
signal code_entered_local(entered_code: String, item_id: String)

# Các node UI (Hãy đảm bảo tên node trong Scene Tree của bạn khớp với các tên này)
@onready var code_input: LineEdit = $Panel/VBoxContainer/CodeInput
@onready var submit_button: Button = $Panel/SubmitButton
@onready var message_label: Label = $Panel/VBoxContainer/MessageLabel
@onready var close_button: Button = $Panel/CloseButton

var _current_item_id: String = "" # Lưu ID nhân vật nếu đang ở chế độ Local
var _is_global_mode: bool = false # Phân biệt đang nhập mã Toàn cục hay Cục bộ

func _ready():
	# Kết nối các sự kiện
	submit_button.pressed.connect(_on_submit_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	code_input.text_submitted.connect(_on_submit_button_pressed) # Nhấn Enter để xác nhận
	
	# Mặc định ẩn UI khi mới vào game
	hide()

# Hàm gọi từ HUD chính (Cho Akina, Vest Solra...)
func show_global_code_ui():
	_is_global_mode = true
	_current_item_id = ""
	message_label.text = "Nhập mã bí mật toàn cục:"
	_open_ui()

# Hàm gọi khi đứng cạnh nhân vật (Cho Morse Solra...)
func show_local_code_ui(item_id: String, prompt_message: String = "Nhập mã:"):
	_is_global_mode = false
	_current_item_id = item_id
	message_label.text = prompt_message
	_open_ui()

func _open_ui():
	show()
	code_input.grab_focus() # Tự động đưa con trỏ vào ô nhập
	code_input.clear()
	get_tree().paused = true # Tạm dừng game để người chơi tập trung nhập mã

func hide_ui():
	hide()
	code_input.clear()
	get_tree().paused = false # Tiếp tục game

func _on_submit_button_pressed(_text: String = ""):
	var entered_code = code_input.text.strip_edges() # Xóa khoảng trắng thừa
	
	if entered_code.is_empty():
		message_label.text = "Vui lòng không để trống!"
		return
	
	if _is_global_mode:
		# Gửi mã tới GameState để kiểm tra toàn cục
		var success = GameState.enter_global_code(entered_code)
		if success:
			message_label.text = "Mã chính xác! Đã thu thập nhân vật."
			# Bạn có thể thêm hiệu ứng chúc mừng ở đây
			await get_tree().create_timer(1.5).timeout
			hide_ui()
		else:
			message_label.text = "Mã không đúng hoặc đã được sử dụng!"
	else:
		# Phát tín hiệu báo cho nhân vật (Local) biết mã đã nhập
		emit_signal("code_entered_local", entered_code, _current_item_id)
		hide_ui()

func _on_close_button_pressed():
	hide_ui()

func _input(event):
	# Nhấn ESC để đóng nhanh hộp thoại
	if event.is_action_pressed("ui_cancel") and visible:
		hide_ui()
		get_viewport().set_input_as_handled()
