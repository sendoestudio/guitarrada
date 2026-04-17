extends Control
class_name LevelEditorComplexTimeline

const interval_box_path : String = "res://defaults/level_editor_complex_bpm_interval.tscn"

@onready var create_button : Button = $CreateButton

@onready var intervals_vboxcontainer : VBoxContainer = $IntervalsScrollContainer/VBoxContainer

var _timeline_creation_handler : LevelEditorTimelineCreation

func set_timeline_creation_handler(handler : LevelEditorTimelineCreation) -> void:
	_timeline_creation_handler = handler

func reset() -> void:
	clean_boxes()
	create_internal_box()

func create_internal_box() -> void:
	var interval_box = load(interval_box_path)
	var interval_box_instance : LevelEditorComplexTimelineInterval = interval_box.instantiate()
	intervals_vboxcontainer.add_child(interval_box_instance)
	interval_box_instance.set_complex_handler(self)

func clean_boxes() -> void:
	for box_index in intervals_vboxcontainer.get_child_count():
		var old_box = intervals_vboxcontainer.get_child(0)
		intervals_vboxcontainer.remove_child(old_box)
		old_box.queue_free()
