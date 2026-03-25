extends VBoxContainer
class_name UIMapList

var tracklist : Array
var current_index : int = -1

const map_option_pattern_path : String = "res://defaults/map_option.tscn"

func load_list() -> void:
	pass

func set_selection(index) -> void:
	pass
	
	current_index = index
