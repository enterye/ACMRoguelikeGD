extends CharacterBody2D

var speed = 100
var damage_delt = 50

var direction: Vector2
var fire_direction: Vector2
var pos

var health = 100

var fire_rate = 0.5

var vert_fire_dir
var horz_fire_dir

var can_fire = true
var firing = false

var armorset0: Texture2D = load("res://ART/CHARACTERS/MainCharacter2.png")

#signal to the level that the player wants to fire a projectile.
#this signal passes the direction and position of the player
signal fire_projectile(fire_dir, pos, rot)

#gets the door the player is standing in
func get_overlapping_areas():
	if($DoorDetector.has_overlapping_areas()):
		return $DoorDetector.get_overlapping_areas()[0]
	else:
		return null

func _process(_delta):
	#get directional input and calculate velocity
	direction = Input.get_vector("move_left","move_right","move_up","move_down").normalized()
	
	#controls sprite animation
	if(direction):
		velocity = direction * speed
		$AnimationPlayer.play("walk")
	else:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("RESET")
		$CharacterSprite.frame = 2 #frame 2 is idle stance
	
	#decides the initial firing direction before deciding which one to use below
	horz_fire_dir = Input.get_axis("fire_left","fire_right")
	vert_fire_dir = Input.get_axis("fire_up","fire_down")
	
	#flips the sprite based on movement velocity
	if(velocity.x < 0):
		$CharacterSprite.flip_h = true
		$WeaponSpawn.position.x = -6
	elif(velocity.x > 0):
		$CharacterSprite.flip_h = false
		$WeaponSpawn.position.x = 6
	
	#get input for firing as well as direction
	#having two axis as apposed to an if-else setup makes it so that if the player
	#changes direction mid-fire they will still fire instead of stopping.
	#another advantage of the two axis setup is that when the player pushes
	#two opposing directions at once, firing will cease. horizontal firing always
	#takes precedence to vertical firing. this is sort of an arbitrary decision,
	#but one direction has to take precedence
	if(horz_fire_dir):
		fire_direction = Vector2(horz_fire_dir, 0)
		firing = true
	elif(vert_fire_dir):
		fire_direction =  Vector2(0, vert_fire_dir)
		firing = true
	else:
		firing = false
	
	#emits signal to fire projectile if the firerate timer isn't currently ticking
	#also starts the firerate timer
	if firing and can_fire:
		$FireRate.start()
		can_fire = false
		
		pos = $WeaponSpawn.global_position
		
		fire_projectile.emit(fire_direction, pos)
	
	#moves the player based on veloctiy
	move_and_slide()

func _on_fire_rate_timeout():
	can_fire = true


func _on_hitbox_area_entered(_area):
	health -= 10
	print(health)
	if health < 1:
		print("DEATH")

func _on_item_pick_up_zone_area_entered(area):
	print(area)
	var rune = get_node(area.get_path()).get_reference().instantiate()
	area.destroy_rune()
	rune.inventory_version()
	$Items.call_deferred("add_child",rune)

	print(rune)

func set_fire_rate(new_rate):
	fire_rate = new_rate
	$FireRate.wait_time = fire_rate

func scale_animation_speed(speedscale):
	$AnimationPlayer.speed_scale = $AnimationPlayer.speed_scale * speedscale

func set_texture(texture):
	$CharacterSprite.set_texture(texture)

#when an item is added to the item tree
func _on_items_child_entered_tree(node):
	node.apply_effect()
