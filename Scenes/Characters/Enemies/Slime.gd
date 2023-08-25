extends CharacterBody2D

var state = "idle"

var health = 150

var main_character

@export var can_jump = true
@export var jumping = false

#resets important properties that change with the animation player and gets a reference to the player
func _ready():
	$SlimeSprite.visible = true
	$Shadow.visible = true
	$Collisions.disabled = false
	$Hurtbox/CollisionShape2D.disabled = false
	$Death.emitting = false
	$SlimeSprite.frame = 1
	$DetectionArea/CollisionShape2D.disabled = false
	$Hitbox/CollisionShape2D.disabled = false
	can_jump = true
	main_character = get_owner().find_child("MainCharacter")
	rotation = 0

func _process(_delta):
	#slime's ai state machine
	match(state):
		"idle":
			pass
		"attack":
			if can_jump:
				$AnimationPlayer.play("jump")
		"damage":
			pass
		"dead":
			pass
			
	move_and_slide()

#applies damage, changes state machine to damage, applies knockback, and kills slime if health is 
#below 1
func _on_hitbox_area_entered(area):
	if "state" != "damage":
		health -= main_character.damage_delt
		state = "damage"
		apply_knockback(area)
		$AnimationPlayer.play("knockback")
		if health < 1:
			die()

#called by animation player. returns the slime to attack state after damage state is over
func end_damage_period() -> void:
	state = "attack"

#stole this from reddit. makes the sprite flash white since you can't do that with modulation
func sprite_flash() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($SlimeSprite, "modulate:v", 1, 0.25).from(15)

#plays the death animation and stops logic from state machine
func die() -> void:
	nullify_velocity()
	$AnimationPlayer.play("die")
	state = "dead"

#nullifies the slime's velocity, called by animation player on death
func nullify_velocity() -> void:
	velocity = Vector2.ZERO

#moves the slime towards the player in a "jumping" motion. called by the animation player
func jump() -> void:
	velocity = (main_character.global_position - global_position).normalized() * 75

#takes the source of incoming damage and applies knockback in the opposite direction
func apply_knockback(area) -> void:
	velocity = (global_position - area.global_position).normalized() * 20

#helper function for the animation player, bring the slime's velocity down smoothly
func stop_jump() -> void:
	velocity = velocity * .15

#changes the slimes state from "idle" to "attack"
func _on_detection_area_body_entered(_body) -> void:
	state = "attack"
