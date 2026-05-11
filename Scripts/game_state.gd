# res://Scripts/Managers/game_state.gd
extends Node

@export var collection_group: SolraCameoResourceGroup = preload("res://Data/SolraCameoList.tres")

signal solra_cameo_collected(id: String)
signal global_code_entered(code: String)
signal player_died() # Tín hiệu mới khi người chơi chết
signal game_started

var _solra_cameo_resources: Dictionary = {} # Resources nhân vật
var _collected_status: Dictionary = {} # Trạng thái thu thập
var _global_codes_entered: Array[String] = [] # Code Global

var _next_spawn_point_id: String = "spawn_entrance"
var _is_first_death: bool = true # Biến mới: Theo dõi lần chết đầu tiên
var _last_respawn_point: Vector2 = Vector2.ZERO # Biến mới: Vị trí hồi sinh cuối cùng
var _last_respawn_scene: String = "" # Biến mới: Scene hồi sinh cuối cùng
var _last_respawn_marker_id: String = ""

func _ready():
	_load_all_solra_cameo_resources()
	_load_game_data() # Load Game

# Tải tất cả nhân vật
func _load_all_solra_cameo_resources():
	if collection_group:
		for resource in collection_group.all_entries:
			if resource and not _solra_cameo_resources.has(resource.id):
				_solra_cameo_resources[resource.id] = resource
				print("Loaded Resource: ", resource.display_name)
	else:
		print("Chưa có collection?")

# Load game
func _load_game_data():
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		# Nạp dữ liệu cũ vào
		_collected_status = data.get("collected_status", {})
		_global_codes_entered = data.get("global_codes", [])
		_is_first_death = data.get("is_first_death", true)
		_last_respawn_point = data.get("last_respawn_point", Vector2.ZERO)
		_last_respawn_scene = data.get("last_respawn_scene", "res://Scenes/Floor01/floor_01.tscn")
		_last_respawn_marker_id = data.get("last_respawn_marker_id", "")
		print("Tui đã nhớ lại mọi thứ rồi khứa súc sinh!")
	else:
		# Nếu chưa có file save thì mới chạy mớ mặc định này
		for id in _solra_cameo_resources:
			_collected_status[id] = false
		print("Lần đầu của chúng mình, chưa có gì được lưu cả!")

# Lưu game
func _save_game_data():
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	if file:
		var data = {
			"collected_status": _collected_status,
			"global_codes": _global_codes_entered,
			"is_first_death": _is_first_death,
			"last_respawn_point": _last_respawn_point,
			"last_respawn_scene": _last_respawn_scene,
			"last_respawn_marker_id": _last_respawn_marker_id
		}
		file.store_var(data)
		file.close()
	print("Dữ liệu đã được tui cất kỹ vào user://savegame.dat rồi nhé!")

func get_solra_cameo_resource(id: String) -> SolraCameoResource:
	return _solra_cameo_resources.get(id)

func is_collected(id: String) -> bool:
	return _collected_status.get(id, false)

func collect_solra_cameo(id: String) -> bool:
	if _solra_cameo_resources.has(id) and not _collected_status.get(id, false):
		_collected_status[id] = true
		emit_signal("solra_cameo_collected", id)
		print("Collected: ", get_solra_cameo_resource(id).display_name)
		_save_game_data() # Save game after collecting
		var res = _solra_cameo_resources[id]
		CollectionManager.show_collection_toast(res)
		return true
	return false

func get_all_solra_cameo_ids() -> Array:
	return _solra_cameo_resources.keys()

func get_collected_count(item_type_filter: SolraCameoResource.ItemType = SolraCameoResource.ItemType.NONE) -> int: # Sửa lỗi Enum
	var count = 0
	for id in _collected_status:
		if _collected_status[id]:
			var resource = get_solra_cameo_resource(id)
			if item_type_filter == SolraCameoResource.ItemType.NONE or (resource and resource.item_type == item_type_filter): # Sửa lỗi Enum
				count += 1
	return count

func get_total_count(item_type_filter: SolraCameoResource.ItemType = SolraCameoResource.ItemType.NONE) -> int: # Sửa lỗi Enum
	var count = 0
	for id in _solra_cameo_resources:
		var resource = _solra_cameo_resources[id]
		if item_type_filter == SolraCameoResource.ItemType.NONE or resource.item_type == item_type_filter: # Sửa lỗi Enum
			count += 1
	return count

# --- Solrapedia/Cameolisto Data Retrieval ---
func get_solrapedia_entries() -> Array:
	var entries = []
	for id in _solra_cameo_resources:
		var resource = _solra_cameo_resources[id]
		var is_item_collected = _collected_status.get(id, false)
		
		# Only show in Solrapedia if collected (or discovered, if you add a \'discovered\' status)
		if is_item_collected:
			entries.append({
				"id": resource.id,
				"type": resource.item_type,
				"display_name": resource.display_name,
				"description": resource.description,
				"icon": resource.icon_texture,
				"is_collected": is_item_collected
			})
	return entries

func get_solrapedia_entry_by_id(id: String) -> Dictionary:
	var resource = get_solra_cameo_resource(id)
	if resource:
		var is_item_collected = _collected_status.get(id, false)
		return {
			"id": resource.id,
			"type": resource.item_type,
			"display_name": resource.display_name,
			"description": resource.description,
			"icon": resource.icon_texture,
			"is_collected": is_item_collected
		}
	return {} # Return empty dictionary or null if not found

# --- Global Code Handling ---
func enter_global_code(code: String) -> bool:
	# Check if this code has already been entered
	if _global_codes_entered.has(code):
		print("Global code \'", code, "\' already entered.")
		return false

	# Iterate through all Solra/Cameo resources to find a match
	for id in _solra_cameo_resources:
		var resource: SolraCameoResource = _solra_cameo_resources[id]
		if resource.interaction_type == SolraCameoResource.InteractionType.INPUT_TEXT and resource.is_global_code:
			if resource.correct_answer.to_lower() == code.to_lower(): # Case-insensitive check
				_global_codes_entered.append(code)
				collect_solra_cameo(id) # Collect the associated Solra/Cameo
				emit_signal("global_code_entered", code) # Notify UI or other systems
				print("Successfully entered global code: ", code, ". Collected: ", resource.display_name)
				_save_game_data()
				return true
	print("Global code \'", code, "\' did not match any global Solra/Cameo.")
	return false

func has_entered_global_code(code: String) -> bool:
	return _global_codes_entered.has(code)

# --- Hàm mới cho Death & Respawn ---
func set_first_death_status(status: bool):
	_is_first_death = status
	_save_game_data()

func get_first_death_status() -> bool:
	return _is_first_death

func set_respawn_point(position: Vector2, scene_path: String, marker_id: String = ""):
	_last_respawn_point = position
	_last_respawn_scene = scene_path
	_last_respawn_marker_id = marker_id # Lưu ID của Marker2D
	_save_game_data()

func get_respawn_data() -> Dictionary:
	return {
		"position": _last_respawn_point, 
		"scene_path": _last_respawn_scene,
		"marker_id": _last_respawn_marker_id
	}

func player_died_event():
	emit_signal("player_died")
	print("Player has died!")
	# Logic xử lý cái chết sẽ nằm trong Player hoặc một Manager khác
	# GameState chỉ thông báo sự kiện

func get_spawn_position(spawn_point_id: String, scene_root: Node) -> Vector2:
	var spawn_node = scene_root.find_child(spawn_point_id, true, false)
	if spawn_node and spawn_node is Marker2D:
		return spawn_node.global_position
	return Vector2.ZERO
	
# Hàm để Portal đặt ID điểm đến trước khi chuyển cảnh
func set_next_spawn_point_id(id: String):
	_next_spawn_point_id = id

# Hàm để Player lấy ID điểm đến khi vừa load xong scene mới
func get_next_spawn_point_id() -> String:
	return _next_spawn_point_id
