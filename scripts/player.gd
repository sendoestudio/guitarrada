extends Node
class_name Player

@export var level_manager : Level

@export var player_index : int = -1

@export var tracks : Array[Track]

@export var tracks_velocity : float = 1
@export var visibility_time_before_hit : float = 4
@export var visibility_time_after_hit : float = 1

const before_error_margin : float = 0.05
const after_error_margin : float = 0.05
const min_points : int = 1
const max_points : int = 10
const continuous_point_per_second : int = 5

#multiplier, amount of consecutive hits
var multiplier_rules : Dictionary[int, int] = {
	2 : 4,
	3 : 8,
	4 : 12
}

var cumulative_points : float

var current_time

var current_score
var current_combo
var highest_combo
var current_multiplier

var current_map

var local_index_to_track_index : Dictionary[int, int]
#var file_index_to_track_index : Dictionary[int, int]
var local_index_to_file_index : Dictionary[int, int]
#track index, time pointer
var track_indexes : Dictionary[int, int]

var track_upcoming_times : Dictionary[int, int]
#track index, time left to hold
var track_hold_timers : Dictionary[int, float]


func _ready() -> void:
	if Manager.current_player_chart_path == null || Manager.current_player_chart_path.size() == 0:
		return
		
	if !Manager.current_player_chart_path.has(player_index) || player_index == -1:
		return
	
	var map_path = Manager.current_player_chart_path[player_index]
	var map_file = FileAccess.open(map_path, FileAccess.READ)
	var map_content = map_file.get_as_text()
	current_map = JSON.parse_string(map_content)
	
	#verify tracks to see if indexes are valid
	for i in tracks.size():
		var track : Track = tracks[i]
		if track == null:
			return
		
		track.set_track_props(tracks_velocity, visibility_time_before_hit, visibility_time_after_hit)
		var current_track_index : int = track.track_index
		var file_index : int = 0
		for track_info in current_map.chart:
			if track_info.track_index == current_track_index:
				if local_index_to_track_index.has(current_track_index):
					print("alert: more than one track with the same index, please check it out")
					break
				
				#file_index_to_track_index.set(file_index, current_track_index)
				track.set_track_notes(track_info.times)
				track.set_player_index(player_index)
				track_indexes.set(current_track_index, 0)
				local_index_to_track_index.set(i, current_track_index)
				local_index_to_file_index.set(i, file_index)
				break
			file_index += 1
	
	if local_index_to_track_index.size() != tracks.size():
		print("alert: the amount of tracks loaded diverge from the amount of existing tracks, please verify")
	
	
	
	multiplier_rules.sort()
	for mult in multiplier_rules:
		print("m: " + str(mult) + " > " + str(multiplier_rules[mult]))
	current_score = 0
	current_combo = 0
	highest_combo = 0
	current_multiplier = 1

func _process(delta: float) -> void:
	current_time = Manager.current_time 
	for i in local_index_to_track_index:
		verify_track(local_index_to_file_index[i], local_index_to_track_index[i], delta)

func verify_track(index, track_index, time_delta):
	if current_map.chart.size() <= index || current_map.chart[index] == null:
		return
	
	var button_name = "p"+str(player_index)+"_button_" + str(int(track_index))
	
	if track_hold_timers.has(track_index) && track_hold_timers.get(track_index) > 0:
		var timer = track_hold_timers.get(track_index)
		timer -= time_delta
		if Input.is_action_pressed(button_name):
			cumulative_points += time_delta
		else:
			timer = 0
			
		if timer <= 0:
			current_score += roundi(cumulative_points * continuous_point_per_second)
			track_hold_timers.erase(track_index)
	
	var time_pointer = track_indexes.get(index)
	if time_pointer == -1 || current_map.chart[index].times.size() <= time_pointer:
		return
	
	var note_time = current_map.chart[index].times[time_pointer].time
	
	if Input.is_action_just_pressed(button_name) && current_time >= (note_time - before_error_margin) && current_time <= (note_time + after_error_margin):
		print("hit")
		var negative_delta : float
		if note_time <= current_time:
			negative_delta = (current_time - note_time) / before_error_margin
		else:
			negative_delta = (note_time - current_time) / before_error_margin
		var delta = 1 - negative_delta
		
		#the function you decide here should interfere slightly in the score's difficulty
		var points = roundi(delta * max_points)
		if points < min_points:
			points = min_points
		current_score += points
		
		current_combo += 1
		
		if current_combo > highest_combo:
			highest_combo = current_combo
		
		track_indexes.set(index, time_pointer + 1)
		if track_indexes.get(index) >=  current_map.chart[index].times.size():
			track_indexes.set(index, -1)
		
		var length = current_map.chart[index].times[time_pointer].duration
		if length > 0:
			track_hold_timers.set(track_index, length)
	
	elif current_time > (note_time + after_error_margin):
		print("miss")
		current_combo = 0
		
		track_indexes.set(index, time_pointer + 1)
		if track_indexes.get(index) >=  current_map.chart[index].times.size():
			track_indexes.set(index, -1)
		
	elif Input.is_action_just_pressed(button_name):
		#depends if you want to count an additional click as a mistake
		#although I recommend using with a timer to avoid players believing the score is too harsh
		
		print("miss")
		current_combo = 0

func get_current_score():
	return current_score
	
func get_current_multiplier():
	return current_multiplier

func get_current_combo():
	return current_combo
