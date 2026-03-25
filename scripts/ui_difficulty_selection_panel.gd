extends MarginContainer

@export var player_index : int = -1

@onready var player_code_label : Label = $VBoxContainer/PlayerCodeLabel


@onready var selection_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer
@onready var easy_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/EasyButton
@onready var medium_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/MediumButton
@onready var hard_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/HardButton
@onready var expert_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/ExpertButton

@onready var confirmed_vbox_container : VBoxContainer = $VBoxContainer/ConfirmedVBoxContainer
@onready var confirmed_diff_label : Label = $VBoxContainer/ConfirmedVBoxContainer/DifficultyLabel


func _on_easy_button_pressed() -> void:
	pass # Replace with function body.


func _on_medium_button_pressed() -> void:
	pass # Replace with function body.


func _on_hard_button_pressed() -> void:
	pass # Replace with function body.


func _on_expert_button_pressed() -> void:
	pass # Replace with function body.


func _on_change_button_pressed() -> void:
	pass # Replace with function body.
