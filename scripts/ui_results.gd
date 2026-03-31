extends Control
class_name UIResults

@onready var song_title_label : Label  = $ColorRect/SongSelectedControl/VBoxContainer/TitleLabel
@onready var song_artist_label : Label  = $ColorRect/SongSelectedControl/VBoxContainer/ArtistLabel


func _ready() -> void:
	var info = Manager.current_map_info
	
	if "title" in info:
		song_title_label.text = info.title
	
	if "artist" in info:
		song_artist_label.text = info.artist

func _on_again_button_pressed() -> void:
	Manager.go_to_stage_scene()


func _on_difficulty_button_pressed() -> void:
	Manager.go_to_difficulty_selection_scene()


func _on_song_selection_button_pressed() -> void:
	Manager.go_to_song_selection_scene()
