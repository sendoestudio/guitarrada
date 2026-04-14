extends TextureRect
class_name LevelEditorTrackNoteButton

@onready var duration_background_colorrect = $BGColorRect
@onready var duration_display_colorrect = $DurationColorRect

const duration_x_size : float = 29

var _level_editor : LevelEditor

var _time : float = -1
var _track_index : int = -1
var _duration : float = -1


func set_info(editor, time, track_index, duration):
	_level_editor = editor
	_time = time
	_track_index = track_index
	_duration = duration

func _on_button_pressed() -> void:
	_level_editor.select_note(self)

func set_duration(duration):
	_duration = duration

func set_duration_display(percentage : float) -> void:
	duration_background_colorrect.visible = percentage > 0
	duration_display_colorrect.visible = percentage > 0
	
	if percentage >= 0:
		var sub_unit = Manager.interval_beats_amount + 1
		var rounded_percentage = ceili(percentage / 0.25) * 0.25
		duration_background_colorrect.size.x = duration_x_size * rounded_percentage * sub_unit
		duration_display_colorrect.size.x = duration_x_size * percentage * sub_unit
