extends Node
class_name Track

const default_note_path : String = "res://defaults/note.tscn"

var is_working : bool

@export var track_index : int = 0
@export var main_color : Color
@export var highlight_while_pressing : bool = false
@export var turn_off_smoother : float = 0


var visibility_start_time : float
var visibility_end_time : float
var absolute_velocity : float

var turn_off_timer : float

var track_times
var visible_area_node_index : int = -1
var invisible_area_node_index : int = -1

var player_index
var action_button_name

var previous_note_index : int = -1

func _ready() -> void:	
	turn_off_timer = 0

func _process(_delta: float) -> void:
	pass
	

func set_track_props(velocity : float, time_before_view : float, time_afer_view : float) -> void:
	pass

func set_track_notes(times) -> void:
	pass
	
func set_player_index(index) -> void:
	player_index = index
	action_button_name = "p"+str(player_index)+"_button_" + str(track_index)
	
	var map_difficulty = Manager.current_player_chart_difficulty[player_index]
	is_working = !(map_difficulty == "" || map_difficulty == null)
	if !is_working:
		return

func set_note_hit(note_index, is_continuous : bool = false) -> void:
	pass

func set_note_miss(note_index) -> void:
	pass

func set_continous_end() -> void:
	pass
