extends Node3D
class_name Level

@export var countdown_timer : float = 3
@export var post_gameplay_timer : float = 3

@export var tracks : Array[Node3D]

@export var tracks_velocity : float = 1
@export var visibility_time_before_hit : float = 4
@export var visibility_time_after_hit : float = 1
@export var post_pause_countdown : float = 1

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

var beats : Array
var beat_pointer : int = 0
var strong_beats : Array
var strong_beat_pointer : int = 0

func _ready() -> void:
	current_map = Manager.current_map_info
	
	if "length" in current_map:
		end_of_level = current_map.length + post_gameplay_timer
	
	if "audio" in current_map:
		var audio_file = load(current_map.audio)
		if audio_player != null && audio_file != null:
			audio_player.stream = audio_file
			
	if "beats" in current_map:
		if current_map.beats.size() > 0:
			beat_pointer = 0
			beats = current_map.beats
	
	
	if "strong_beats" in current_map:
		if current_map.strong_beats.size() > 0:
			strong_beat_pointer = 0
			strong_beats = current_map.strong_beats
	
	has_audio_started = false
	
	#current_score = 0
	#current_combo = 0
	#highest_combo = 0
	#current_multiplier = 1
	
	current_time = -countdown_timer
	Manager.is_playing = true
	
	Manager.reset_beat_factor()
			
func _process(delta: float) -> void:
	if audio_player.playing:
		current_time = audio_player.get_playback_position()
	else:
		current_time += delta
	
	#Manager.current_time = current_time
	Manager.set_current_time(current_time)
	var current_audio_time = Manager.get_current_audio_time()
	var current_video_time = Manager.get_current_video_time()
	
	if current_time >= 0 && !has_audio_started:
		has_audio_started = true
		if audio_player != null:
			audio_player.play(current_time)
			
	if current_audio_time >= end_of_level:
		finish_level()
		
	if beat_pointer != -1:
		if beats[beat_pointer] <= current_video_time:
			beat_pointer += 1
			if beat_pointer >= beats.size():
				beat_pointer = -1
		
		if beat_pointer > 0:
			Manager.set_beat_factor(current_video_time, beats[beat_pointer -1], beats[beat_pointer])
	
	if strong_beat_pointer != -1:
		if strong_beats[strong_beat_pointer] <= current_video_time:
			strong_beat_pointer += 1
			if strong_beat_pointer >= strong_beats.size():
				strong_beat_pointer = -1
		
		if strong_beat_pointer > 0:
			Manager.set_strong_beat_factor(current_video_time, strong_beats[strong_beat_pointer -1], strong_beats[strong_beat_pointer])
	

func finish_level():
	Manager.go_to_result_scene()
	pass
