extends Control
class_name UISongSelection

func _on_quit_button_pressed() -> void:
	Manager.quit_game()

func _on_settings_button_pressed() -> void:
	Manager.go_to_settings_scene()
