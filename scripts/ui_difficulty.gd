extends Control
class_name  UIDifficulty

@onready var song_title_label : Label = $SongSelectedControl/VBoxContainer/TitleLabel
@onready var song_artist_label : Label = $SongSelectedControl/VBoxContainer/ArtistLabel

@onready var play_button : Button = $PlayButton


func _ready() -> void:
	var info = Manager.current_map_info
	
	if "title" in info:
		song_title_label.text = info.title
	
	if "artist" in info:
		song_artist_label.text = info.artist

func _on_play_button_pressed() -> void:
	pass # Replace with function body.
	
	Manager.go_to_stage_scene()


func _on_back_button_pressed() -> void:
	Manager.go_to_song_selection_scene()
