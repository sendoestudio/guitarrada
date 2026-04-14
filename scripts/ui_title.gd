extends Control
class_name UITitle

@onready var version_label : Label = $VersionLabel

func _ready() -> void:
	version_label.text = ProjectSettings.get_setting("application/config/version")

func _on_start_button_pressed() -> void:
	Manager.go_to_song_selection_scene()
