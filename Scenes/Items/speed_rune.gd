extends "res://Scenes/Items/Rune_Default.gd"

func get_reference():
	self_reference = load("res://Scenes/Items/speed_rune.tscn")
	return self_reference

func apply_effect():
	var player = get_parent().get_parent()
	player.speed = player.speed * 1.5
	player.scale_animation_speed(1.5)
