extends Control
class_name LevelEditor

const note_path : String = "res://defaults/level_editor_note.tscn"

@export var timeline_scrollcontainer : ScrollContainer
@export var chart_notes_options_control : Control

@export var track_times_display : LevelEditorBeatTrack 
@export var main_tracks : Array[LevelEditorTrack]
@export var notes_parent : Control

@export var current_note_options_control : Control
@export var duration_lineedit : LineEdit
@export var moment_label : Label
var _previous_duration_lineedit_value : String

@export var map_properties_control : Control
@export var audio_play_control : Control
#@export var timeline_creation_control : Control

@export var file_path_label : Label

var current_beat_list : Array[float]
var current_strong_beat_list : Array[float]
var current_file_path : String = ""
var current_map : Map
var current_chart : Chart
var current_note : ChartTrackTime = null
var current_note_display : LevelEditorTrackNoteButton = null
var current_note_track_index : int = -1
var current_note_index : int = -1
var current_difficulty_index : String = ""
var current_file_name : String = ""


@export var map_title_lineedit : LineEdit
@export var map_artist_lineedit : LineEdit
@export var map_audio_path_lineedit : LineEdit
@export var map_audio_preview_start_lineedit : LineEdit


@export var audio_execution_hslider : HSlider
@export var audio_play_button : Button
@export var audio_pause_button : Button
@export var audio_stop_button : Button
@export var audio_stream_player : AudioStreamPlayer
@export var instant_lineedit : LineEdit
var _audio_previous_position : float
var is_dragging_instant : bool = false

@export var difficulty_selection_optionbutton : OptionButton

@export var copy_notes_interval_control : Control
@export var copy_notes_origin_start_lineedit : LineEdit
@export var copy_notes_origin_end_lineedit : LineEdit
@export var copy_notes_target_start_lineedit : LineEdit


@export var delete_notes_interval_control : Control
@export var delete_notes_origin_start_lineedit : LineEdit
@export var delete_notes_origin_end_lineedit : LineEdit

@export var create_timeline_control : LevelEditorTimelineCreation


@export var default_file_dialog : FileDialog
var is_loading_file : bool = false
var is_saving_file : bool = false
var is_loading_audio : bool = false

var has_unsaved_changes : bool = false


var is_waiting_for_load_buttons : bool = false

func _ready() -> void:
	if track_times_display != null:
		track_times_display.set_level_editor(self)
	
	var track_inner_index : int = 0
	for track in main_tracks:
		if track != null:
			track.set_level_editor(self, track_inner_index)
		track_inner_index += 1
		
	file_path_label.text = ""
	is_dragging_instant = false
	#var beat_test = _create_beats_from_bpm(120, 10, 0)
	#var strong_beats_test = _create_strong_beats_from_bpm(4, 4, 120, 10, 0)
	#
	#current_beat_list = beat_test
	#current_strong_beat_list = strong_beats_test
	#track_times_display.create_track(beat_test, strong_beats_test)
	#for track in main_tracks:
		#if track != null:
			#track.create_track(beat_test, [])
			
	#current_map = Map.new()
	#current_chart = _create_chart()
	
	clean_notes()
	
	current_note_options_control.visible = false
	timeline_scrollcontainer.visible = false
	chart_notes_options_control.visible = false
	create_timeline_control.visible = false
	map_properties_control.visible = false
	audio_play_control.visible = false
	
	is_saving_file = false
	is_loading_audio = false
	is_loading_file = false
	
	create_timeline_control.set_level_editor(self)
	
func _process(delta: float) -> void:
	if audio_stream_player.playing:
		var audio_pos = audio_stream_player.get_playback_position()
		audio_execution_hslider.value = audio_pos
		instant_lineedit.text = str(snappedf(audio_pos, 0.001))
	elif is_dragging_instant:
		var proposed_pos = audio_execution_hslider.value
		instant_lineedit.text = str(snappedf(proposed_pos, 0.001))
	
	if is_waiting_for_load_buttons:
		clean_notes()
		var tracks = current_chart.tracks
		for track in tracks:
			var index : int = track.track_index
			if index >= 0 && index < main_tracks.size():
				#main_tracks[index].create_track(beats, track.times)
				#is_waiting_for_load_buttons = true
				main_tracks[index].create_moments(track.times)
		is_waiting_for_load_buttons = false
		

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
		current_map.charts[current_difficulty_index] = current_chart

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
	
	current_map.charts[current_difficulty_index] = current_chart

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
	
	current_map.charts[current_difficulty_index] = current_chart
	

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


func fill_properties_fields() -> void:
	map_title_lineedit.text = current_map.title
	map_artist_lineedit.text = current_map.artist
	map_audio_path_lineedit.text = current_map.audio
	map_audio_preview_start_lineedit.text = str(current_map.audio_preview_start)

func load_file(path : String) -> void:
	var map : Map
	
	if path == "" || path == null:
		map = Map.new()
	else:
		var json_file = Manager.load_json_file(path)
		map = create_map_from_object(json_file)
		
	current_map = map
	fill_properties_fields()
	
	var audio_result = handle_audio_file(map.audio)
	if !audio_result:
		map_audio_path_lineedit.text = "[error: file not found]" 
	
	map_properties_control.visible = true
	audio_play_control.visible = true
	var has_no_beats = map.beats.size() == 0 && map.strong_beats.size() == 0
	timeline_scrollcontainer.visible = false
	create_timeline_control.visible = has_no_beats
	if has_no_beats:
		create_timeline_control.reset()
	chart_notes_options_control.visible = !has_no_beats
	current_file_path = path
	file_path_label.text = current_file_path
	current_difficulty_index = ""
	current_chart = null
	
func load_timeline(difficulty_index) -> void:
	if  current_map.beats.size() == 0 && current_map.strong_beats.size() == 0:
		return
		
	#remind to copy the changes to the previous map
	current_chart = current_map.charts[difficulty_index]
	
	if current_chart == null:
		var new_chart : Chart = Chart.new()
		var new_chart_tracks : Array[ChartTrack] = []
		for track in main_tracks.size():
			var new_track : ChartTrack = ChartTrack.new()
			new_track.track_index = track
			new_chart_tracks.append(new_track)
		new_chart.tracks = new_chart_tracks
		current_chart = new_chart
		current_map.charts[difficulty_index] = new_chart
	
	
	build_timeline(current_map.beats, current_map.strong_beats, current_chart.tracks)
	timeline_scrollcontainer.visible = true

func create_map_from_object(json_file : Dictionary) -> Map:
	var response : Map = Map.new()
	
	#validation methods to be implemented
	
	response.title = json_file.title
	response.artist = json_file.artist
	response.length = json_file.length
	response.audio_preview_start = json_file.audio_preview_start
	response.audio = json_file.audio
	
	if json_file.charts.easy != null && json_file.charts.easy != {}:
		response.charts.easy = load_chart_from_file(json_file.charts.easy)
	if json_file.charts.medium != null && json_file.charts.medium != {}:
		response.charts.medium = load_chart_from_file(json_file.charts.medium)
	if json_file.charts.hard != null && json_file.charts.hard != {}:
		response.charts.hard = load_chart_from_file(json_file.charts.hard)
	if json_file.charts.expert != null && json_file.charts.expert != {}:
		response.charts.expert = load_chart_from_file(json_file.charts.expert)
	
	response.beats = load_times_from_file(json_file.beats)
	response.strong_beats = load_times_from_file(json_file.strong_beats)
	
	return response

func load_chart_from_file(json_info) -> Chart:
	var response : Chart = Chart.new()
	
	var tracks : Array[ChartTrack] = []
	for file_track in json_info.tracks:
		var chart_track = ChartTrack.new()
		chart_track.track_index = file_track.track_index
		file_track.times.sort_custom(func(a, b) : return a.time < b.time)
		for file_time in file_track.times:
			var new_time : ChartTrackTime = ChartTrackTime.new()
			new_time.time = file_time.time
			new_time.duration = file_time.duration
			chart_track.times.append(new_time)
		tracks.append(chart_track)
	response.tracks = tracks
		
	return response 

func load_times_from_file(json_info_prop) -> Array[float]:
	var response : Array[float] = []
	
	json_info_prop.sort_custom(func(a, b) : return a < b)
	for time in json_info_prop:
		response.append(time)
	
	return response

func clean_timeline():
	track_times_display.clean_track()
	for track in main_tracks:
		track.clean_track()

func build_timeline(beats : Array[float], strong_beats : Array[float], tracks : Array[ChartTrack]) -> void:
	clean_timeline()
	clean_notes()
	
	track_times_display.create_track(beats, strong_beats)
		
	for track in tracks:
		var index : int = track.track_index
		if index >= 0 && index < main_tracks.size():
			main_tracks[index].create_track(beats)
	is_waiting_for_load_buttons = true
	
	

func handle_audio_file(path) -> bool:
	var has_loaded_audio : bool = false
	if path != "" && FileAccess.file_exists(path):
		var audio_file : AudioStream = load(path)
		audio_stream_player.stream = audio_file
		audio_execution_hslider.min_value = 0
		audio_execution_hslider.max_value = audio_file.get_length()
		has_loaded_audio = true
	
	
	audio_pause_button.disabled = !has_loaded_audio
	audio_play_button.disabled = !has_loaded_audio
	audio_stop_button.disabled = !has_loaded_audio
	audio_execution_hslider.value = 0 
	audio_execution_hslider.editable = has_loaded_audio
	
	return has_loaded_audio

func save_map(path) -> void:
	if path == "":
		return
		
	current_map.charts[current_difficulty_index] = current_chart
	
	
	
	var json_file = JSON.stringify(JSON.from_native(current_map, true))
	print(str(json_file))
	
	var file_handler = FileAccess.open(path, FileAccess.WRITE)
	
	#file_handler.store_string(json_file)
	file_handler.store_string(file_handler)
	file_handler.close()


func _on_open_file_button_pressed() -> void:
	if has_unsaved_changes:
		#handle
		pass
	
	is_saving_file = false
	is_loading_audio = false
	is_loading_file = true
	default_file_dialog.visible = true
	default_file_dialog.filters = ["*.json"]
	default_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE


func _on_file_dialog_file_selected(path: String) -> void:
	if is_loading_file:
		pass
		#create validation method
		load_file(path)
		
	if is_loading_audio:
		#create validation method, just in case
		var audio_result = handle_audio_file(path)
		
		if audio_result:
			map_audio_path_lineedit.text = path
			current_map.audio = path
	
	if is_saving_file:
		_save_map_to_file(path)
		

func _on_difficulty_option_button_item_selected(index: int) -> void:
	if current_map.beats.size() == 0:
		return
	
	var difficulty : String = ""
	if index == 0:
		difficulty = "easy"
	elif index == 1:
		difficulty = "medium"
	elif index == 2:
		difficulty = "hard"
	elif index == 3:
		difficulty = "expert"
		
	if difficulty != "":
		current_chart = current_map.charts[difficulty]
		current_difficulty_index = difficulty
		load_timeline(current_difficulty_index)
	


func _on_new_file_button_pressed() -> void:
	load_file("")


func _on_find_audio_file_button_pressed() -> void:
	is_saving_file = false
	is_loading_audio = true
	is_loading_file = false
	default_file_dialog.visible = true
	default_file_dialog.filters = ["*.mp3, *.wav, *.ogg"]
	default_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE


func _on_save_as_new_button_pressed() -> void:
	is_saving_file = true
	is_loading_audio = false
	is_loading_file = false
	default_file_dialog.visible = true
	default_file_dialog.filters = ["*.json"]
	default_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE


func _on_save_button_pressed() -> void:
	if current_file_path == "":
		_on_save_as_new_button_pressed()


func _save_map_to_file(path : String) -> void:
	if path == "" || current_map == null:
		return
	
	var file_format : Dictionary = {}
	file_format.title = current_map.title
	file_format.artist = current_map.artist
	file_format.audio_preview_start = current_map.audio_preview_start
	
	#file_format.charts = current_map.charts
	file_format.charts = {}
	file_format.beats = current_map.beats
	file_format.strong_beats = current_map.strong_beats
	file_format.length = current_map.length
	
	if current_map.charts.easy != null:
		var dictionary = build_tracks_for_file(current_map.charts.easy)
		file_format.charts.easy = dictionary
	else:
		file_format.charts.easy = null
	if current_map.charts.medium != null:
		file_format.charts.medium = build_tracks_for_file(current_map.charts.medium)
	else:
		file_format.charts.medium = null
	if current_map.charts.hard != null:
		file_format.charts.hard = build_tracks_for_file(current_map.charts.hard)
	else:
		file_format.charts.hard = null
	if current_map.charts.expert != null:
		file_format.charts.expert = build_tracks_for_file(current_map.charts.expert)
	else:
		file_format.charts.expert = null
	#if audio_stream_player.stream != null:
		#file_format.length = audio_stream_player.stream.get_length()
	
	
	var map_file : String = JSON.stringify(file_format, "\t")
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(map_file)
	file.close()
	
	current_file_path = path
	file_path_label.text = current_file_path


func _on_title_line_edit_text_changed(new_text: String) -> void:
	current_map.title = new_text


func _on_artist_line_edit_text_changed(new_text: String) -> void:
	current_map.artist = new_text


func _on_preview_start_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		current_map.audio_preview_start = float(new_text)
	else:
		map_audio_preview_start_lineedit.text = str(current_map.audio_preview_start)

func create_timeline_from_bpm_intervals(bpm_intervals : Array[LevelEditorBpmInterval]):
	if bpm_intervals.size() > 1:
		bpm_intervals.sort_custom(func(a, b) : a.start < b.start)
	
	var beat_list : Array[float] = []
	var strong_beat_list : Array[float] = []
	for interval : LevelEditorBpmInterval in bpm_intervals:
		var current_beats  : Array[float]
		current_beats = _create_beats_from_bpm(interval.bpm, interval.end, interval.start)
		beat_list.append_array(current_beats)
		
		var current_strong_beats  : Array[float]
		current_strong_beats = _create_strong_beats_from_bpm(interval.numerator, interval.denominator, interval.bpm, interval.end, interval.start)
		strong_beat_list.append_array(current_strong_beats)
	
	current_map.beats = beat_list
	current_map.strong_beats = strong_beat_list
	
	
	chart_notes_options_control.visible = true
	create_timeline_control.visible = false
	#build_timeline(current_map.beats, current_map.strong_beats, current_chart.tracks) 
	
func create_timeline_from_lists(length : float, beat_list : Array[float], strong_beat_list : Array[float]):
	current_map.length = length
	current_map.beats = beat_list
	current_map.strong_beats = strong_beat_list
	
	chart_notes_options_control.visible = true
	create_timeline_control.visible = false
	
func build_tracks_for_file(tracks_info : Chart) -> Dictionary:
	var response : Dictionary = {}
	response.tracks = []
	
	for track in tracks_info.tracks:
		var track_info = {}
		track_info.track_index = track.track_index
		track_info.times = []
		
		#var times_info : Dictionary = []
		for time in track.times:
			var time_info = {}
			time_info.time = time.time
			time_info.duration = time.duration
			track_info.times.append(time_info)
			
		#track_info.times = times_info
		response.tracks.append(track_info)
	return response


func _on_playback_play_button_pressed() -> void:
	if audio_stream_player.stream != null:
		if audio_stream_player.stream_paused:
			audio_stream_player.stream_paused = false
		else:
			audio_stream_player.play(_audio_previous_position)


func _on_playback_pause_button_pressed() -> void:
	if audio_stream_player.stream != null:
		audio_stream_player.stream_paused = true

func _on_playback_stop_button_pressed() -> void:
	if audio_stream_player.stream != null:
		audio_stream_player.stop()
		_audio_previous_position = 0
		audio_execution_hslider.value = _audio_previous_position


func _on_playback_execution_h_slider_drag_started() -> void:
	if audio_stream_player.stream != null:
		audio_stream_player.stream_paused = true
		_audio_previous_position = audio_stream_player.get_playback_position()
		is_dragging_instant = true

func _on_playback_execution_h_slider_drag_ended(value_changed: bool) -> void:
	if audio_stream_player.stream != null:
		audio_stream_player.stream_paused = false
		if value_changed:
			var current_position = audio_execution_hslider.value
			audio_stream_player.play(current_position)
		is_dragging_instant = false
