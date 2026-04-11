extends Control

@onready var audio_latency_lineedit : LineEdit = $ColorRect/MarginContainer/VBoxContainer/AudioHBoxContainer/LineEdit
@onready var video_latency_lineedit : LineEdit = $ColorRect/MarginContainer/VBoxContainer/VideoHBoxContainer/LineEdit


var previous_audio_value = "0"
var previous_video_value = "0"

func _ready() -> void:
	audio_latency_lineedit.text = str(Manager.get_audio_latency_in_ms())
	video_latency_lineedit.text = str(Manager.get_video_latency_in_ms())


func _on_assistant_button_pressed() -> void:
	Manager.go_to_latency_assistant_scene()


func _on_back_button_pressed() -> void:
	Manager.go_to_song_selection_scene()



func _on_video_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		var proposed_value = int(new_text)
		if proposed_value >= Manager.video_latency_min_limit && proposed_value <= Manager.video_latency_max_limit:
			previous_video_value = new_text
			Manager.set_video_latency(proposed_value)
	
	video_latency_lineedit.text = previous_video_value

func _on_audio_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		var proposed_value = new_text.to_int()
		if proposed_value >= Manager.audio_latency_min_limit && proposed_value <= Manager.audio_latency_max_limit:
			previous_audio_value = new_text
			Manager.set_audio_latency(proposed_value)
	
	audio_latency_lineedit.text = previous_audio_value
