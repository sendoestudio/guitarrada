extends Control
class_name LevelEditorBeatMarker

@onready var background_colorrect : ColorRect = $ColorRect
@onready var beat_label : Label = $Label

func setup(beat_index : int, inner_pos_index : int, is_strong_beat : bool = false):
	beat_label.text = str(beat_index) if inner_pos_index == 0 else ""
	
	if inner_pos_index == 0:
		background_colorrect.color.a = 0.75 if is_strong_beat else 0.5
	else:
		background_colorrect.color.a = 0.2 if (inner_pos_index % 2 == 0) else 0.05
