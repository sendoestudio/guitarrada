extends MarginContainer

signal player_status(index : int, is_ready : bool)

@export var player_index : int = -1

@onready var player_code_label : Label = $VBoxContainer/PlayerCodeLabel


@onready var selection_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer
#@onready var easy_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/EasyButton
#@onready var medium_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/MediumButton
#@onready var hard_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/HardButton
#@onready var expert_diff_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/ExpertButton

@onready var difficulties_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer
@onready var example_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/ExampleButton

@onready var confirmed_vbox_container : VBoxContainer = $VBoxContainer/ConfirmedVBoxContainer
@onready var confirmed_diff_label : Label = $VBoxContainer/ConfirmedVBoxContainer/DifficultyLabel

var charts

func _ready() -> void:
	if player_index == -1:
		visible = false
		return
	
	player_code_label.text = "Player " + str(1 + player_index)
	
	Manager.current_player_chart_difficulty[player_index] = ""
	var info = Manager.current_map_info
	charts = info.charts
	
	example_button.visible = false
	
	for difficulty_index in Manager.difficulties:
		var difficulty_name : String = Manager.difficulties.get(difficulty_index)
		if difficulty_name in charts && charts[difficulty_name] != null && "tracks" in charts[difficulty_name] && charts[difficulty_name].tracks.size() > 0:
			var new_button : Button = Button.new()
			new_button.theme = example_button.theme
			new_button.text = difficulty_name.capitalize()
			new_button.pressed.connect(_set_player.bind(difficulty_name))
			new_button.visible = true
			difficulties_vbox_container.add_child(new_button)
	
	#easy_diff_button.visible = "easy" in charts && charts.easy != null && "tracks" in charts.easy && charts.easy.tracks.size() > 0
	#medium_diff_button.visible = "medium" in charts && charts.medium != null && "tracks" in charts.medium && charts.medium.tracks.size() > 0
	#hard_diff_button.visible = "hard" in charts && charts.hard != null && "tracks" in charts.hard && charts.hard.tracks.size() > 0
	#expert_diff_button.visible = "expert" in charts && charts.expert != null && "tracks" in charts.expert && charts.expert.tracks.size() > 0

	selection_vbox_container.visible = true
	confirmed_vbox_container.visible = false

func _on_easy_button_pressed() -> void:
	_set_player("easy")
	#Manager.current_player_chart_path[player_index] = "easy"
	#
	#selection_vbox_container.visible = false
	#confirmed_vbox_container.visible = true
	#player_status.emit(player_index, true)

func _on_medium_button_pressed() -> void:
	_set_player("medium")
	#Manager.current_player_chart_path[player_index] = "medium"
#
#
	#selection_vbox_container.visible = false
	#confirmed_vbox_container.visible = true
	#player_status.emit(player_index, true)

func _on_hard_button_pressed() -> void:
	_set_player("hard")
	#Manager.current_player_chart_path[player_index] = "hard"
#
	#
	#selection_vbox_container.visible = false
	#confirmed_vbox_container.visible = true
	#player_status.emit(player_index, true)

func _on_expert_button_pressed() -> void:
	#Manager.current_player_chart_path[player_index] = "expert"
	_set_player("expert")
	
	
func _set_player(difficulty_chart : String):
	Manager.current_player_chart_difficulty[player_index] = difficulty_chart
	confirmed_diff_label.text = difficulty_chart.capitalize()
	
	selection_vbox_container.visible = false
	confirmed_vbox_container.visible = true
	player_status.emit(player_index, true)

func _on_change_button_pressed() -> void:
	
	selection_vbox_container.visible = true
	confirmed_vbox_container.visible = false
	player_status.emit(player_index, false)
