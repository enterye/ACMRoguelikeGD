extends "res://Scenes/Items/Rune_Default.gd"

var texture: Texture2D = load("res://ART/ITEMS/ARMOR/IronArmor.png")

func get_reference():
	self_reference = load("res://Scenes/Items/armor_set_1.tscn")
	return self_reference

func apply_effect():
	var player = get_parent().get_parent()
	player.set_texture(texture)
	
