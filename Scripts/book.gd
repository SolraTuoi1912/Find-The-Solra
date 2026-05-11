extends Area2D

# Kéo file .tres (BookData) vào đây trong Inspector
@export var book_resource: BookData 
@export_enum("black", "blue", "gray", "red", "yellow", "green") var book_color: String = "blue"

@onready var anim = $AnimatedSprite2D
@onready var prompt = $Label

var is_player_inside = false

func _ready():
	# Nếu có resource, tự động đổi màu sách
	if book_resource and book_resource.book_id != "":
		anim.play(book_color)
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	prompt.hide()

# Kiểm tra player có gần sách hay không
func _on_body_entered(body):
	if body.name.to_lower() == "player":
		is_player_inside = true
		prompt.show()

func _on_body_exited(body):
	if body.name.to_lower() == "player":
		is_player_inside = false
		prompt.hide()

# Tương tác với sách
func _input(event):
	if is_player_inside and event.is_action_pressed("interact"):
		if book_resource:
			# Mở sách
			BookUI.open_book(book_resource)
		else:
			print("Cuốn sách này rỗng tuếch Thái ơi! Chưa gắn Resource kìa XD")
