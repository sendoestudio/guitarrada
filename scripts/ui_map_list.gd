extends VBoxContainer
class_name UIMapList

signal index_changed

var tracklist : Array[Dictionary]
var current_index : int = -1

const map_option_pattern_path : String = "res://ui_patterns/ui_map_list_option.tscn"

func _ready() -> void:
	tracklist = Manager.load_tracklist(true)
	load_list()

func load_list() -> void:
	clear_list()
	
	var index = 0
	for map in tracklist:
		var option = load(map_option_pattern_path)
		var option_instance : UIMapListOption = option.instantiate()
		add_child(option_instance)
		option_instance.set_info(self, map.artist, map.title, index)
		index += 1

func set_selection(index) -> void:
	Manager.current_map_info = tracklist[index]
	Manager.current_map_path = tracklist[index].path
	
	current_index = index
	index_changed.emit()

func clear_list() -> void:
	for i in get_child_count():
		var child = get_child(0)
		remove_child(child)
		child.queue_free()	
