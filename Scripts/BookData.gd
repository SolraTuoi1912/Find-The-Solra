extends Resource
class_name BookData # Tiết kiệm thời gian nạp Resource

@export var book_id: String = ""
@export_multiline var pages: Array[Dictionary] = [] 
# Dictionary có dạng text + image
