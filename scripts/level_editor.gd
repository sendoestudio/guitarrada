extends Control
class_name LevelEditor

const note_path : String = "res://defaults/level_editor_note.tscn"

@export var track_times_display : LevelEditorBeatTrack 
@export var main_tracks : Array[LevelEditorTrack]
@export var notes_parent : Control

@export var current_note_options_control : Control
@export var duration_lineedit : LineEdit
@export var moment_label : Label
var _previous_duration_lineedit_value : String

var current_beat_list : Array[float]
var current_strong_beat_list : Array[float]
var current_file_path : String = ""
var current_map : Map
var current_chart : Chart
var current_note : ChartTrackTime = null
var current_note_display : LevelEditorTrackNoteButton = null
var current_note_track_index : int = -1
var current_note_index : int = -1

func _ready() -> void:
	if track_times_display != null:
		track_times_display.set_level_editor(self)
	
	var track_inner_index : int = 0
	for track in main_tracks:
		if track != null:
			track.set_level_editor(self, track_inner_index)
		track_inner_index += 1
			
	
	var beat_test = _create_beats_from_bpm(120, 10, 0)
	var strong_beats_test = _create_strong_beats_from_bpm(4, 4, 120, 10, 0)
	
	current_beat_list = beat_test
	current_strong_beat_list = strong_beats_test
	track_times_display.create_track(beat_test, strong_beats_test)
	for track in main_tracks:
		if track != null:
			track.create_track(beat_test, [])
			
	current_map = Map.new()
	current_chart = _create_chart()
	
	clean_notes()
	
	current_note_options_control.visible = false

func _create_chart() -> Chart:
	var new_chart = Chart.new()
	#new_chart.tracks = []
	
	for ref_track in main_tracks:
		var new_track : ChartTrack = ChartTrack.new()
		new_track.track_index = ref_track._inner_track_index
		new_chart.tracks.append(new_track)
	
	return new_chart

func _create_beats_from_bpm(bpm : float, length : float, offset : float = 0) -> Array[float]:
	var beats : Array[float] = []
	#var strong_beats : Array[float] = []
	
	var bpm_interval =  60.0 / bpm
	
	var beat_amount = roundi((length - offset) / bpm_interval)
	
	for i in beat_amount:
		beats.append(offset + (i * bpm_interval))
	
	return beats
		
func _create_strong_beats_from_bpm(num : int, den : int, bpm : float, length : float, offset : float = 0) -> Array[float]:
	var strong_beats : Array[float] = []
	
	var bpm_interval =  60.0 / bpm
	var strong_beat_interval = bpm_interval * num * (float(num) / den)
	
	var strong_beat_amount = roundi((length - offset) / strong_beat_interval)
	
	for j in strong_beat_amount:
		strong_beats.append(offset + (j * strong_beat_interval))
	
	return strong_beats

func _create_beats_from_string(beat_list : String) -> Array[float]:
	var beats : Array[float] = []
	
	var beat_array : Array[String] = beat_list.split(";")
	for i in beat_array:
		if i.is_valid_float():
			var new_beat : float = float(i)
			beats.append(new_beat)
		else:
			print("BEATS LIST found invalid value: " + i)
	
	return beats

func _create_strong_beats_from_string(beat_list : String) -> Array[float]:
	var strong_beats : Array[float] = []
	
	var beat_array : Array[String] = beat_list.split(";")
	for i in beat_array:
		if i.is_valid_float():
			var new_beat : float = float(i)
			strong_beats.append(new_beat)
		else:
			print("STRONG BEATS LIST found invalid value: " + i)
	
	return strong_beats

func create_note_at_spot(pos : Vector2, inner_index : int, time : float, duration : float, is_loading : bool = false) -> void:
	var note = load(note_path)
	var note_instance : LevelEditorTrackNoteButton  = note.instantiate()
	notes_parent.add_child(note_instance)
	note_instance.global_position = pos
	note_instance.set_info(self, time, inner_index, duration)
	
	if duration > 0:
		pass
	
	if !is_loading:
		var new_time : ChartTrackTime = ChartTrackTime.new()
		new_time.time = time
		new_time.duration = duration
		current_chart.tracks[inner_index].times.append(new_time)
		current_chart.tracks[inner_index].times.sort_custom(func(a, b) : return a.time < b.time)
		#print(current_chart.tracks[inner_index].times)

func clean_notes() -> void:
	for index in notes_parent.get_child_count():
		var note = notes_parent.get_child(0)
		notes_parent.remove_child(note)
		note.queue_free()

func select_note(note_object : LevelEditorTrackNoteButton ) -> void:
	current_note_display = note_object
	
	var error = 0.001
	var note_time = current_note_display._time
	var note_track = current_note_display._track_index
	var note_duration = current_note_display._duration
	current_note_track_index = note_track
	
	var found_node = current_chart.tracks[note_track].times.filter(func(a) : return a.time >= note_time - error && a.time <= note_time + error)
	if found_node.size() == 1:
		current_note_index = current_chart.tracks[note_track].times.find(found_node[0])

	current_note_options_control.visible = true
	if note_duration > 0:
		duration_lineedit.text = str(convert_duration_to_beat(note_time, note_duration))
	else:
		duration_lineedit.text = "-1"
	 #change to calculate beat
	moment_label.text = "Time: " + str( snappedf(note_time, 0.001))


func _on_delete_button_pressed() -> void:
	if current_note_display == null || current_note_index == -1 || current_note_track_index == -1:
		return
	
	current_chart.tracks[current_note_track_index].times.remove_at(current_note_index)
	notes_parent.remove_child(current_note_display)
	current_note_display.queue_free()

	_on_cancel_button_pressed()

func _on_duration_button_pressed() -> void:
	if current_note_display == null || current_note_index == -1 || current_note_track_index == -1:
		return
		
	var beat_percentage = float(_previous_duration_lineedit_value)
	
	#validate before applying
	var time = current_chart.tracks[current_note_track_index].times[current_note_index].time
	current_note_display.set_duration_display(beat_percentage)
	var duration = convert_beat_to_duration(time, beat_percentage)
	
	current_note_display.set_duration(duration)
	current_chart.tracks[current_note_track_index].times[current_note_index].duration = duration
	#call method to clean interval
	
	

func _on_cancel_button_pressed() -> void:
	current_note_display = null
	current_note_index = -1
	current_note_track_index = -1
	current_note_options_control.visible = false


func _on_duration_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		_previous_duration_lineedit_value = "0"
	elif new_text.is_valid_float():
		_previous_duration_lineedit_value = new_text
	
	duration_lineedit.text = _previous_duration_lineedit_value

func convert_beat_to_duration(start_point : float, beats : float) -> float:
	var response : float = 0.0
	
	var error = 0.001
	var found_times = current_beat_list.filter(func(a) : return a >= start_point - error && a <= start_point + error)
	if found_times.size() == 1:
		var index  = current_beat_list.find(found_times[0])
		var end_index = index + floori(beats)
		if end_index >= current_beat_list.size():
			response = current_beat_list[current_beat_list.size() - 1] - current_beat_list[index]
		else:
			response = current_beat_list[end_index] - current_beat_list[index]
			if beats - floori(beats) > error:
				var remaining_subbeat = beats - floori(beats)
				var beat_interval = current_beat_list[end_index + 1] - current_beat_list[end_index]
				response += remaining_subbeat * beat_interval
	else:
		var before_times = current_beat_list.filter(func(a) : return a <= start_point)
		var previous_index = before_times.size() - 1
		var before_start_point = current_beat_list[previous_index]
		var after_start_point =  current_beat_list[previous_index + 1]
		var beat_offset = (after_start_point - start_point) / (after_start_point - before_start_point)
		response = (after_start_point - before_start_point) * (beat_offset)
		if beats + (1 - beat_offset) >= 1:
			#response += beat_offset
			beats -= beat_offset
			var new_start_index = previous_index + 1
			var end_index = new_start_index + floori(beats)
			if end_index >= current_beat_list.size():
				response += current_beat_list[current_beat_list.size() - 1] - current_beat_list[new_start_index]
			else:
				response += current_beat_list[end_index] - current_beat_list[new_start_index]
				if beats - floori(beats) > error:
					var remaining_subbeat = beats - floori(beats)
					var beat_interval = current_beat_list[end_index + 1] - current_beat_list[end_index]
					response += remaining_subbeat * beat_interval
	
	return response

func convert_duration_to_beat(start_point : float, duration : float) -> float:
	var response : float = 0.0
	
	var end_point = start_point + duration
	var start_beat_index
	var end_beat_index
	
	var error = 0.001
	var found_start_times = current_beat_list.filter(func(a) : return a >= start_point - error && a <= start_point + error)
	if found_start_times.size() == 1:
		start_beat_index = current_beat_list.find(found_start_times[0])
	else:
		var before_times = current_beat_list.filter(func(a) : return a <= start_point)
		#var last_index = current_beat_list.find(found_start_times[0])
		var previous_index = before_times.size() - 1
		var before_start_point = current_beat_list[previous_index]
		var after_start_point =  current_beat_list[previous_index + 1]
		start_beat_index = previous_index +  ((start_point - before_start_point) / (after_start_point - before_start_point))
		

	var found_end_times = current_beat_list.filter(func(a) : return a >= end_point - error && a <= end_point + error)
	if found_end_times.size() == 1:
		end_beat_index  = current_beat_list.find(found_end_times[0])
	else:
		var before_times = current_beat_list.filter(func(a) : return a <= end_point)
		var previous_index = before_times.size() - 1
		var before_end_point = current_beat_list[previous_index]
		var after_end_point =  current_beat_list[previous_index + 1]
		end_beat_index = previous_index +  ((end_point - before_end_point) / (after_end_point - before_end_point))
		
	
	response = end_beat_index - start_beat_index
	return response

func calculate_note_duration() -> void:
	pass
