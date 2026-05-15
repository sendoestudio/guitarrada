extends Node
class_name ComboModifier

@export var minimum_combo : int = -1
@export var minimum_multiplier : int = -1
@export var minimum_player_amount : int = -1
@export var players : Array[Player] = []

@export var effect_animation_player : AnimationPlayer
@export var starting_animation_name : String
@export var positive_combo_animation_name : String
@export var negative_combo_animation_name : String

var was_on_enhanced_state : bool = false

func _ready() -> void:
	for player in players:
		if minimum_combo > -1:
			player.combo_updated.connect(verify_players)
		if minimum_multiplier > -1:
			player.multiplier_updated.connect(verify_players)
	
	if minimum_player_amount <= -1:
		minimum_player_amount = players.size()
		
	was_on_enhanced_state = false
	if effect_animation_player.has_animation(starting_animation_name):
		effect_animation_player.play(starting_animation_name)

func verify_players() -> void:
	if effect_animation_player == null:
		return
	
	var verifying_players : Array[Player]
	verifying_players = players.filter(func(a) : return a.is_working && (a.current_combo >= minimum_combo && a.current_multiplier >= minimum_multiplier))
	if verifying_players.size() >= minimum_player_amount:
		if !was_on_enhanced_state:
			was_on_enhanced_state = true
			if effect_animation_player.has_animation(positive_combo_animation_name):
				effect_animation_player.play(positive_combo_animation_name)
	else:
		if was_on_enhanced_state:
			was_on_enhanced_state = false
			if effect_animation_player.has_animation(negative_combo_animation_name):
				effect_animation_player.play(negative_combo_animation_name)
	
