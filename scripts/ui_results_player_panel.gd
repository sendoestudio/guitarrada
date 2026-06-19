extends MarginContainer
class_name UIResultsPlayerPanel

@export var player_index = -1

@onready var placement_label = $VBoxContainer/PlacementLabel
@onready var player_code_label = $VBoxContainer/PlayerCodeLabel
@onready var score_label = $VBoxContainer/ScoreLabel

@onready var max_combo_value_label = $VBoxContainer/AddInfoVBoxContainer/MaxComboHBoxContainer/ValueLabel
@onready var perfects_value_label = $VBoxContainer/AddInfoVBoxContainer/PerfectsHBoxContainer/ValueLabel
@onready var goods_value_label = $VBoxContainer/AddInfoVBoxContainer/GoodsHBoxContainer/ValueLabel
@onready var average_value_label = $VBoxContainer/AddInfoVBoxContainer/AveragesHBoxContainer/ValueLabel
@onready var mistakes_value_label = $VBoxContainer/AddInfoVBoxContainer/MistakesHBoxContainer/ValueLabel
@onready var overclicks_value_label = $VBoxContainer/AddInfoVBoxContainer/OverclicksHBoxContainer/ValueLabel

func _ready() -> void:
	if player_index == -1 || player_index >= Manager.player_amount:
		visible = false
		return
	
	if Manager.current_player_stats[player_index] == null:
		visible = false
		return
	
	var player_placement = Manager.get_player_placement(player_index)
	placement_label.visible = player_placement != -1
	placement_label.text = get_placement_name(player_placement)
	
	player_code_label.text = "Player " + str(1 + player_index)
	var stats : ResultStats = Manager.current_player_stats[player_index]
	
	score_label.text = str(stats.score)
	max_combo_value_label.text = str(stats.max_combo)
	perfects_value_label.text = str(stats.perfect_hits)
	goods_value_label.text = str(stats.good_hits)
	average_value_label.text = str(stats.average_hits)
	mistakes_value_label.text = str(stats.mistakes)
	overclicks_value_label.text = str(stats.overclicks)

func get_placement_name(pos : int) -> String:
	if pos < 0:
		return ""
	
	pos += 1
	var response : String
	var pos_text = str(pos)
	
	if pos_text.ends_with("1"):
		response = pos_text + "st "
	elif pos_text.ends_with("2"):
		response = pos_text + "nd "
	elif pos_text.ends_with("3"):
		response = pos_text + "rd "
	else:
		response = pos_text + "th "
	
	response += "Place"
	
	return response
