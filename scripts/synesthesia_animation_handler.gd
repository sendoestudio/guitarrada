extends Node
class_name SynesthesiaAnimationHandler

const error = 0.015

@export var animation_player : AnimationPlayer
@export var animation_name : String
@export var idle_animation_name : String
@export var is_following_strong_beats : bool
@export var follow_beats_scale : bool

var animation_length : float

func _ready() -> void:
	if animation_player == null || animation_name == "":
		animation_length = -1
		return
		
	if animation_player.has_animation(animation_name):
		animation_length = animation_player.get_animation(animation_name).length
		if animation_player.has_animation(idle_animation_name):
			animation_player.play(idle_animation_name)
	else:
		animation_length = -1

func _process(_delta: float) -> void:
	if animation_length == -1:
		return
	
	var beat = Manager.get_strong_beat_factor() if is_following_strong_beats else Manager.get_beat_factor()
	if beat <= 0:
		return
	
	if beat >= (1 - error) || beat <= 0 + error:
		var local_length = animation_length
		if follow_beats_scale:
			local_length = Manager.get_strong_beats_distance() if is_following_strong_beats else Manager.get_beats_distance()
		animation_player.stop(true)
		animation_player.play(animation_name, -1, animation_length / local_length)
		
