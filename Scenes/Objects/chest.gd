extends StaticBody2D

var possible_items = []

func spawn_item():
	pass

func _on_detection_area_body_entered(_body):
	$ChestSprite.frame = 1
	spawn_item()
