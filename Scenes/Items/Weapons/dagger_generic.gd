extends "res://Scenes/Items/Weapons/weapon_generic.gd"

var attacks = ["Attack1", "Attack2", "Attack3", "loop_attack"]

var animation_speed = 1
var default_damage = 30

func _ready():
	$WeaponAnimation.speed_scale = animation_speed

func attack():
	$WeaponAnimation.speed_scale = animation_speed
	match(attack_state):
		"idle":
			$WeaponAnimation.play("Attack1")
		"aip":
			pass
		"aw":
			$WeaponAnimation.play(attacks[attack_index])
		"resetting":
			pass

