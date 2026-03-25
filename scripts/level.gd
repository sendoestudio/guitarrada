extends Node3D
class_name Level

@export var countdown_timer : float = 3
@export var post_gameplay_timer : float = 3

@export var tracks : Array[Node3D]

@export var tracks_velocity : float = 1
@export var visibility_time_before_hit : float = 4
@export var visibility_time_after_hit : float = 1

#decide how to implement pause panel and pause warning

#multiplier, amount of consecutive hits
var multiplier_rules : Dictionary[int, int] = {
	2 : 4,
	3 : 8,
	4 : 12
}

@export var audio_player : AudioStreamPlayer

var cumulative_points : float

var current_time

var current_map

var local_index_to_track_index : Dictionary[int, int]
#var file_index_to_track_index : Dictionary[int, int]
var local_index_to_file_index : Dictionary[int, int]
#track index, time pointer
var track_indexes : Dictionary[int, int]

var track_upcoming_times : Dictionary[int, int]
#track index, time left to hold
var track_hold_timers : Dictionary[int, float]

var has_audio_started : bool

var end_of_level : float

func _ready() -> void:
	
	var map_file = FileAccess.open(Manager.current_map_path, FileAccess.READ)
	var map_content = map_file.get_as_text()
	current_map = JSON.parse_string(map_content)
	
	if "length" in current_map:
		end_of_level = current_map.length + post_gameplay_timer
	
	if "audio" in current_map:
		var audio_file = load(current_map.audio)
		if audio_player != null && audio_player.stream != null:
			audio_player.stream = audio_file
	
	has_audio_started = false
	
	#current_score = 0
	#current_combo = 0
	#highest_combo = 0
	#current_multiplier = 1
	
	current_time = -countdown_timer
	Manager.is_playing = true
	
			
func _process(delta: float) -> void:
	if audio_player.playing:
		current_time = audio_player.get_playback_position()
	else:
		current_time += delta
	
	Manager.current_time = current_time
	
	if current_time >= 0 && !has_audio_started:
		has_audio_started = true
		if audio_player != null:
			audio_player.play(current_time)
			
	if current_time >= end_of_level:
		finish_level()

func finish_level():
	Manager.go_to_result_scene()
	pass
