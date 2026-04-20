extends Control
class_name LevelPause

@export var _level_handler : Level
@export var restart_confirmation_call : bool = false
@export var song_selection_confirmation_call : bool = false
@export var song_resume_timer : float = -1

var _song_resume_time_left : float
var _is_restarting : bool
var _is_going_to_selection : bool
var _is_resuming : bool

@onready var options_control : Control = $OptionsControl

@onready var confirmation_control : Control = $ConfirmationControl
@onready var confirmation_action_label : Label = $ConfirmationControl/ActionLabel
@onready var confirmation_question_label : Label = $ConfirmationControl/QuestionLabel

@onready var countdown_control : Control = $CountdownControl
@onready var countdown_counter_colorrect : ColorRect = $CountdownControl/CountColorRect

func _ready() -> void:
	_is_restarting = false
	_is_going_to_selection = false
	_is_resuming = false
	resume_gameplay()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") && !get_tree().paused:
		pause_gameplay()
	
	if _is_resuming:
		_song_resume_time_left -= delta
		if song_resume_timer > 0:
			countdown_counter_colorrect.scale.x = _song_resume_time_left / song_resume_timer
		if _song_resume_time_left <= 0:
			resume_gameplay()

func resume_gameplay() -> void:
	get_tree().paused = false
	options_control.visible = false
	confirmation_control.visible = false
	countdown_control.visible = false

func pause_gameplay() -> void:
	get_tree().paused = true
	options_control.visible = true
	confirmation_control.visible = false
	countdown_control.visible = false
	
	_is_restarting = false
	_is_going_to_selection = false
	_is_resuming = false
	
func restart_level() -> void:
	get_tree().paused = false
	Manager.go_to_stage_scene()

func go_to_song_selection() -> void:
	get_tree().paused = false
	Manager.go_to_song_selection_scene()
	
func set_confirmation_control(title : String, question : String) -> void:
	confirmation_action_label.text = title
	confirmation_question_label.text = question


func _on_continue_button_pressed() -> void:
	options_control.visible = false
	
	if song_resume_timer > 0:
		_song_resume_time_left = song_resume_timer
		countdown_control.visible = true
		_is_restarting = false
		_is_going_to_selection = false
		_is_resuming = true
	else:
		resume_gameplay()


func _on_restart_button_pressed() -> void:
	if restart_confirmation_call:
		options_control.visible = false
		confirmation_control.visible = true
		set_confirmation_control("Restart Level", "Do you really want to restart?\nAll progress will be lost")
		_is_restarting = true
		_is_going_to_selection = false
		_is_resuming = false
	else:
		restart_level()

func _on_song_selection_button_pressed() -> void:
	if song_selection_confirmation_call:
		options_control.visible = false
		confirmation_control.visible = true
		set_confirmation_control("Go To Song Selection", "Do you really want to quit?\nAll progress will be lost")
		_is_restarting = false
		_is_going_to_selection = true
		_is_resuming = false
	else:
		go_to_song_selection()


func _on_confirm_button_pressed() -> void:
	if _is_restarting:
		restart_level()
	elif _is_going_to_selection:
		go_to_song_selection()


func _on_cancel_button_pressed() -> void:
	confirmation_control.visible = false
	options_control.visible = true
	
	_is_restarting = false
	_is_going_to_selection = false
	_is_resuming = false
