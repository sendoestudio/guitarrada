extends HBoxContainer
class_name LevelEditorBeatTrack

var _level_editor : LevelEditor

const beat_marker_path : String = "res://defaults/level_editor_track_beat_marker.tscn"

@onready var markers_parent : HBoxContainer = $HBoxContainer

func set_level_editor(editor):
	_level_editor = editor

func _ready() -> void:
	clean_track()

func create_track(beats, strong_beats):
	var interval_beats_amount = Manager.interval_beats_amount
	var new_mark = load(beat_marker_path)
	
	for beat_index in beats.size():
		var marker_instance : LevelEditorBeatMarker = new_mark.instantiate()
		markers_parent.add_child(marker_instance)
		marker_instance.setup(beat_index, 0, is_strong_beat(beats[beat_index], strong_beats))
		marker_instance.custom_minimum_size = Vector2(25.0, 45.0)
		
		if interval_beats_amount <= 0:
			continue
		
		if (beat_index + 1) >= beats.size():
			break
		
		for i in interval_beats_amount:
			var inner_marker_instance : LevelEditorBeatMarker = new_mark.instantiate()
			markers_parent.add_child(inner_marker_instance)
			inner_marker_instance.setup(beat_index, (i + 1))
			inner_marker_instance.custom_minimum_size = Vector2(25.0, 45.0)
		
func clean_track():
	for i in markers_parent.get_child_count():
		var child = markers_parent.get_child(0)
		markers_parent.remove_child(child)
		child.queue_free()

func is_strong_beat(current_time, strong_list, error = 0.005) -> bool:
	if strong_list == null || strong_list.size() == 0:
		return false
	
	var response : bool = false
	for i in strong_list:

		var diff = current_time - i
		var abs_diff = absf(diff)
		
		if abs_diff <= error:
			response = true
			break
		elif i >= current_time - (error * 3):
			break
		
	return response
