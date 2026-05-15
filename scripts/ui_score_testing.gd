extends Node

@export var player : Player

func _init() -> void:
	self.text = ""
	
func _ready() -> void:
	if player != null:
		player.score_updated.connect(update_score)
	else:
		self.text = "no player referenced"
#func _process(delta: float) -> void:
	#if player != null && player.is_working:
		#var final_text = "Player " + str(player.player_index + 1)
		#final_text += "\nCurrent score " + str(player.get_current_score())
		#final_text += "\nMultiplier " + str(player.get_current_multiplier())
		#final_text += "\nCombo " + str(player.get_current_combo())
		#
		#self.text = final_text
	#else:
		#self.text = ""

func update_score(player_index : int, score : int, multiplier : int, combo : int) -> void:
	var final_text = "Player " + str(player_index + 1)
	final_text += "\nCurrent score " + str(score)
	final_text += "\nMultiplier " + str(multiplier)
	final_text += "\nCombo " + str(combo)
	
	self.text = final_text
