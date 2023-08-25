extends StaticBody2D

var speed_rune = preload("res://Scenes/Items/speed_rune.tscn")
var strength_rune = preload("res://Scenes/Items/speed_rune.tscn")
var rate_rune = preload("res://Scenes/Items/rate_rune.tscn")

var possible_items = [speed_rune, strength_rune, rate_rune]

var spawned = false

var item_node = get_parent()

func _ready():
	item_node = get_owner().find_child("Items")

func spawn_item():
	spawned = true
	var rand = randi() % possible_items.size()
	var ref = possible_items[rand]
	var item = ref.instantiate()
	print(item)
	item.position = global_position - Vector2(0, -16)
	item_node.call_deferred("add_child",item)

func _on_detection_area_body_entered(_body):
	$ChestSprite.frame = 1
	if spawned == false:
		spawn_item()
