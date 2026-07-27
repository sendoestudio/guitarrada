extends Control
class_name UIMapListOption

@onready var title_label : Label = $TitleLabel
@onready var artist_label : Label = $ArtistLabel
var list_parent : UIMapList
var item_index : int

func set_info(list, artist, title, index) -> void:
	list_parent = list
	item_index = index
	title_label.text = title
	artist_label.text = artist
	

func _on_button_pressed() -> void:
	if list_parent == null:
		return
	
	list_parent.set_selection(item_index)
	
