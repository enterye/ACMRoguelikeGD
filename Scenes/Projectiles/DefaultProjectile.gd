extends Area2D

const SPEED = 200
var direction : Vector2

func _process(delta):
	#calculates speed. since we are using position instead of a physics function,
	#we must include delta to account for all framerates
	position += SPEED * direction * delta

#this function makes the sprite invisible, activates sparks, then destroys the node
func _on_body_entered(_body):
	$Sprite2D.visible = false
	
	#calculates the direction the sparks should rotate away from
	$Sparks.process_material.angle_min = rad_to_deg(direction.angle())
	$Sparks.process_material.angle_max = rad_to_deg(direction.angle())
	
	#stops movement so that the sparks will stay in one place
	direction = Vector2.ZERO
	$Sparks.emitting = true
	#this timer is the same length as the sparks duration; it's only here to know
	#how long to wait before destroying the node
	$SparkTimer.start()


func _on_spark_timer_timeout():
	#destroys the node
	queue_free()
