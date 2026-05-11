@tool
extends Area2D

@export var solra_cameo_resource: SolraCameoResource: # Exported resource
	set(value):
		solra_cameo_resource = value
		if Engine.is_editor_hint():
			_update_visuals_and_collision()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_prompt: Label = $InteractionPrompt # Label để hiển thị "Press E to Interact"

# Biến để theo dõi trạng thái tương tác
var _can_interact: bool = false

func _ready():
	# Cập nhật hình ảnh và va chạm ngay khi bắt đầu (cả trong editor và runtime)
	_update_visuals_and_collision()
	
	# Chỉ chạy logic game khi không ở trong editor
	if Engine.is_editor_hint():
		return

	# Logic game khi chạy thật
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)
	if not is_connected("body_exited", _on_body_exited):
		connect("body_exited", _on_body_exited)
	
	# Ẩn prompt tương tác ban đầu
	if interaction_prompt:
		interaction_prompt.hide()
	
	# Cập nhật trạng thái hiển thị nếu đã được thu thập
	if solra_cameo_resource and GameState.is_collected(solra_cameo_resource.id):
		_update_collected_visuals(true)
	else:
		_update_collected_visuals(false)

func _process(_delta):
	# Chỉ chạy logic game khi không ở trong editor
	if Engine.is_editor_hint():
		return
	
	# Ngăn tương tác nếu đã thu thập
	if solra_cameo_resource and GameState.is_collected(solra_cameo_resource.id):
		return

	if _can_interact and Input.is_action_just_pressed("interact"):
		_handle_interaction()

func _update_visuals_and_collision():
	# Đảm bảo các node con đã sẵn sàng trước khi cập nhật
	if not is_inside_tree(): return
	
	# Nếu các node @onready chưa được khởi tạo (thường xảy ra trong editor)
	if sprite == null: sprite = get_node_or_null("Sprite2D")
	if collision_shape == null: collision_shape = get_node_or_null("CollisionShape2D")
	
	if solra_cameo_resource:
		# Cập nhật Sprite
		if sprite and solra_cameo_resource.main_texture:
			sprite.texture = solra_cameo_resource.main_texture
			sprite.centered = true
			
			# Cập nhật CollisionShape
			if collision_shape:
				var texture_size = solra_cameo_resource.main_texture.get_size()
				var rect_shape = RectangleShape2D.new()
				rect_shape.size = texture_size
				collision_shape.shape = rect_shape
				collision_shape.position = Vector2.ZERO
				
			if Engine.is_editor_hint():
				print("Editor: Updated visuals for ", solra_cameo_resource.display_name)
	else:
		if sprite: sprite.texture = null
		if collision_shape: collision_shape.shape = null

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		# Ngăn tương tác nếu đã thu thập
		if solra_cameo_resource and GameState.is_collected(solra_cameo_resource.id):
			return

		# Xử lý TOUCH tự động
		if solra_cameo_resource.interaction_type == SolraCameoResource.InteractionType.TOUCH:
			_handle_interaction() # Tự động thu thập khi chạm
		else:
			_can_interact = true
			if interaction_prompt: interaction_prompt.show()

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		_can_interact = false
		if interaction_prompt: interaction_prompt.hide()

func _handle_interaction():
	# Ngăn tương tác nếu đã thu thập
	if solra_cameo_resource and GameState.is_collected(solra_cameo_resource.id):
		return

	if solra_cameo_resource:
		match solra_cameo_resource.interaction_type:
			SolraCameoResource.InteractionType.TOUCH:
				_collect_solra_cameo()
			SolraCameoResource.InteractionType.DIALOGUE:
				_start_dialogue()
			SolraCameoResource.InteractionType.INPUT_TEXT:
				_open_input_text_ui()

func _collect_solra_cameo():
	if GameState.collect_solra_cameo(solra_cameo_resource.id):
		print("Collected: ", solra_cameo_resource.display_name)
		_update_collected_visuals(true) # Cập nhật hiển thị đã thu thập
		# Không ẩn đi, chỉ ngừng xử lý tương tác thêm
		_can_interact = false
		if interaction_prompt: interaction_prompt.hide()

func _start_dialogue():
	print("Dialogue: ", solra_cameo_resource.display_name)
	# Tạm thời thu thập ngay sau khi tương tác
	_collect_solra_cameo()

func _open_input_text_ui():
	print("Input UI for: ", solra_cameo_resource.display_name)
	# Logic mở UI nhập liệu sẽ được gọi ở đây

func _update_collected_visuals(is_collected: bool):
	if sprite:
		if is_collected:
			sprite.modulate = Color(0.7, 0.7, 0.7, 0.5) # Làm mờ và xám đi
			# TODO: Có thể thêm một icon dấu tích nhỏ trên đầu Solra
		else:
			sprite.modulate = Color(1, 1, 1, 1) # Trở lại màu bình thường
			
	# Đảm bảo không thể tương tác thêm nếu đã thu thập
	if is_collected:
		set_process(false) # Ngừng _process để không kiểm tra Input nữa
		# Không tắt monitorable/monitoring hoàn toàn để tránh lỗi logic, 
		# nhưng đã có kiểm tra is_collected ở trên nên sẽ không kích hoạt lại.
		if interaction_prompt: interaction_prompt.hide()

# 1. Hàm này được gọi khi người chơi nhấn phím tương tác (E)
func _on_interact():
	if solra_cameo_resource.interaction_type == SolraCameoResource.InteractionType.INPUT_TEXT:
		if not solra_cameo_resource.is_global_code:
			# Tìm CodeBlockUI trong Scene để hiển thị
			var code_ui = get_tree().current_scene.find_child("CodeBlockUI", true, false)
			if code_ui:
				code_ui.show_local_code_ui(solra_cameo_resource.id, "Giải mã Morse và nhập tại đây:")
				
				# Kết nối tín hiệu từ UI về hàm xử lý bên dưới (chỉ kết nối 1 lần)
				if not code_ui.code_entered_local.is_connected(_on_local_code_entered):
					code_ui.code_entered_local.connect(_on_local_code_entered)

# 2. Hàm xử lý kết quả sau khi người chơi nhấn "Xác nhận" trên UI
func _on_local_code_entered(entered_code: String, item_id: String):
	# Kiểm tra xem mã này có phải dành cho nhân vật này không
	if item_id == solra_cameo_resource.id:
		# SO SÁNH KHÔNG PHÂN BIỆT HOA THƯỜNG:
		if entered_code.to_lower() == solra_cameo_resource.correct_answer.to_lower():
			GameState.collect_solra_cameo(solra_cameo_resource.id)
			print("Mã chính xác! Đã thu thập: ", solra_cameo_resource.display_name)
			# (Tùy chọn) Thêm hiệu ứng biến mất hoặc đổi màu tại đây
		else:
			print("Mã sai rồi, hãy thử lại!")
