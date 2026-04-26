extends Node
class_name Player

signal score_updated(player_index : int, score : int, multiplier : int, combo : int)
signal multiplier_updated
signal combo_updated

var is_working : bool

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

var multiplier_value : int = 1

var cumulative_points : float

#var current_time
var current_video_time : float
var current_audio_time : float

var current_score
var current_combo
var highest_combo
var last_multiplier_combo
var current_multiplier

var current_map
var current_tracks

var local_index_to_track_index : Dictionary[int, int]
#var file_index_to_track_index : Dictionary[int, int]
var local_index_to_file_index : Dictionary[int, int]
#track index, time pointer
var track_indexes : Dictionary[int, int]

var track_upcoming_times : Dictionary[int, int]
#track index, time left to hold
var track_hold_timers : Dictionary[int, float]

var stats : ResultStats

var is_first_process_frame : bool

var last_mistake_timer : float = -1

func _ready() -> void:
	if Manager.current_player_chart_difficulty == null || Manager.current_player_chart_difficulty.size() == 0:
		is_working = false
		return
		
	if !Manager.current_player_chart_difficulty.has(player_index) || player_index == -1:
		is_working = false
		return
	
	stats = ResultStats.new()
	
	var map_difficulty = Manager.current_player_chart_difficulty[player_index]
	if map_difficulty == "" || map_difficulty == null:
		is_working = false
		for track in tracks:
			track.visible = false
		return
	
	
	#var map_file = FileAccess.open(map_path, FileAccess.READ)
	#var map_content = map_file.get_as_text()
	#current_map = JSON.parse_string(map_content)
	current_map = Manager.current_map_info.charts[map_difficulty]
	current_tracks = current_map.tracks
	#verify tracks to see if indexes are valid
	for i in tracks.size():
		var track : Track = tracks[i]
		if track == null:
			return
		
		track.set_track_props(tracks_velocity, visibility_time_before_hit, visibility_time_after_hit)
		var current_track_index : int = track.track_index
		var file_index : int = 0
		for track_info in current_tracks:
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
	
	#for mult in multiplier_rules:
		#print("m: " + str(mult) + " > " + str(multiplier_rules[mult]))
	current_score = 0
	current_combo = 0
	highest_combo = 0
	last_multiplier_combo = 0
	current_multiplier = 1
	is_working = true
	
	is_first_process_frame = true
	
	Manager.update_player_placement(player_index, current_score)
	
func _process(delta: float) -> void:
	current_audio_time = Manager.get_current_audio_time()
	current_video_time = Manager.get_current_video_time()
	
	for i in local_index_to_track_index:
		verify_track(local_index_to_file_index[i], local_index_to_track_index[i], delta)
	
	if is_first_process_frame:
		score_updated.emit(player_index, get_current_score(), current_multiplier, current_combo)
		is_first_process_frame = false

func verify_track(index, track_index, time_delta):
	if current_tracks.size() <= index || current_tracks[index] == null:
		return
	
	var button_name = "p"+str(player_index)+"_button_" + str(int(track_index))
	
	if track_hold_timers.has(track_index) && track_hold_timers.get(track_index) > 0:
		var timer = track_hold_timers.get(track_index)
		timer -= time_delta
		
		if timer > 0:
			if Input.is_action_pressed(button_name):
				cumulative_points += time_delta * multiplier_value * continuous_point_per_second
			else:
				timer = 0
			
		if timer <= 0:
			current_score += floori(cumulative_points)
			cumulative_points = 0
			track_hold_timers.erase(track_index)
			stats.score = current_score
			send_stats()
			
			tracks[track_index].set_continous_end()
	
		track_hold_timers[track_index] = timer
		score_updated.emit(player_index, get_current_score(), current_multiplier, current_combo)
	
	var time_pointer = track_indexes.get(index)
	if time_pointer == -1 || current_tracks[index].times.size() <= time_pointer:
		send_stats()
		return
	
	var note_time = current_tracks[index].times[time_pointer].time
	var has_duration = current_tracks[index].times[time_pointer].duration > 0
	
	if Input.is_action_just_pressed(button_name) && current_audio_time >= (note_time - before_error_margin) && current_audio_time <= (note_time + after_error_margin):
		#print("hit")
		var negative_delta : float
		if note_time <= current_audio_time:
			negative_delta = (current_audio_time - note_time) / before_error_margin
		else:
			negative_delta = (note_time - current_audio_time) / before_error_margin
		var delta = 1 - negative_delta
		
		#the function you decide here should interfere slightly in the score's difficulty
		var points = roundi(delta * max_points)
		if points < min_points:
			points = min_points
		
		update_stats(delta)
			
		current_score += points * multiplier_value
		stats.score = current_score
		
		current_combo += 1
		current_multiplier = calculate_multiplier()
		
		if current_combo > highest_combo:
			highest_combo = current_combo
			stats.max_combo = highest_combo
		
		
		tracks[track_index].set_note_hit(time_pointer, has_duration)
		track_indexes.set(index, time_pointer + 1)
		if track_indexes.get(index) >=  current_tracks[index].times.size():
			track_indexes.set(index, -1)
			send_stats()
		
		var length = current_tracks[index].times[time_pointer].duration
		if length > 0:
			track_hold_timers.set(track_index, length)
	
		score_updated.emit(player_index, get_current_score(), current_multiplier, current_combo)
		multiplier_updated.emit()
		combo_updated.emit()
		
		
	elif current_audio_time > (note_time + after_error_margin):
		#print("miss")
		current_combo = 0
		current_multiplier = calculate_multiplier()
		update_stats(-1)
		last_mistake_timer = after_error_margin
		
		tracks[track_index].set_note_miss(time_pointer)
		track_indexes.set(index, time_pointer + 1)
		if track_indexes.get(index) >=  current_tracks[index].times.size():
			track_indexes.set(index, -1)
			send_stats()
		
		score_updated.emit(player_index, get_current_score(), current_multiplier, current_combo)
		multiplier_updated.emit()
		combo_updated.emit()
		
	elif Input.is_action_just_pressed(button_name):
		#depends if you want to count an additional click as a mistake
		#although I recommend using with a timer to avoid players believing the score is too harsh
		#and also to avoid double discount if the player overclicked right after
		#a note was registered as a mistake
		stats.overclicks += 1
		if last_mistake_timer > 0:
			last_mistake_timer -= time_delta
		else:
			current_combo = 0 #example: if you want to break the combo the player is overclicking
			current_multiplier = calculate_multiplier()
		#print("miss")
		#current_combo = 0
		
		score_updated.emit(player_index, get_current_score(), current_multiplier, current_combo)
		multiplier_updated.emit()
		combo_updated.emit()
		
func get_current_score():
	return floori(current_score + cumulative_points)
	
func get_current_multiplier():
	return current_multiplier

func get_current_combo():
	return current_combo

func update_stats(delta):
	if delta > 0.95:
		stats.perfect_hits += 1
	elif delta > 0.75:
		stats.good_hits += 1
	elif  delta >= 0:
		stats.average_hits += 1
	else:
		stats.mistakes += 1

func send_stats():
	Manager.current_player_stats[player_index] = stats
	Manager.update_player_placement(player_index, current_score)

func calculate_multiplier():
	var response = 1
	
	#if you just need a simple combo system, use this one
	#if current_combo >= 12:
		#response = 4
	#elif current_combo >= 8:
		#response = 3
	#elif current_combo >= 4:
		#response = 2
	
	#in case you don't want to completely break the combo
	#when the player makes a mistake
	
	if current_combo == 0:
		if current_multiplier > 1:
			response = current_multiplier - 1
			if response == 3:
				last_multiplier_combo = 8
			elif response == 2:
				last_multiplier_combo = 4
			else:
				last_multiplier_combo = 0
	else:
		last_multiplier_combo += 1
		if last_multiplier_combo >= 12:
			response = 4
		elif last_multiplier_combo >= 8:
			response = 3
		elif last_multiplier_combo >= 4:
			response = 2
	
	
	return response
