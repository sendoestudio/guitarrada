extends HBoxContainer
class_name LevelEditorBeatTrack

var _level_editor : LevelEditor

const beat_marker_path : String = "res://defaults/level_editor_track_beat_marker.tscn"

@onready var markers_parent : HBoxContainer = $HBoxContainer

func set_level_editor(editor):
	_level_editor = editor

func _ready() -> void:
	
	clean_track()
	
	#var overbeats_test : Array[float] = [
		#0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5
		#]
		#
	#var strong_beats_test : Array[float] = [
		#0, 2, 4, 6, 8, 10
	#]
	##var times_test : Array[float] = [
		##0.5, 1.25
	##]
	##
	#create_track(overbeats_test, strong_beats_test)

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
		
		#var interval_to_next = -1
		if (beat_index + 1) >= beats.size():
			#interval_to_next = beats[beat_index + 1] - beats[beat_index]
		#else:
			break
		#
		#var inner_beat_factor = (interval_to_next / interval_beats_amount)
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
		#if i <= current_time + (error * 5):
			#break
		#
		var diff = current_time - i
		var abs_diff = absf(diff)
		
		if abs_diff <= error:
			response = true
			break
		elif i >= current_time - (error * 3):
			break
		
	#print(response)
	return response
