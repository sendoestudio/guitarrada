extends Node

@export var track_index : int = 0
@export var main_color : Color
@export var highlight_while_pressing : bool = false
@export var turn_off_smoother : float = 0

@export var relative_start_point : Vector3
@export var relative_end_point : Vector3
@export var track_velocity : Vector3

var turn_off_timer : float

@onready var inner_display : MeshInstance3D = $CenterMeshInstance

var current_material : StandardMaterial3D

func _ready() -> void:
	var material : StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = main_color
	material.emission = main_color
	
	inner_display.set_surface_override_material(0, material)
	
	current_material = inner_display.get_active_material(0)
	
	turn_off_timer = 0

func _process(delta: float) -> void:
	var action_code = "button_" + str(track_index)
	var is_on 
	if highlight_while_pressing:
		is_on = Input.is_action_pressed(action_code)
	else:
		is_on = Input.is_action_just_pressed(action_code)
	
	
	
	if is_on:
		current_material.emission_enabled = true
		turn_off_timer = turn_off_smoother if turn_off_smoother > 0 else -1
		current_material.emission_energy_multiplier = 1 
	elif turn_off_timer > 0:
		current_material.emission_enabled = true
		turn_off_timer -= delta
		var emission_facton = turn_off_timer / turn_off_smoother
		current_material.emission_energy_multiplier = emission_facton
		if turn_off_timer <= 0:
			turn_off_timer = -1
	else:
		current_material.emission_enabled = false
