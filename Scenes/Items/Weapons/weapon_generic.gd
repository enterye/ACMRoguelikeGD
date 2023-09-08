extends Node2D

#possible states are idle, aip (attack in progress), aw (attack window), and resetting
@export var attack_state = "idle"
@export var attack_index = 0

func flip():
	scale = Vector2(1, -1)
	
func unflip():
	scale = Vector2(1, 1)
	
func walk():
	if attack_state == "idle":
		$WeaponAnimation.speed_scale = 0.8
		$WeaponAnimation.play("walk")

func idle():
	if attack_state == "idle":
		$WeaponAnimation.play("RESET")
