extends "res://Scenes/Items/Weapons/weapon_generic.gd"

var attacks = ["Attack1", "Attack2", "Attack3"]

const ANIMATION_SPEED = 1.5
const DEFAULT_DAMAGE = 30

func _ready():
	$WeaponAnimation.speed_scale = ANIMATION_SPEED

func attack():
	$WeaponAnimation.speed_scale = ANIMATION_SPEED
	match(attack_state):
		"idle":
			$WeaponAnimation.play("Attack1")
		"aip":
			pass
		"aw":
			$WeaponAnimation.play(attacks[attack_index])
		"resetting":
			pass

