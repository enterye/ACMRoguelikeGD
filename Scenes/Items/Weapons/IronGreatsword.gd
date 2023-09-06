extends "res://Scenes/Items/Weapons/weapon_generic.gd"

#possible states are idle, aip (attack in progress), aw (attack window), and resetting
@export var attack_state = "idle"
var attacks = ["Attack1", "Attack2"]
@export var attack_index = 0

const ANIMATION_SPEED = 0.6
const DEFAULT_DAMAGE = 100

func _ready():
	$WeaponAnimation.speed_scale = ANIMATION_SPEED

func attack():
	match(attack_state):
		"idle":
			$WeaponAnimation.play("Attack1")
		"aip":
			pass
		"aw":
			$WeaponAnimation.play(attacks[attack_index])
		"resetting":
			pass

func walk():
	$WeaponAnimation.play("walk")

func idle():
	$WeaponAnimation.play("RESET")
