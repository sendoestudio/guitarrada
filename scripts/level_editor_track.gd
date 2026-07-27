extends Control
class_name LevelEditorTrack

var _level_editor : LevelEditor
var _inner_track_index : int

const empty_button_path : String = "res://defaults/level_editor_track_empty_button.tscn"

@export var track_label : Label
@export var buttons_container : HBoxContainer

func set_level_editor(editor, index):
	_level_editor = editor
	_inner_track_index = index
	track_label.text = "Track " + str(_inner_track_index + 1)

func _ready() -> void:
	clean_track()

func create_track(beats : Array[float]):
	var interval_beats_amount = Manager.interval_beats_amount
	var new_button = load(empty_button_path)
	
	for beat_index in beats.size():
		var button_instance : LevelEditorTrackEmptyButton = new_button.instantiate()
		buttons_container.add_child(button_instance)
		button_instance.setup(self, beats[beat_index])
		button_instance.custom_minimum_size = Vector2(25.0, 45.0)
		
		if interval_beats_amount <= 0:
			continue
		
		var interval_to_next = -1
		if (beat_index + 1) < beats.size():
			interval_to_next = beats[beat_index + 1] - beats[beat_index]
		else:
			break
		
		if interval_beats_amount == 0:
			return
		
		var inner_beat_factor = (interval_to_next / (interval_beats_amount + 1))
		
		for i in interval_beats_amount:
			var inner_button_instance : LevelEditorTrackEmptyButton = new_button.instantiate()
			buttons_container.add_child(inner_button_instance)
			var current_inner_time = beats[beat_index] + (inner_beat_factor) * (i + 1)
			inner_button_instance.setup(self, current_inner_time)
			inner_button_instance.custom_minimum_size = Vector2(25.0, 45.0)
		
	
			
func create_moments(times : Array[ChartTrackTime]):
	var error = 0.0001
	for i : LevelEditorTrackEmptyButton in buttons_container.get_children():
		var veryfing_time = i._representing_time
		var found_times = times.filter(func(a) : return a.time >= veryfing_time - error && a.time <= veryfing_time + error)
		if found_times.size() == 1:
			i.create_note_from_loading(found_times[0].duration)
	
func clean_track():
	for i in buttons_container.get_child_count():
		var child = buttons_container.get_child(0)
		buttons_container.remove_child(child)
		child.queue_free()

func create_note(time : float, pos : Vector2, length :float = -1, is_load = false):
	_level_editor.create_note_at_spot(pos, _inner_track_index, time, length, is_load)

	
