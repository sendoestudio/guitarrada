extends Node

@export var player : Player



func _process(delta: float) -> void:
	var final_text = "Current score " + str(player.get_current_score())
	final_text += "\nMultiplier " + str(player.get_current_multiplier())
	final_text += "\nCombo " + str(player.get_current_combo())
	
	self.text = final_text
