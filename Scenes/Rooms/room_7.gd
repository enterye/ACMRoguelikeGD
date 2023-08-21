extends "res://Scenes/Rooms/default_room.gd"

func _ready():
	up_socket = OPEN
	down_socket = OPEN
	right_socket = OPEN
	left_socket = CLOSED
	sockets = [right_socket, down_socket, left_socket, up_socket]
	treasure_room = false
