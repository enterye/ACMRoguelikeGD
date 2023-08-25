extends "res://Scenes/Items/Rune_Default.gd"

func get_reference():
	self_reference = load("res://Scenes/Items/Rate_Rune.tscn")
	return self_reference

func apply_effect():
	var player = get_parent().get_parent()
	var fire_rate = player.fire_rate
	fire_rate = fire_rate * 0.5
	player.set_fire_rate(fire_rate)
