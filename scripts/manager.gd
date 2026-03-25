extends Node

const song_selection_path : String = "res://scenes/map_selection_scene.tscn"
const difficulty_selection_path : String = "res://scenes/difficulty_selection_scene.tscn"
const stage_path : String = "res://example_scene.tscn" #temp scene
const result_path : String = "res://scenes/results_scene.tscn"
const settings_path : String = ""
const av_sync_path : String = ""
const go_to_level_editor : String = ""


var current_map_path : String = "res://default_format.json" #change to agregator
var current_map_info

var last_song_selection_index : int = -1
#player id, selected map path
var current_player_chart_path : Dictionary[int, String] = {
	0 : "res://default_format.json",
	1 : "res://default_format.json"
}

#player id, scoring
var current_player_score : Dictionary[int, int] = {
	0 : -1,
	1 : -1
}

var current_time : float = -1
var is_playing : bool = false


var input_video_latency : float = 0
var input_audio_latency : float = 0

func go_to_song_selection_scene() -> void:
	_go_to_scene(song_selection_path)

func go_to_difficulty_selection_scene() -> void:
	_go_to_scene(difficulty_selection_path)
	
func go_to_stage_scene() -> void:
	_go_to_scene(stage_path)

func go_to_result_scene() -> void:
	_go_to_scene(result_path)

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
