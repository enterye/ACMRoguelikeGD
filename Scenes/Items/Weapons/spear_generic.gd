extends "res://Scenes/Items/Weapons/weapon_generic.gd"

var attacks = ["Attack1", "Attack2", "Attackloop"]

var animation_speed = 0.9
var default_damage = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	$WeaponAnimation.speed_scale = animation_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
