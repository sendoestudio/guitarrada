extends Control
class_name LevelEditor

const note_path : String = "res://defaults/level_editor_note.tscn"

enum confirmation_options {
	none,
	delete_all_notes,
	delete_timeline,
	discard_changes_to_new_file,
	discard_changes_to_open_file,
	discard_changes_to_quit
}

@export var timeline_scrollcontainer : ScrollContainer
@export var chart_notes_options_control : Control
@export var timeline_pointer_colorrect : ColorRect
const timeline_pointer_start_point : float = 135
const timeline_pointer_note_width : float = 29

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
var current_note_on_chart
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

@export var copy_difficulty_control : Control
@export var copy_difficulty_selection_optionbutton : OptionButton

@export var create_timeline_control : LevelEditorTimelineCreation


@export var default_file_dialog : FileDialog
@export var confirmation_dialog : ConfirmationDialog
@export var validation_error_window : Window
@export var validation_error_textedit : TextEdit
var _validation_errors : String

var is_loading_file : bool = false
var is_saving_file : bool = false
var is_loading_audio : bool = false

var danger_is_deleting_timeline : bool = false
var danger_is_deleting_notes : bool = false
var danger_is_discarding_for_new_file : bool = false
var danger_is_discarding_for_open_file : bool = false
var danger_is_discarding_to_quit : bool = false

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
	
	delete_notes_interval_control.visible = false
	copy_notes_interval_control.visible = false
	copy_difficulty_control.visible = false
	
	default_file_dialog.visible = false
	confirmation_dialog.visible = false
	validation_error_window.visible = false
	
	
	is_saving_file = false
	is_loading_audio = false
	is_loading_file = false
	
	create_timeline_control.set_level_editor(self)
	
func _process(delta: float) -> void:
	var change_pointer_pos : float = -1
	if audio_stream_player.playing:
		var audio_pos = audio_stream_player.get_playback_position()
		audio_execution_hslider.value = audio_pos
		change_pointer_pos = audio_pos
		instant_lineedit.text = str(snappedf(audio_pos, 0.001))
	elif is_dragging_instant:
		var proposed_pos = audio_execution_hslider.value
		change_pointer_pos = proposed_pos
		instant_lineedit.text = str(snappedf(proposed_pos, 0.001))
	
	if change_pointer_pos >= 0:
		var proportion_pos = convert_time_to_beat(change_pointer_pos) * (Manager.interval_beats_amount + 1)
		timeline_pointer_colorrect.position.x = proportion_pos * timeline_pointer_note_width + timeline_pointer_start_point
	
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
	var strong_beat_interval = bpm_interval * float(num)
	
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
		var beat_percentage = convert_duration_to_beat(time, duration)
		note_instance.set_duration_display(beat_percentage)
	
	if !is_loading:
		var new_time : ChartTrackTime = ChartTrackTime.new()
		new_time.time = time
		new_time.duration = duration
		current_chart.tracks[inner_index].times.append(new_time)
		current_chart.tracks[inner_index].times.sort_custom(func(a, b) : return a.time < b.time)
		#print(current_chart.tracks[inner_index].times)
		current_map.charts[current_difficulty_index] = current_chart
		
		update_file_path_display(false)

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
	var note_beat = convert_time_to_beat(note_time)
	current_note_track_index = note_track
	
	var found_node = current_chart.tracks[note_track].times.filter(func(a) : return a.time >= note_time - error && a.time <= note_time + error)
	if found_node.size() == 1:
		current_note_on_chart = found_node[0]

	current_note_options_control.visible = true
	if note_duration > 0:
		duration_lineedit.text = str(convert_duration_to_beat(note_time, note_duration))
	else:
		duration_lineedit.text = "-1"
	 #change to calculate beat
	moment_label.text = "Track: " + str(note_track + 1) + " Beat: "+ str(note_beat) +" Time: " + str( snappedf(note_time, 0.001))


func _on_delete_button_pressed() -> void:
	if current_note_display == null || current_note_on_chart == null || current_note_track_index == -1:
		return
	
	current_chart.tracks[current_note_track_index].times.erase(current_note_on_chart)
	notes_parent.remove_child(current_note_display)
	current_note_display.queue_free()

	_on_cancel_button_pressed()
	
	current_map.charts[current_difficulty_index] = current_chart
	update_file_path_display(false)
	
func _on_duration_button_pressed() -> void:
	if current_note_display == null || current_note_on_chart == null || current_note_track_index == -1:
		return
		
	var beat_percentage = float(duration_lineedit.text)
	
	#validate before applying
	var time = current_note_on_chart.time
	current_note_display.set_duration_display(beat_percentage)
	var duration = convert_beat_to_duration(time, beat_percentage)
	
	current_note_display.set_duration(duration)
	var find_note_index = current_chart.tracks[current_note_track_index].times.find(current_note_on_chart)
	current_chart.tracks[current_note_track_index].times[find_note_index].duration = duration

	var beat_error = (duration / beat_percentage) / float(Manager.interval_beats_amount + 1.0)
	delete_timeline_notes_on_interval(time + beat_error, time + duration - (beat_error / 2), current_note_track_index)
	
	current_map.charts[current_difficulty_index] = current_chart
	
	update_file_path_display(false)

func _on_cancel_button_pressed() -> void:
	current_note_display = null
	current_note_index = -1
	current_note_track_index = -1
	current_note_on_chart = null
	current_note_options_control.visible = false


func _on_duration_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		duration_lineedit.text = "0"
	elif !new_text.is_valid_float():
		duration_lineedit.text = _previous_duration_lineedit_value
	
	_previous_duration_lineedit_value = duration_lineedit.text

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

func convert_beat_to_time(beat : float) -> float:
	var response : float
	var error : float = 0.001
	
	var absolute_beat = floori(beat)
	response = current_beat_list[absolute_beat]
	
	if absolute_beat + 1 >= current_beat_list.size():
		return response
	
	if (beat - absolute_beat) > error:
		var difference = beat - absolute_beat
		response += (current_beat_list[absolute_beat + 1] -  current_beat_list[absolute_beat]) * difference
	
	return response

func convert_time_to_beat(time : float) -> float:
	var response : float
	var error : float = 0.0025
	
	var before_beats = current_beat_list.filter(func(a) : return a <= time + 0.001)
	response = before_beats.size() - 1
	
	if current_beat_list.size() == before_beats.size():
		return response
	
	if (time - current_beat_list[roundi(response)]) > error:
		var diff = time - current_beat_list[roundi(response)]
		var interval = current_beat_list[roundi(response) + 1] - current_beat_list[roundi(response)]
		response += diff / interval
	
	return response

#func calculate_note_duration() -> void:
	#pass


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
	
	current_beat_list = beats
	current_strong_beat_list = strong_beats

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

#func save_map(path) -> void:
	#if path == "":
		#return
		#
	#current_map.charts[current_difficulty_index] = current_chart
	#
	#
	#
	#var json_file = JSON.stringify(JSON.from_native(current_map, true))
	#print(str(json_file))
	#
	#var file_handler = FileAccess.open(path, FileAccess.WRITE)
	#
	##file_handler.store_string(json_file)
	#file_handler.store_string(file_handler)
	#file_handler.close()


func _on_open_file_button_pressed(force : bool = false) -> void:
	if has_unsaved_changes && !force:
		set_confirmation_type(confirmation_options.discard_changes_to_open_file)
		confirmation_dialog.visible = true
		confirmation_dialog.title = "Unsaved Changes"
		confirmation_dialog.dialog_text = "Are you sure you want to discard all unsaved changes to the current map?"
		return
	
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
	
		update_file_path_display(false)
		
	if is_saving_file:
		_save_map_to_file(path)
		

func _on_difficulty_option_button_item_selected(index: int) -> void:
	if current_map.beats.size() == 0:
		return
	
	var difficulty : String = Manager.difficulties[index]
	#""
	#if index == 0:
		#difficulty = "easy"
	#elif index == 1:
		#difficulty = "medium"
	#elif index == 2:
		#difficulty = "hard"
	#elif index == 3:
		#difficulty = "expert"
		
	if difficulty != "":
		current_chart = current_map.charts[difficulty]
		current_difficulty_index = difficulty
		load_timeline(current_difficulty_index)
	


func _on_new_file_button_pressed(force : bool = false) -> void:
	if has_unsaved_changes && !force:
		set_confirmation_type(confirmation_options.discard_changes_to_new_file)
		confirmation_dialog.visible = true
		confirmation_dialog.title = "Unsaved Changes"
		confirmation_dialog.dialog_text = "Are you sure you want to discard all unsaved changes to the current map?"
		return
	
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
	else:
		_save_map_to_file(current_file_path)

func _save_map_to_file(path : String) -> void:
	if path == "" || current_map == null:
		return
	
	var file_format : Dictionary = {}
	file_format.title = current_map.title
	file_format.artist = current_map.artist
	file_format.audio_preview_start = current_map.audio_preview_start
	file_format.audio = current_map.audio
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
	
	update_file_path_display(true)

func _on_title_line_edit_text_changed(new_text: String) -> void:
	current_map.title = new_text
	update_file_path_display(false)

func _on_artist_line_edit_text_changed(new_text: String) -> void:
	current_map.artist = new_text
	update_file_path_display(false)

func _on_preview_start_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		current_map.audio_preview_start = float(new_text)
	else:
		map_audio_preview_start_lineedit.text = str(current_map.audio_preview_start)
	
	update_file_path_display(false)

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
	
	copy_difficulty_selection_optionbutton.selected = -1
	
	update_file_path_display(false)
	#build_timeline(current_map.beats, current_map.strong_beats, current_chart.tracks) 
	
func create_timeline_from_lists(length : float, beat_list : Array[float], strong_beat_list : Array[float]):
	current_map.length = length
	current_map.beats = beat_list
	current_map.strong_beats = strong_beat_list
	
	copy_difficulty_selection_optionbutton.selected = -1
	
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
		instant_lineedit.text = "0"
		audio_execution_hslider.value = _audio_previous_position
		timeline_pointer_colorrect.position.x = timeline_pointer_start_point


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


func delete_timeline_notes_on_interval(start_time : float, end_time : float, track : int = -1) -> void:
	if end_time <= start_time:
		return
		
	var error = 0.001
	for track_index in current_chart.tracks.size():
		if track != -1 && track != track_index:
			continue
		var deleting_times = current_chart.tracks[track_index].times.filter(func(a) : return a.time >= start_time - error && a.time < end_time - error)
		for deleting_time in deleting_times:
			current_chart.tracks[track_index].times.erase(deleting_time)
		
	current_map.charts[current_difficulty_index] = current_chart
		
	var display_notes = notes_parent.get_children()
	var deleting_display_notes = display_notes.filter(func(a) : return  a._time >= start_time - error && a._time <= end_time + error && (track == -1 || track == a._track_index))
	for deleting_note in deleting_display_notes:
		notes_parent.remove_child(deleting_note)
		
	update_file_path_display(false)

func delete_timeline_notes():
	for track_index in current_chart.tracks.size():
		current_chart.tracks[track_index].times.clear()
		
	current_map.charts[current_difficulty_index] = current_chart
	
	var display_notes = notes_parent.get_children()
	for deleting_note in display_notes:
		notes_parent.remove_child(deleting_note)

	update_file_path_display(false)

func _on_delete_notes_button_pressed() -> void:
	delete_notes_interval_control.visible = true
	delete_notes_origin_start_lineedit.text = ""
	delete_notes_origin_end_lineedit.text = ""

func _on_copy_notes_button_pressed() -> void:
	copy_notes_interval_control.visible = true
	copy_notes_origin_start_lineedit.text = ""
	copy_notes_origin_end_lineedit.text = ""
	copy_notes_target_start_lineedit.text = ""

func _on_copy_difficulty_button_pressed() -> void:
	copy_difficulty_control.visible = true
	copy_difficulty_selection_optionbutton.selected = -1
	for i in copy_difficulty_selection_optionbutton.item_count:
		var diff_index = Manager.difficulties[i]
		copy_difficulty_selection_optionbutton.set_item_disabled(i, diff_index == current_difficulty_index)

func _on_delete_interval_cancel_button_pressed() -> void:
	delete_notes_interval_control.visible = false


func _on_delete_interval_apply_button_pressed() -> void:
	if !validate_delete_interval_fields():
		display_error_list(_validation_errors)
		return
	
	var start_beat = float(delete_notes_origin_start_lineedit.text)
	var end_beat = float(delete_notes_origin_end_lineedit.text)
	
	var start_time = convert_beat_to_time(start_beat)
	var end_time = convert_beat_to_time(end_beat)
	
	delete_timeline_notes_on_interval(start_time, end_time)
	
	delete_notes_interval_control.visible = false

func validate_delete_interval_fields() -> bool:
	var errors = 0
	
	var start : float = -1
	var end : float = -1
	_validation_errors = ""
	
	if delete_notes_origin_start_lineedit.text == "":
		errors += 1
		_validation_errors += "Start field is empty\n"
	elif !delete_notes_origin_start_lineedit.text.is_valid_float():
		errors += 1
		_validation_errors += "Start field is invalid\n"
	else:
		start = float(delete_notes_origin_start_lineedit.text)
	
	if delete_notes_origin_end_lineedit.text == "":
		errors += 1
		_validation_errors += "End field is empty\n"
	elif !delete_notes_origin_end_lineedit.text.is_valid_float():
		errors += 1
		_validation_errors += "End field is invalid\n"
	else:
		end = float(delete_notes_origin_end_lineedit.text)
		
	if end <= start:
		errors += 1
		_validation_errors += "End can't be lower than Start\n"
	
	return errors == 0


func _on_confirmation_dialog_confirmed() -> void:
	if danger_is_deleting_notes:
		delete_timeline_notes()
	elif danger_is_discarding_for_new_file:
		_on_new_file_button_pressed(true)
	elif danger_is_discarding_for_open_file:
		_on_open_file_button_pressed(true)
	elif danger_is_discarding_to_quit:
		_on_quit_button_pressed(true)
	elif danger_is_deleting_timeline:
		difficulty_selection_optionbutton.selected = -1
		
		timeline_scrollcontainer.visible = false
		create_timeline_control.visible = true
		create_timeline_control.reset()
		chart_notes_options_control.visible = false
		
		current_beat_list = []
		current_strong_beat_list = []
		
		current_map.beats = []
		current_map.strong_beats = []
		
		current_difficulty_index = ""
		current_chart = null
		for i in current_map.charts.keys():
			current_map.charts[i] = null
		
		update_file_path_display(false)
	
	set_confirmation_type(confirmation_options.none)
	

func _on_confirmation_dialog_canceled() -> void:
	confirmation_dialog.visible = false
	set_confirmation_type(confirmation_options.none)

func _on_delete_all_notes_button_pressed() -> void:
	confirmation_dialog.visible = true
	set_confirmation_type(confirmation_options.delete_all_notes)
	confirmation_dialog.title = "Delete Notes"
	confirmation_dialog.dialog_text = "Are you sure you want to delete all notes from " + current_difficulty_index.to_upper() + " difficulty?"

func set_confirmation_type(option : confirmation_options):
	danger_is_deleting_notes = option == confirmation_options.delete_all_notes
	danger_is_discarding_for_new_file = option == confirmation_options.discard_changes_to_new_file
	danger_is_discarding_for_open_file = option == confirmation_options.discard_changes_to_open_file
	danger_is_deleting_timeline = option == confirmation_options.delete_timeline
	danger_is_discarding_to_quit = option == confirmation_options.discard_changes_to_quit

func set_length(length : float):
	current_map.length = length


func _on_copy_difficulty_cancel_button_pressed() -> void:
	copy_difficulty_control.visible = false


func _on_copy_difficulty_apply_button_pressed() -> void:
	var index = copy_difficulty_selection_optionbutton.selected
	
	if index == -1 || !Manager.difficulties.has(index):
		return
	
	var difficulty = Manager.difficulties[index]
	
	if difficulty == current_difficulty_index:
		return
	
	var ref_tracks : Array[ChartTrack] = current_map.charts[difficulty].tracks
	
	clean_notes()
	
	for track_index in current_chart.tracks.size():
		current_chart.tracks[track_index].times.append_array(ref_tracks[track_index].times)
	current_map.charts[current_difficulty_index] = current_chart
	
	load_timeline(current_difficulty_index)
	
	copy_difficulty_control.visible = false


func _on_copy_interval_cancel_button_pressed() -> void:
	copy_notes_interval_control.visible = false


func _on_copy_interval_apply_button_pressed() -> void:
	if !validade_copy_interval_fields():
		display_error_list(_validation_errors)
		return
	
	var upcoming_chart : Chart = Chart.new() 
	upcoming_chart.tracks = []
	
	var error : float = 0.001
	var origin_start_beat : float = float(copy_notes_origin_start_lineedit.text)
	var origin_end_beat : float = float(copy_notes_origin_end_lineedit.text)
	var target_start_beat : float = float(copy_notes_target_start_lineedit.text)
	
	var origin_target_beat_diff = target_start_beat - origin_start_beat
	
	var origin_start_time : float = convert_beat_to_time(origin_start_beat)
	var origin_end_time : float = convert_beat_to_time(origin_end_beat)
	
	var target_start_time : float = convert_beat_to_time(target_start_beat)
	var target_end_time : float = convert_beat_to_time(origin_end_beat + origin_target_beat_diff)

	delete_timeline_notes_on_interval(target_start_time, target_end_time)

	for track_index in current_chart.tracks.size():
		var origin_maps : Array[ChartTrackTime] = []
		origin_maps = current_chart.tracks[track_index].times.filter(func(a) : return a.time >= (origin_start_time - error) && a.time <= (origin_end_time - error) )
		for i in origin_maps.size():
			var new_time : ChartTrackTime = ChartTrackTime.new()
			
			var original_point = origin_maps[i].time
			var original_beat_point = convert_time_to_beat(original_point)
			
			new_time.duration = min(origin_maps[i].duration, origin_end_time - original_point)
			
			
			var target_beat_point = original_beat_point + origin_target_beat_diff
			var target_point = convert_beat_to_time(target_beat_point)
			new_time.time = target_point
			current_chart.tracks[track_index].times.append(new_time)
		
		#current_chart.tracks[track_index].times.append_array(origin_maps)
		current_chart.tracks[track_index].times.sort_custom(func(a, b) : return a.time < b.time)
		#upcoming_chart.tracks.append(origin_maps)
	
	current_map.charts[current_difficulty_index] = current_chart
	
	load_timeline(current_difficulty_index)
	
	copy_notes_interval_control.visible = false
	update_file_path_display(false)

func validade_copy_interval_fields() -> bool:
	var errors : int = 0
	
	var start : float = -1
	var end : float = -1
	
	_validation_errors = ""
	
	if copy_notes_origin_start_lineedit.text == "":
		errors += 1
		_validation_errors += "Origin Start field is empty\n"
	elif !copy_notes_origin_start_lineedit.text.is_valid_float():
		errors += 1
		_validation_errors += "Origin Start value is invalid\n"
	else:
		start = float(copy_notes_origin_start_lineedit.text)
		if start < 0:
			errors += 1
			_validation_errors += "Origin Start value can't be negative\n"
	
	if copy_notes_origin_end_lineedit.text == "":
		errors += 1
		_validation_errors += "Origin End field is empty\n"
	elif !copy_notes_origin_end_lineedit.text.is_valid_float():
		errors += 1
		_validation_errors += "Origin End field is invalid\n"
	else:
		end = float(copy_notes_origin_end_lineedit.text)
		if end < 0:
			errors += 1
			_validation_errors += "Origin Start field is empty\n"
	
	if copy_notes_target_start_lineedit.text == "":
		errors += 1		
		_validation_errors += "Target Start field is empty\n"
	elif !copy_notes_target_start_lineedit.text.is_valid_float():
		errors += 1
		_validation_errors += "Target Start field is empty\n"
	else:
		var target_start = float(copy_notes_target_start_lineedit.text)
		var interval_length = end - start
		if target_start < 0:
			errors += 1
			_validation_errors += "Target Start field value can't be negative\n"
		elif target_start >= start && target_start < end:
			errors += 1
			_validation_errors += "Target Start can't be inside origin interval\n"
		elif target_start + interval_length >= start && target_start + interval_length< end:
			errors += 1
			_validation_errors += "Target Start can't be inside origin interval\n"
	
	if end <= start:
		errors += 1
		_validation_errors += "Origin End can't be lower than Start\n"
	
	return errors == 0


func _on_delete_timeline_button_pressed() -> void:
	confirmation_dialog.visible = true
	set_confirmation_type(confirmation_options.delete_timeline)
	confirmation_dialog.title = "Delete Timeline"
	confirmation_dialog.dialog_text = "Are you sure you want to delete timeline? All charting done will be deleted"

func update_file_path_display(is_saved : bool):
	has_unsaved_changes = !is_saved
	var displaying_title = "" if is_saved else "* "
	displaying_title += current_file_path if current_file_path != "" else "[untitled]"
	file_path_label.text = displaying_title


func _on_quit_button_pressed(force : bool = false) -> void:
	if has_unsaved_changes && !force:
		confirmation_dialog.visible = true
		set_confirmation_type(confirmation_options.discard_changes_to_quit)
		confirmation_dialog.title = "Discard Changes"
		confirmation_dialog.dialog_text = "Are you sure you want to quit without saving the current changes?"
	else:
		get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit_button_pressed()
		get_tree().set_auto_accept_quit(false)

func display_error_list(errors : String) -> void:
	validation_error_window.visible = true
	validation_error_textedit.text = errors


func _on_validation_error_window_close_requested() -> void:
	validation_error_window.visible = false
