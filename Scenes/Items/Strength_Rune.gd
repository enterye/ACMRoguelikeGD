extends "res://Scenes/Items/Rune_Default.gd"

func get_reference():
	self_reference = load("res://Scenes/Items/strength_rune.tscn")
	return self_reference

func apply_effect():
	var player = get_parent().get_parent()
	player.damage_delt = player.damage_delt * 1.5
