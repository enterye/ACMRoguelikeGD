extends "res://Scenes/Items/Rune_Default.gd"

func get_reference():
	self_reference = load("res://Scenes/Items/speed_rune.tscn")
	return self_reference

func apply_effect():
	var player = get_parent().get_parent()
	print("effect application")
	player.speed = player.speed * 1.5
