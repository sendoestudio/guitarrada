extends Control
class_name UIResults

@onready var song_title_label : Label  = $ColorRect/SongSelectedControl/VBoxContainer/TitleLabel
@onready var song_artist_label : Label  = $ColorRect/SongSelectedControl/VBoxContainer/ArtistLabel



func _on_again_button_pressed() -> void:
	Manager.go_to_stage_scene()


func _on_difficulty_button_pressed() -> void:
	Manager.go_to_difficulty_selection_scene()


func _on_song_selection_button_pressed() -> void:
	Manager.go_to_song_selection_scene()
