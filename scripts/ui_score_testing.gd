extends Node

@export var level : Node3D



func _process(delta: float) -> void:
	var final_text = "Current score " + str(level.current_score)
	final_text += "\nMultiplier " + str(level.current_multiplier)
	final_text += "\nCombo " + str(level.current_combo)
	
	self.text = final_text
