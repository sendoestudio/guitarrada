extends MarginContainer

signal player_status(index : int, is_ready : bool)

@export var player_index : int = -1

@onready var player_code_label : Label = $VBoxContainer/PlayerCodeLabel


@onready var selection_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer

@onready var difficulties_vbox_container : VBoxContainer = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer
@onready var example_button : Button = $VBoxContainer/SelectionVBoxContainer/DiffsVBoxContainer/ExampleButton

@onready var confirmed_vbox_container : VBoxContainer = $VBoxContainer/ConfirmedVBoxContainer
@onready var confirmed_diff_label : Label = $VBoxContainer/ConfirmedVBoxContainer/DifficultyLabel

var charts

func _ready() -> void:
	if player_index == -1 || player_index >=  Manager.player_amount:
		visible = false
		return
	
	player_code_label.text = "Player " + str(1 + player_index)
	
	Manager.current_player_chart_difficulty[player_index] = ""
	var info = Manager.current_map_info
	if info == null || info == {}:
		info = Manager.load_json_file(Manager.testing_level_file_path)
	
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
	
	selection_vbox_container.visible = true
	confirmed_vbox_container.visible = false
	
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
