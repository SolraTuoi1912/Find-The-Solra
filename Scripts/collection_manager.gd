# res://Scripts/Singletons/CollectionManager.gd
extends Node

# Load sẵn Scene Popup để gọi cho nhanh
var popup_scene = preload("res://Scenes/collection_popup.tscn")

func show_collection_toast(res: SolraCameoResource):
	# Tạo instance của popup
	var popup = popup_scene.instantiate()
	# Thêm vào root để nó luôn hiện trên cùng các layer khác
	get_tree().root.add_child(popup)
	# Gọi hàm hiển thị đã thiết lập
	popup.display(res)
