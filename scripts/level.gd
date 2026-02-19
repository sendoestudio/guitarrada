extends Node3D

@export var countdown_timer : float = 3

@export var tracks : Array[Node3D]

@export var default_map : JSON

@export var tracks_velocity : float = 1
@export var visibility_time_before_hit : float = 4
@export var visibility_time_after_hit : float = 1

var current_time

func _ready() -> void:
	var map
	
	if default_map != null:
		map = default_map.data
		
	for track in tracks:
		if track == null:
			return
		
		track.set_track_props(tracks_velocity, visibility_time_before_hit, visibility_time_after_hit)
		var current_track_index = track.track_index
		for track_info in map.chart:
			if track_info.track_index == current_track_index:
				track.set_track_notes(track_info.times)
				break
	
	current_time = -countdown_timer
	Manager.is_playing = true
			
func _process(delta: float) -> void:
	current_time += delta
	Manager.current_time = current_time
