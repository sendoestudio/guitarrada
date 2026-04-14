extends Control

@onready var video_control : Control = $VideoControl
@onready var audio_control : Control = $AudioControl
@onready var finish_control : Control = $FinishControl

@onready var sync_process_animation_player : AnimationPlayer = $SyncProcessAnimationPlayer
@onready var response_animation_player : AnimationPlayer = $ResponseAnimationPlayer

@onready var video_latency_result_label : Label = $FinishControl/ResultControl/ResultVBoxContainer/HBoxContainer/ValueLabel
@onready var audio_latency_result_label : Label = $FinishControl/ResultControl/ResultVBoxContainer/HBoxContainer2/ValueLabel

@onready var video_start_button : Button = $VideoControl/StartVideoButton
@onready var audio_start_button : Button = $AudioControl/StartAudioButton
@onready var first_option_finish_button : Button = $FinishControl/ResultControl/OptionsVBoxContainer/ConfirmButton

var state = 0
var is_syncing : bool
var input_arrays : Array[float]

var video_latency_result : float
var audio_latency_result : float

var video_latency_ms : int
var audio_latency_ms : int

var pointer : int

var previous_icon_scheme

func _ready() -> void:	
	state = 0
	is_syncing = false
	
	sync_process_animation_player.play("video_prep")
	
	video_latency_result = 0
	audio_latency_result = 0
	
	video_start_button.grab_focus()

func _process(delta: float) -> void:
	if is_syncing:
		var current_time = sync_process_animation_player.current_animation_position
		if current_time > 17.45:
			is_syncing = false
			if state == 0:
				state = 1
				calculate_latency(true)
				sync_process_animation_player.play("audio_prep")
				audio_start_button.grab_focus()
			else:
				state = 2
				calculate_latency(false)
				sync_process_animation_player.play("finish")
				set_resulting_values()
				first_option_finish_button.grab_focus()
				
	
		
func _input(event: InputEvent) -> void:
	if !is_syncing:
		return
	
	if (event is InputEventMouseButton || event is InputEventMouseMotion || event is InputEventJoypadMotion):
		return
	
	if (!event.pressed):
		return
	
	var current_time : float = sync_process_animation_player.current_animation_position
	
	
	if current_time > 2.5 || current_time < 17.5:
		#simpler implementation
		var offset : float = fmod(current_time, 1)
		input_arrays.append(offset)
		
	if current_time > 2 || current_time < 17:
		if state == 0:
			response_animation_player.play("video_input")
		else:
			response_animation_player.play("audio_input")

func _on_start_video_button_pressed() -> void:
	sync_process_animation_player.play("video_sync")
	input_arrays.clear()
	is_syncing = true

func _on_start_audio_button_pressed() -> void:
	sync_process_animation_player.play("audio_sync")
	input_arrays.clear()
	is_syncing = true

func _on_confirm_button_pressed() -> void:
	Manager.set_audio_latency(audio_latency_ms)
	Manager.set_video_latency(video_latency_ms)
	#call persistence method
	
	_call_return_scene()


func _on_reject_button_pressed() -> void:
	_call_return_scene()


func _on_try_again_button_pressed() -> void:
	state = 0
	is_syncing = false
	sync_process_animation_player.play("video_prep")
	
	video_latency_result = 0
	audio_latency_result = 0

func calculate_latency(is_video : bool):
	if input_arrays.size() < 10:
		return
	
	input_arrays.sort()
	
	var median
	
	var index_one = input_arrays.size() / 2 - 1
	median = input_arrays[index_one]
	
	if (input_arrays.size() % 2 != 0):
		var index_two = input_arrays.size() / 2
		median +=  input_arrays[index_two]
		median = median / 2.0
	
	if median > 0.85:
		median = 0
	
	if is_video:
		video_latency_result = median
	else:
		audio_latency_result = median

func set_resulting_values():
	video_latency_ms = roundi(video_latency_result * 1000)
	audio_latency_ms = roundi(audio_latency_result * 1000)
	
	video_latency_result_label.text = str(video_latency_ms)
	audio_latency_result_label.text = str(audio_latency_ms)


func _on_cancel_button_pressed() -> void:
	_call_return_scene()

func _call_return_scene() -> void:
	#Manager.go_to_song_selection_scene()
	Manager.go_to_settings_scene()
