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

func create_internal_box(from : LevelEditorComplexTimelineInterval = null) -> void:
	var interval_box = load(interval_box_path)
	var interval_box_instance : LevelEditorComplexTimelineInterval = interval_box.instantiate()
	intervals_vboxcontainer.add_child(interval_box_instance)
	interval_box_instance.set_complex_handler(self)
	
	if from != null:
		var original_index = find_index(from)
		intervals_vboxcontainer.move_child(interval_box_instance, original_index + 1)
	
	refresh_boxes_buttons()

func delete_internal_box(box : LevelEditorComplexTimelineInterval) -> void:
	if intervals_vboxcontainer.get_child_count() < 2:
		return
	
	intervals_vboxcontainer.remove_child(box)
	box.queue_free()
	
	refresh_boxes_buttons()

func clean_boxes() -> void:
	for box_index in intervals_vboxcontainer.get_child_count():
		var old_box = intervals_vboxcontainer.get_child(0)
		intervals_vboxcontainer.remove_child(old_box)
		old_box.queue_free()

#func update_order(current_index : int, is_up : bool) -> void:
	#var other_index = current_index + (-1 if is_up else 1)
	#var current_copy = current_index
	#
	#if other_index < 0 || other_index >= intervals_vboxcontainer.get_child_count():
		#return
	#
	#intervals_vboxcontainer.get_child(current_index).set_index(other_index)
	#intervals_vboxcontainer.get_child(other_index).set_index(current_copy)
	#
	#var list = intervals_vboxcontainer.get_children()
	#list.sort_custom(func(a, b) : return a._order_index < b._order_index)

func update_box_position(box : LevelEditorComplexTimelineInterval, is_up : bool) -> void:
	var current_index = find_index(box)
	
	
	if current_index == -1:
		return
	
	var new_index = current_index + (-1 if is_up else 1)
	intervals_vboxcontainer.move_child(box, new_index)
	refresh_boxes_buttons()

func refresh_boxes_buttons() -> void:
	var child_count : int =  intervals_vboxcontainer.get_child_count()
	for i in child_count:
		var child : LevelEditorComplexTimelineInterval = intervals_vboxcontainer.get_child(i)
		child.set_delete_button(child_count > 1)
		child.set_up_button(i > 0)
		child.set_down_button(i < (child_count - 1))

func find_index(box : LevelEditorComplexTimelineInterval) -> int:
	var response = -1
	for i in intervals_vboxcontainer.get_child_count():
		if intervals_vboxcontainer.get_child(i) == box:
			response = i
			break
	
	return response


func _on_cancel_button_pressed() -> void:
	_timeline_creation_handler.reset()


func _on_create_button_pressed() -> void:
	var intervals : Array[LevelEditorBpmInterval] = []
	var errors_desc : String = ""
	
	var errors = 0
	for box : LevelEditorComplexTimelineInterval in intervals_vboxcontainer.get_children():
		var interval = box.get_interval()
		if interval == null:
			errors_desc += "errors in index " + str(box.get_pos_index()) + ":\n"
			errors_desc += box.get_errors()
			errors += 1
			break
		
		intervals.append(interval)
	
	if errors > 0:
		_timeline_creation_handler.display_error_list(errors_desc)
		return
	
	intervals.sort_custom(func(a, b) : return a.start < b.start)
	
	var count = intervals.size()
	if count > 1:
		for index in (count - 1):
			if intervals[index + 1].start < intervals[index].end:
				errors_desc += "Start at index " + str(index + 1) + " is lower than the End at index " + str(index)
				errors += 1
				break
	
	if errors > 0:
		_timeline_creation_handler.display_error_list(errors_desc)
		return
	
	var length = intervals[intervals.size() - 1].end
	_timeline_creation_handler.set_length(length)
	_timeline_creation_handler.build_complex_timeline(intervals)
