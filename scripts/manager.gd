extends Node

const is_using_3d_stage : bool = true

const map_folder_path: String = "res://maps/"
const map_file_format : String = "info.json"

const song_selection_path : String = "res://scenes/map_selection_scene.tscn"
const difficulty_selection_path : String = "res://scenes/difficulty_selection_scene.tscn"
#const stage_path : String = "res://scenes/level_scene.tscn"
const stage_3d_path : String = "res://scenes/level_3d_scene.tscn"
const stage_2d_path : String = "res://scenes/level_2d_scene.tscn"
const result_path : String = "res://scenes/results_scene.tscn"
const settings_path : String = "res://scenes/settings_scene.tscn"
const av_sync_path : String = "res://scenes/latency_assist_control.tscn"
const go_to_level_editor : String = ""

const audio_latency_min_limit : int = 0
const audio_latency_max_limit : int = 9999
const video_latency_min_limit : int = 0 #use negative value in case you want to accept 
const video_latency_max_limit : int = 9999

var _video_latency : float = 0
var _audio_latency : float = 0

var current_map_path : String = "" #change to agregator
var current_map_info : Dictionary = {}
var current_chart_path : String = ""

var last_song_selection_index : int = -1

var tracklist : Array[Dictionary] = []

const interval_beats_amount : int = 3

const track_amount : int = 3
#player id, selected map path
var current_player_chart_difficulty : Dictionary[int, String] = {
	0 : "",
	1 : ""
}

#player id, scoring
var current_player_score : Dictionary[int, int] = {
	0 : -1,
	1 : -1
}

var current_player_stats : Dictionary[int, ResultStats] = {
	0 : null,
	1 : null
}

const difficulties : Dictionary[int, String] = {
	0 : "easy",
	1 : "medium",
	2 : "hard",
	3 : "expert"
}

var player_position_list : Array[PlayerPosition] = []

#multiplier, amount of consecutive hits
var _current_time : float = -1
var _current_audio_time : float = -1
var _current_video_time : float = -1
var is_playing : bool = false


var _input_video_latency : float = 0
var _input_audio_latency : float = 0

var _beat_factor : float = 0
var _strong_beat_factor : float = 0
var _beats_distance : float = -1
var _strong_beats_distance : float = -1


func go_to_song_selection_scene() -> void:
	_go_to_scene(song_selection_path)

func go_to_difficulty_selection_scene() -> void:
	_go_to_scene(difficulty_selection_path)
	
func go_to_stage_scene() -> void:
	player_position_list.clear()
	
	var path = stage_3d_path if is_using_3d_stage else stage_2d_path
	_go_to_scene(path)

func go_to_result_scene() -> void:
	_go_to_scene(result_path)
	
func go_to_latency_assistant_scene() -> void:
	_go_to_scene(av_sync_path)

func go_to_settings_scene() -> void:
	_go_to_scene(settings_path)

func _go_to_scene(scene_path) -> void:
	if scene_path == "" || scene_path == null:
		return
	
	get_tree().change_scene_to_file(scene_path)

func set_selected_song(path) -> bool:
	var result = false
	
	if FileAccess.file_exists(path):
		var info = load_json_file(path)
		if info != null:
			current_map_path = path
			current_map_info = info
			result = true
	
	return result
	
func load_json_file(file_path):
	var json_text = FileAccess.get_file_as_string(file_path)
	var json_info = JSON.parse_string(json_text)
	return json_info

func quit_game():
	get_tree().quit()

#lazy load: only loads if tracklist hasn't been loaded before
#however if there is a possibility the tracklist may change in realtime
#lazy load should be off
func load_tracklist(is_lazy = true):
	if !is_lazy || tracklist.size() == 0:
		tracklist = _load_map_objects_from_folder()
		
	return tracklist

#add further atttributes to validate your maps
func _validate_tracklist_file(json_data) -> bool:
	var errors : int = 0
	
	if !("title" in json_data):
		errors += 1

	if !("artist" in json_data):
		errors += 1
	#if !("bpm" in json_data):
		#errors += 1
	if !("length" in json_data):
		errors += 1
	if !("charts" in json_data):
		errors += 1
	if !("audio" in json_data):
		errors += 1
	if !(FileAccess.file_exists(json_data.audio)):
		errors += 1
	#validade chart files tbi
	
	
	return errors == 0
	
func _load_map_objects_from_folder():
	var objects_array : Array[Dictionary] = []
	var dir = DirAccess.open(map_folder_path)
	if dir:
		dir.list_dir_begin()
		var map_folder_name = dir.get_next()
		while map_folder_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				var info_file_path = map_folder_path + "/" + map_folder_name + "/" + map_file_format
				if FileAccess.file_exists(info_file_path):
					var current_file = load_json_file(info_file_path)
					if _validate_tracklist_file(current_file):
						current_file.path = info_file_path
						objects_array.append(current_file)
					#print("info file for " + file_name + " found")
					#var current_file = load(info_file_path)
						
			#else:
				#print("Found file: " + file_name)
			map_folder_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
	
	return objects_array

	
func _load_map_paths_from_folder():
	var paths_array : Array[String] = []
	var dir = DirAccess.open(map_folder_path)
	if dir:
		dir.list_dir_begin()
		var map_folder_name = dir.get_next()
		while map_folder_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				var info_file_path = map_folder_path + "/" + map_folder_name + map_file_format
				if FileAccess.file_exists(info_file_path):
					var current_file = load_json_file(info_file_path)
					if _validate_tracklist_file(current_file):
						paths_array.append(info_file_path)
					#print("info file for " + file_name + " found")
					#var current_file = load(info_file_path)
						
			#else:
				#print("Found file: " + file_name)
			map_folder_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
	
	return paths_array


func get_video_latency() -> float:
	return _video_latency

func get_audio_latency() -> float:
	return _audio_latency

func get_video_latency_in_ms() -> int:
	return roundi(_video_latency * 1000)

func get_audio_latency_in_ms() -> int:
	return roundi(_audio_latency * 1000)

func set_video_latency(lat_ms : int):
	_video_latency = lat_ms / 1000.0
	
func set_audio_latency(lat_ms : int):
	_audio_latency = lat_ms / 1000.0

func set_current_time(time : float) -> void:
	_current_time = time
	_current_audio_time = time - _audio_latency if time != -1 else -1
	_current_video_time =  time + _video_latency if time != -1 else -1

func get_current_time() -> float:
	return _current_time
	
func get_current_audio_time() -> float:
	return _current_audio_time

func get_current_video_time() -> float:
	return _current_video_time

func set_beat_factor(time : float, current_beat : float, next_beat : float):
	var diff = next_beat - current_beat
	_beat_factor = ((next_beat - time) / (diff))

func set_strong_beat_factor(time : float, current_beat : float, next_beat : float):
	var diff = next_beat - current_beat
	_strong_beat_factor = ((next_beat - time) / (diff))

func reset_beat_factor() -> void:
	_beat_factor = 0
	_strong_beat_factor = 0

func set_beats_distance(distance : float) -> void:
	_beats_distance = distance

func set_strong_beats_distance(distance : float) -> void:
	_strong_beats_distance = distance
	

func get_beat_factor() -> float:
	return _beat_factor

func get_strong_beat_factor() -> float:
	return _strong_beat_factor
	
func get_beats_distance() -> float:
	return _beats_distance
	
func get_strong_beats_distance() -> float:
	return _strong_beats_distance
	
func update_player_placement(player_index, score) -> void:
	var found_player = player_position_list.find_custom(func(a) : return a.player_index == player_index)
	if found_player == -1:
		var new_player_position : PlayerPosition = PlayerPosition.new()
		new_player_position.player_index = player_index
		new_player_position.score = score
		player_position_list.append(new_player_position)
	else:
		player_position_list[found_player].score = score
	
	player_position_list.sort_custom(func(a, b) : return a.score > b.score)
	

func get_player_placement(player_index) -> int:
	if player_position_list.size() < 2:
		return -1
	
	var found_position = player_position_list.find_custom(func(a) : return a.player_index == player_index)
	
	if found_position != -1:
		var score = player_position_list[found_position].score
		var ties : Array[PlayerPosition] = player_position_list.filter(func(a) : return a.score == score && a.player_index != player_index)
		if ties.size() > 0:
			player_position_list[found_position].is_tied = true
			var highest_position : int = found_position
			for tie in ties:
				var pos = player_position_list.find_custom(func(a) : return a.player_index == tie.player_index)
				if pos < highest_position:
					highest_position = pos
			found_position = highest_position
	
	return found_position
