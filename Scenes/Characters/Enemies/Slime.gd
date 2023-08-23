extends CharacterBody2D

var state = "idle"

var health = 100

var main_character

@export var can_jump = true
@export var jumping = false

func _ready():
	$SlimeSprite.visible = true
	$Shadow.visible = true
	$Collisions.disabled = false
	$Hurtbox/CollisionShape2D.disabled = false
	$Death.emitting = false

func _process(_delta):
	match(state):
		"idle":
			pass
		"attack":
			$AnimationPlayer.play("jump")
		"dead":
			pass
			
	move_and_slide()

func _on_hitbox_area_entered(_area):
	health -= 50
	print(health)
	if health < 1:
		die() 

func die():
	nullify_velocity()
	$AnimationPlayer.play("die")
	state = "dead"

func nullify_velocity():
	velocity = Vector2.ZERO

func jump():
	velocity = (main_character.global_position - global_position).normalized() * 75

func stop_jump():
	velocity = velocity * .25

func _on_detection_area_body_entered(body):
	main_character = body
	state = "attack"
