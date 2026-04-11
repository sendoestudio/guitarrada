extends Node3D
class_name SynesthesiaHandler

@export var max_value : float = 1
@export var min_value : float = 0
@export var strong_beats_only : bool = false

@export var use_position : bool
@export var position_modifier : Vector3
var rest_position : Vector3

@export var use_rotation : bool
@export var rotation_modifier : Vector3
var rest_rotation : Vector3

@export var use_scale : bool
@export var scale_modifier : Vector3
var rest_scale : Vector3

@export var use_color : bool
@export var color_modifier : Color
var rest_color : Color

func _ready() -> void:
	rest_position = position
	rest_rotation = rotation
	rest_scale = scale

func _process(delta: float) -> void:
	var beat = Manager.get_strong_beat_factor() if strong_beats_only else Manager.get_beat_factor()
	
	var influence =  (beat - min_value) / (max_value - min_value)
	
	if use_position:
		position =  rest_position + position_modifier * influence
	
	if use_rotation:
		rotation = rest_rotation + rotation_modifier * influence
		
	if use_scale:
		scale = rest_scale + scale_modifier * influence
	
		
