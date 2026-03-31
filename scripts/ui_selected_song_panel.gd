extends Control
class_name UiSelectedSongPanel

@onready var title_label = $VBoxContainer/TitleLabel
@onready var artist_label = $VBoxContainer/ArtistLabel
@onready var thumbail_texture_rect = $VBoxContainer/Thumbnail/TextureRect

@onready var bpm_label = $VBoxContainer/AddInfoVBoxContainer/BPMHBoxContainer/ValueLabel
@onready var length_label = $VBoxContainer/AddInfoVBoxContainer/LengthHBoxContainer/ValueLabel

@onready var preview_audio_stream_player = AudioStreamPlayer

func _ready() -> void:
	visible = false

func _on_play_button_pressed() -> void:
	Manager.go_to_difficulty_selection_scene()


func _on_v_box_container_index_changed() -> void:
	var info = Manager.current_map_info
	
	visible = info != {}
	
	if info == {}:
		return
	
	title_label.text = info.title
	artist_label.text = info.artist
	
	#thumbnail tbi
	
	bpm_label.text = str(info.bpm)
	
	var length_minutes = floori(info.length / 60.0)
	var length_seconds = fmod(info.length, 60)
	var length_string = "{mins}:{secs}".format({"mins" : length_minutes, "secs" : "%02d" % length_seconds})
	length_label.text = length_string
