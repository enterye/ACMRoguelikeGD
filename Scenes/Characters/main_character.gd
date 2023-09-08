extends CharacterBody2D

var speed = 100
var damage_delt = 50
var dodge_speed = 2

var direction: Vector2
var pos

var health = 100

var fire_rate = 0.5

var vert_fire_dir
var horz_fire_dir

var mouse_pos
var mouse_angle

var flipped = false

var armorset0: Texture2D = load("res://ART/CHARACTERS/MainCharacter2.png")

#signal to the level that the player wants to fire a projectile.
#this signal passes the direction and position of the player
signal fire_projectile(fire_dir, pos, rot)
#signal for melee weapons
signal melee_attack

var held_weapon

var upperanglelim = -100
var loweranglelim = 100


var weapon_flipped
@export var unlocked: bool = true

func _ready():
	held_weapon = $WeaponHand.get_child(0)
	damage_delt = $WeaponHand.get_child(0).DEFAULT_DAMAGE
	melee_attack.connect(held_weapon.attack)

#gets the door the player is standing in
func get_overlapping_areas():
	if($DoorDetector.has_overlapping_areas()):
		return $DoorDetector.get_overlapping_areas()[0]
	else:
		return null

func _process(_delta):
	#get directional input, mouse position, and calculate velocity
	direction = Input.get_vector("move_left","move_right","move_up","move_down").normalized()
	mouse_pos = get_global_mouse_position()
	mouse_angle = mouse_pos - global_position
	mouse_angle = rad_to_deg(mouse_angle.angle())
	
	#controls sprite animation and player movement
	if(unlocked):
		if(Input.is_action_just_pressed("dodge") and $DodgeCooldown.is_stopped()):
			$AnimationPlayer.play("dodge")
		elif(direction):
			velocity = direction * speed
			$AnimationPlayer.play("walk")
			held_weapon.walk()
		else:
			velocity = Vector2.ZERO
			$AnimationPlayer.play("RESET")
			held_weapon.idle()
			$CharacterSprite.frame = 2 #frame 2 is idle stance
	
	#rotates melee weapon
	$WeaponHand.look_at(mouse_pos)
	
	#gets input for attacking. attack state is handled by weapon
	if Input.is_action_just_pressed("Attack"):
		melee_attack.emit()
	
	#flips the sprite based mouse pos, changes angle limits based on player direction faced
	if(mouse_angle > upperanglelim and mouse_angle < loweranglelim):
		if flipped == true:
			flipr()
			flipped = false
	else:
		if flipped == false:
			flipl()
			flipped = true
	
	#moves the player based on veloctiy
	move_and_slide()


####HELD WEAPON FLIPPING LOGIC DOES NOT WORK AS INTENDED####
#incoming fix low on list of prorities
func flipr():
	$CharacterSprite.flip_h = false
	$WeaponSpawn.position.x = 6
	$WeaponHand.position.x = -6
	upperanglelim = -100
	loweranglelim = 100
	if weapon_flipped != false:
		weapon_flipped = false
		held_weapon.flip()

func flipl():
	$CharacterSprite.flip_h = true
	$WeaponSpawn.position.x = -6
	$WeaponHand.position.x = 6
	upperanglelim = -80
	loweranglelim = 80
	if weapon_flipped != true:
		weapon_flipped = true
		held_weapon.unflip()

func dodge():
	if $DodgeCooldown.is_stopped():
		velocity = velocity * dodge_speed
		$DodgeCooldown.start()

func _on_hitbox_area_entered(_area):
	health -= 10
	print(health)
	if health < 1:
		print("DEATH")

func _on_item_pick_up_zone_area_entered(area):
	var rune = get_node(area.get_path()).get_reference().instantiate()
	area.destroy_rune()
	rune.inventory_version()
	$Items.call_deferred("add_child",rune)

func scale_animation_speed(speedscale):
	$AnimationPlayer.speed_scale = $AnimationPlayer.speed_scale * speedscale

func set_texture(texture):
	$CharacterSprite.set_texture(texture)

#when an item is added to the item tree
func _on_items_child_entered_tree(node):
	node.apply_effect()
