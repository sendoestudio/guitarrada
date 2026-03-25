extends Control
class_name  UIDifficulty

@onready var song_title_label : Label = $SongSelectedControl/VBoxContainer/TitleLabel
@onready var song_artist_label : Label = $SongSelectedControl/VBoxContainer/ArtistLabel

@onready var play_button : Button = $PlayButton


func _on_play_button_pressed() -> void:
	pass # Replace with function body.
	
	Manager.go_to_stage_scene()
