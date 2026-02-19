extends Node

const default_note_path : String = "res://defaults/example_note.tscn"

@export var track_index : int = 0
@export var main_color : Color
@export var highlight_while_pressing : bool = false
@export var turn_off_smoother : float = 0

@export var notes_direction : Vector3 = Vector3(0, 0, 1)

var visibility_start_time : float
var visibility_end_time : float
var track_velocity : Vector3

var turn_off_timer : float

@onready var inner_display : MeshInstance3D = $CenterMeshInstance

var current_material : StandardMaterial3D

@onready var notes_parent : Node3D = $MomentsParent

var track_times
var visible_area_node_index : int = -1
var invisible_area_node_index : int = -1

func _ready() -> void:
	var material : StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = main_color
	material.emission = main_color
	
	inner_display.set_surface_override_material(0, material)
	
	current_material = inner_display.get_active_material(0)
	
	turn_off_timer = 0

func _process(delta: float) -> void:
	if Manager.is_playing && track_times != null:
		var time = Manager.current_time
		notes_parent.position = time * track_velocity
		
		if visible_area_node_index != -1:
			if time > track_times[visible_area_node_index].time - visibility_start_time:
				notes_parent.get_child(visible_area_node_index).visible = true
				visible_area_node_index += 1
				if visible_area_node_index >= track_times.size():
					visible_area_node_index = -1
		
		if invisible_area_node_index != -1:
			if time > track_times[invisible_area_node_index].time + visibility_end_time:
				notes_parent.get_child(invisible_area_node_index).visible = false
				invisible_area_node_index += 1
				if invisible_area_node_index >= track_times.size():
					invisible_area_node_index = -1
	
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
		
	
	

func set_track_props(velocity : float, time_before_view : float, time_afer_view : float) -> void:
	track_velocity = velocity * notes_direction
	visibility_start_time = time_before_view
	visibility_end_time = time_afer_view

func set_track_notes(times) -> void:
	if times == null:
		return
	
	track_times = times
	
	for time_info in track_times:
		var note = load(default_note_path)
		var note_instance = note.instantiate()
		notes_parent.add_child(note_instance)
		note_instance.position = - time_info.time * track_velocity
		note_instance.visible = visibility_start_time == -1
		visible_area_node_index = 0 if visibility_start_time != -1 else -1
		invisible_area_node_index = visible_area_node_index
		#when implemented, add method to add continuous commands
	
	
	
