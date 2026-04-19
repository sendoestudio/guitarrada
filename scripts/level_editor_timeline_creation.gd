extends Control
class_name LevelEditorTimelineCreation

@onready var selection_vboxcontainer : VBoxContainer = $VBoxContainer
@onready var simple_control : LevelEditorTimelineCreationSimple = $Simple
@onready var complex_control : LevelEditorComplexTimeline = $Complex
@onready var manual_control : LevelEditorManualTimeline = $Manual
var _level_editor : LevelEditor

func set_level_editor(level_editor : LevelEditor) -> void:
	_level_editor = level_editor
	simple_control.set_timeline_creation_handler(self)
	complex_control.set_timeline_creation_handler(self)
	manual_control.set_timeline_creation_handler(self)

func reset() -> void:
	_set_visibility(0)

func _on_simple_timeline_button_pressed() -> void:
	_set_visibility(1)
	simple_control.clean_fields()

func _on_complex_timeline_button_pressed() -> void:
	_set_visibility(2)
	complex_control.reset()

func _on_manual_timeline_button_pressed() -> void:
	_set_visibility(3)
	manual_control.clean_fields()

func _set_visibility(index : int) -> void:
	selection_vboxcontainer.visible = index == 0
	simple_control.visible = index == 1
	complex_control.visible = index == 2
	manual_control.visible = index == 3

func set_length(length : float):
	_level_editor.set_length(length)

func build_simple_timeline(bpm_interval : LevelEditorBpmInterval):
	var interval : Array[LevelEditorBpmInterval] = [ bpm_interval ]
	_level_editor.create_timeline_from_bpm_intervals(interval)

func build_complex_timeline(bpm_intervals : Array[LevelEditorBpmInterval]):
	_level_editor.create_timeline_from_bpm_intervals(bpm_intervals)

func build_manual_timeline(length : float, beats_string : Array[float], strong_beats_string : Array[float],):
	_level_editor.create_timeline_from_lists(length, beats_string, strong_beats_string)
