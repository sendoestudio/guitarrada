extends Track
class_name Track2D

const default_note_2d_path : String = "res://defaults/note_2d.tscn"

@export var notes_parent : Node2D
@export var particle_system : CPUParticles2D
@export var inner_display : Sprite2D

var notes_direction : Vector2 = Vector2(0, -1)
var track_velocity : Vector2
var rest_color : Color

func _ready() -> void:
	rest_color = main_color * 0.25
	rest_color.a = 1
	inner_display.self_modulate = rest_color
	
	if particle_system != null:
		particle_system.one_shot = true
		particle_system.emitting = false
	
	turn_off_timer = 0
	
func _process(delta: float) -> void:
	if !is_working:
		return
	
	if Manager.is_playing && track_times != null:
		var time = Manager.get_current_video_time()
		notes_parent.position = time * track_velocity
		
		if visible_area_node_index != -1:
			if time > track_times[visible_area_node_index].time - visibility_start_time:
				notes_parent.get_child(visible_area_node_index).visible = true
				visible_area_node_index += 1
				if visible_area_node_index >= track_times.size():
					visible_area_node_index = -1
		
		if invisible_area_node_index != -1:
			var duration = track_times[invisible_area_node_index].duration
			if duration <= 0:
				duration = 0
			if time > track_times[invisible_area_node_index].time + visibility_end_time + duration:
				notes_parent.get_child(invisible_area_node_index).visible = false
				invisible_area_node_index += 1
				if invisible_area_node_index >= track_times.size():
					invisible_area_node_index = -1
	
	#var action_code = "p"+str(player_index)+"_button_" + str(track_index)
	var is_on 
	if highlight_while_pressing:
		is_on = Input.is_action_pressed(action_button_name)
	else:
		is_on = Input.is_action_just_pressed(action_button_name)
	
	
	if is_on:
		inner_display.self_modulate = main_color
		#current_material.emission_enabled = true
		#turn_off_timer = turn_off_smoother if turn_off_smoother > 0 else -1
		#current_material.emission_energy_multiplier = 1 
	elif turn_off_timer > 0:
		turn_off_timer -= delta
		var emission_facton = turn_off_timer / turn_off_smoother
		
		var resulting_color = (main_color - rest_color) * emission_facton + rest_color
		inner_display.self_modulate = resulting_color
		if turn_off_timer <= 0:
			turn_off_timer = -1
	else:
		inner_display.self_modulate = rest_color
	
func set_note_hit(note_index, is_continuous : bool = false) -> void:
	var note : Note2D = notes_parent.get_child(note_index)
	note.display_hit()
	previous_note_index = note_index
	
	if particle_system != null:
		particle_system.one_shot = !is_continuous
		particle_system.emitting = true

func set_note_miss(note_index) -> void:
	var note : Note2D = notes_parent.get_child(note_index)
	note.display_mistake()

func set_continous_end() -> void:
	var note : Note2D = notes_parent.get_child(previous_note_index)
	note.end_hit()
	
	if particle_system != null:
		particle_system.emitting = false

func set_track_notes(times) -> void:
	if times == null:
		return
	
	track_times = times
	
	for time_info in track_times:
		var note = load(default_note_2d_path)
		var note_instance : Note2D = note.instantiate()
		notes_parent.add_child(note_instance)
		note_instance.position = - time_info.time * track_velocity
		note_instance.visible = visibility_start_time == -1
		note_instance.create_note(time_info.duration, absolute_velocity)
		visible_area_node_index = 0 if visibility_start_time != -1 else -1
		invisible_area_node_index = visible_area_node_index
		#when implemented, add method to add continuous commands

func set_track_props(velocity : float, time_before_view : float, time_afer_view : float) -> void:
	absolute_velocity = velocity
	track_velocity = absolute_velocity * notes_direction
	
	visibility_start_time = time_before_view
	visibility_end_time = time_afer_view
