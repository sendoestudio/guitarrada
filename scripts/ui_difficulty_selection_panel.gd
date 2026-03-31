extends MarginContainer

signal player_status(index : int, is_ready : bool)

@export var player_index : int = -1

@onready var player_code_label : Label = $VBoxContainer/PlayerCodeLabel


@onready var selection_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer
@onready var easy_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/EasyButton
@onready var medium_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/MediumButton
@onready var hard_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/HardButton
@onready var expert_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/ExpertButton

@onready var confirmed_vbox_container : VBoxContainer = $VBoxContainer/ConfirmedVBoxContainer
@onready var confirmed_diff_label : Label = $VBoxContainer/ConfirmedVBoxContainer/DifficultyLabel

var charts

func _ready() -> void:
	if player_index == -1:
		visible = false
		return
	
	player_code_label.text = "Player " + str(1 + player_index)
	
	Manager.current_player_chart_path[player_index] = ""
	var info = Manager.current_map_info
	charts = info.chart_paths
	
	easy_diff_button.visible = "easy" in charts && charts.easy != null && FileAccess.file_exists(charts.easy)
	medium_diff_button.visible = "medium" in charts && charts.medium != null && FileAccess.file_exists(charts.medium)
	hard_diff_button.visible = "hard" in charts && charts.hard != null && FileAccess.file_exists(charts.hard)
	expert_diff_button.visible = "expert" in charts && charts.expert != null && FileAccess.file_exists(charts.expert)

	selection_vbox_container.visible = true
	confirmed_vbox_container.visible = false

func _on_easy_button_pressed() -> void:
	Manager.current_player_chart_path[player_index] = charts.easy
	
	selection_vbox_container.visible = false
	confirmed_vbox_container.visible = true
	player_status.emit(player_index, true)

func _on_medium_button_pressed() -> void:
	Manager.current_player_chart_path[player_index] = charts.medium


	selection_vbox_container.visible = false
	confirmed_vbox_container.visible = true
	player_status.emit(player_index, true)

func _on_hard_button_pressed() -> void:
	Manager.current_player_chart_path[player_index] = charts.hard

	
	selection_vbox_container.visible = false
	confirmed_vbox_container.visible = true
	player_status.emit(player_index, true)

func _on_expert_button_pressed() -> void:
	Manager.current_player_chart_path[player_index] = charts.expert
	
	selection_vbox_container.visible = false
	confirmed_vbox_container.visible = true
	player_status.emit(player_index, true)

func _on_change_button_pressed() -> void:
	
	selection_vbox_container.visible = true
	confirmed_vbox_container.visible = false
	player_status.emit(player_index, false)
