extends Control
class_name LevelEditorTrack

var _level_editor : LevelEditor
var _inner_track_index : int

const empty_button_path : String = "res://defaults/level_editor_track_empty_button.tscn"


#@export var track_index = -1

@onready var track_label : Label = $TrackLabel
@onready var buttons_container : HBoxContainer = $HBoxContainer

func set_level_editor(editor, index):
	_level_editor = editor
	_inner_track_index = index
	track_label.text = "Track " + str(_inner_track_index + 1)

func _ready() -> void:
	clean_track()
	
	#var overbeats_test : Array[float] = [
		#0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5
		#]
	#var times_test : Array[float] = [
		#0.5, 1.25
	#]
	#
	#create_track(overbeats_test, times_test)

func create_track(beats, times):
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
		
		var inner_beat_factor = (interval_to_next / interval_beats_amount)
		for i in interval_beats_amount:
			var inner_button_instance : LevelEditorTrackEmptyButton = new_button.instantiate()
			buttons_container.add_child(inner_button_instance)
			inner_button_instance.setup(self, beats[beat_index] + (inner_beat_factor) * (i + 1))
			inner_button_instance.custom_minimum_size = Vector2(25.0, 45.0)
		
func clean_track():
	for i in buttons_container.get_child_count():
		var child = buttons_container.get_child(0)
		buttons_container.remove_child(child)
		child.queue_free()

func create_note(time : float, pos : Vector2):
	#pos.x += 140.0
	_level_editor.create_note_at_spot(pos, _inner_track_index, time, -1, false)
