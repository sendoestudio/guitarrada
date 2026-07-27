extends Node
class_name Level

@export var countdown_timer : float = 3
@export var post_gameplay_timer : float = 3

@export var audio_player : AudioStreamPlayer

var cumulative_points : float

var current_time

var current_map

var local_index_to_track_index : Dictionary[int, int]
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

func _init() -> void:
	var info = Manager.current_map_info
	if info == null || info == {}:
		info = Manager.load_json_file(Manager.testing_level_file_path)
		
		if Manager.current_player_chart_difficulty.size() == 0:
			for index in Manager.player_amount:
				if index < Manager.testing_difficulties.size():
					Manager.current_player_chart_difficulty[index] = Manager.difficulties[Manager.tesing_difficulties[index]]
				else:
					Manager.current_player_chart_difficulty[index] = ""

func _ready() -> void:	
	current_map = Manager.current_map_info
	if current_map == null || current_map == {}:
		current_map = Manager.load_json_file(Manager.testing_level_file_path)
	
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
	
	current_time = -countdown_timer
	Manager.is_playing = true
	
	Manager.reset_beat_factor()
	
	Manager.set_beats_distance(-1)
	Manager.set_strong_beats_distance(-1)
			
func _process(delta: float) -> void:
	if audio_player.playing:
		current_time = audio_player.get_playback_position()
	else:
		current_time += delta
	
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
			elif beat_pointer > 0:
				var distance = beats[beat_pointer] - beats[beat_pointer -1]
				Manager.set_beats_distance(distance)
		
		if beat_pointer > 0:
			Manager.set_beat_factor(current_video_time, beats[beat_pointer -1], beats[beat_pointer])
	
	if strong_beat_pointer != -1:
		if strong_beats[strong_beat_pointer] <= current_video_time:
			strong_beat_pointer += 1
			if strong_beat_pointer >= strong_beats.size():
				strong_beat_pointer = -1
			elif strong_beat_pointer > 0:
				var distance = strong_beats[strong_beat_pointer] - strong_beats[strong_beat_pointer -1]
				Manager.set_strong_beats_distance(distance)
		
		if strong_beat_pointer > 0:
			Manager.set_strong_beat_factor(current_video_time, strong_beats[strong_beat_pointer -1], strong_beats[strong_beat_pointer])
	

func finish_level():
	Manager.go_to_result_scene()
	pass
