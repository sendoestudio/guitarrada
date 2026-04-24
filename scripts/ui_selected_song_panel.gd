extends Control
class_name UiSelectedSongPanel

@onready var title_label = $VBoxContainer/TitleLabel
@onready var artist_label = $VBoxContainer/ArtistLabel

@onready var length_label = $VBoxContainer/AddInfoVBoxContainer/LengthHBoxContainer/ValueLabel

@export var preview_audio_stream_player : AudioStreamPlayer
@export var preview_duration : float = 10
var _preview_timer : float

func _ready() -> void:
	visible = false
	_preview_timer = -1

func _process(delta: float) -> void:
	if _preview_timer > 0:
		_preview_timer -= delta
		if _preview_timer <= 0:
			preview_audio_stream_player.stop()

func _on_play_button_pressed() -> void:
	Manager.go_to_difficulty_selection_scene()


func _on_v_box_container_index_changed() -> void:
	var info = Manager.current_map_info
	
	visible = info != {}
	
	if info == {}:
		return
	
	title_label.text = info.title
	artist_label.text = info.artist
	
	var length_minutes = floori(info.length / 60.0)
	var length_seconds = fmod(info.length, 60)
	var length_string = "{mins}:{secs}".format({"mins" : length_minutes, "secs" : "%02d" % length_seconds})
	length_label.text = length_string
	
	if preview_audio_stream_player != null:
		if preview_duration > 0:
			if !FileAccess.file_exists(info.audio):
				return
			var audio = load(info.audio)
			preview_audio_stream_player.stream = audio
			preview_audio_stream_player.play(info.audio_preview_start)
			_preview_timer = preview_duration
