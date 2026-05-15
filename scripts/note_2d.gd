extends Node2D
class_name Note2D

@export var main_sprite : Sprite2D 
@export var continuous_center : Node2D 
@export var continuous_mesh : Sprite2D
var has_duration : bool

func create_note(duration : float, velocity : float):
	has_duration = duration > 0
	continuous_center.visible = has_duration
	if has_duration:
		continuous_center.scale.y = duration * velocity
	
func display_hit():
	main_sprite.visible = false	
	
func end_hit():
	continuous_mesh.visible = false
	
func display_mistake():
	main_sprite.self_modulate = Color.BLACK
	
	if has_duration:
		continuous_mesh.self_modulate = Color.BLACK
