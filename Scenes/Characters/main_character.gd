extends CharacterBody2D

const SPEED = 100

var direction: Vector2
var fire_direction: Vector2
var pos

var vert_fire_dir
var horz_fire_dir

var can_fire = true
var firing = false

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
	velocity = direction * SPEED
	
	#controls sprite animation
	if(direction):
		$AnimationPlayer.play("walk")
	else:
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
	print("player took damage")
