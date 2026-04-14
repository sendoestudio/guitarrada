extends Button
class_name LevelEditorTrackEmptyButton

var _parent_track : LevelEditorTrack
var _representing_time : float

func setup(parent : LevelEditorTrack, time : float):
	_parent_track = parent
	_representing_time = time

func _on_pressed() -> void:
	_parent_track.create_note(_representing_time, global_position)
