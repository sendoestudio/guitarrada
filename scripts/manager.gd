extends Node

var current_map_path : String = "res://default_format.json" #change to agregator

#player id, selected map path
var current_player_chart_path : Dictionary[int, String] = {
	0 : "res://default_format.json",
	1 : "res://default_format.json"
}

#player id, scoring
var current_player_score : Dictionary[int, int] = {
	
}

var current_time : float = -1
var is_playing : bool = false


var input_video_latency : float = 0
var input_audio_latency : float = 0
