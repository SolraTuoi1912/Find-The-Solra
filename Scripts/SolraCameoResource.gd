# res://Scripts/Data/SolraCameoResource.gd
class_name SolraCameoResource extends Resource

enum ItemType { SOLRA, CAMEO, NONE }
enum InteractionType { TOUCH, DIALOGUE, INPUT_TEXT }

@export var id: String = "" # Mã định danh duy nhất (ví dụ: "solra_vest", "cameo_akina")
@export var item_type: ItemType = ItemType.SOLRA # Loại: Solra hay Cameo
@export var display_name: String = "" # Tên hiển thị trong game/Solrapedia
@export_multiline var description: String = "" # Mô tả chi tiết cho Solrapedia

@export var icon_texture: Texture2D # Icon hiển thị trong Solrapedia (ví dụ: ảnh nhỏ 32x32)
@export var main_texture: Texture2D # Texture chính của NPC/Item trong game (dùng cho Auto-Scaling)
@export var animated_sprite_frames: SpriteFrames # AnimatedSpriteFrames cho NPC/Item trong game (ưu tiên nếu có animation)

@export var interaction_type: InteractionType = InteractionType.TOUCH # Loại tương tác để thu thập cụ thể cho từng loại tương tác
@export_group("Interaction Data")
@export_multiline var dialogue_text: String = "" # Dùng cho DIALOGUE
@export var correct_answer: String = "" # Dùng cho INPUT_TEXT (cho cả Morse, Caesar, v.v.)
@export var is_global_code: bool = false # Nếu là INPUT_TEXT, có phải là mã toàn cục (nhập từ Code Block trên HUD) không?

@export_group("Pedia Data")
@export_range(1, 1000) var difficulty: int = 1
@export var difficulty_rank_name: String = "" # Ví dụ: "Secret Universe"
@export var location_hint: String = ""
@export_multiline var character_lore: String = "" # Có thể dùng để ghi chú thêm ngoài description chính
