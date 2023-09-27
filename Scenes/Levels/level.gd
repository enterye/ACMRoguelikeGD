extends Node2D

#preloads the default_projectile node in preperation for instantiation
var projectile_ref = preload("res://Scenes/Projectiles/default_projectile.tscn")
var dash_ghost_ref = preload("res://Scenes/Particles/dash_ghost.tscn") 

#spawn player projectile
#signal recieved from main_character node, which pases the direction of fire
#and players current position
func _on_main_character_fire_projectile(fire_dir, pos):
	#instantiates the projectile
	var projectile = projectile_ref.instantiate() as Area2D
	
	#sets the projectiles important properties
	projectile.direction = fire_dir
	projectile.position = pos
	projectile.rotation = fire_dir.angle()
	
	#adds projectile to scene
	$Projectiles.add_child(projectile)


func _on_main_character_spawn_dash_ghost():
	var dg_object = dash_ghost_ref.instantiate()
	dg_object.set_sprite($MainCharacter.sprite)
	dg_object.global_position = $MainCharacter/CharacterSprite.get_global_position()
	$SubPlayerParticles.add_child(dg_object)
