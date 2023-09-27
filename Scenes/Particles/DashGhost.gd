extends Sprite2D

@onready var tween = get_tree().create_tween()
@onready var player = get_parent().get_parent()

func _ready():
	set_tween()
	pass

func set_tween():
	tween.set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5).from(0.7)
	tween.connect("finished", on_tween_completed)

func set_sprite(sprite):
	texture = sprite.texture
	vframes = sprite.vframes
	hframes = sprite.hframes
	frame = sprite.frame
	flip_h = sprite.flip_h
	rotation = sprite.rotation

func on_tween_completed():
	queue_free()
