extends Area2D

var self_reference = load("res://Scenes/Items/rune_default.tscn")

func _ready():
	$Sprite2D.scale = Vector2(1, 1)
	$Sprite2D.visible = true
	$Shadow.visible = true

func inventory_version():
	visible = false
	$CollisionShape2D.disabled = true


func destroy_rune():
	$AnimationPlayer.play("on_pickup")
	
func apply_effect():
	var player = get_parent().get_parent()
	player.speed = player.speed * 1.5
