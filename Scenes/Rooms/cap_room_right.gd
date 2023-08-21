extends "res://Scenes/Rooms/default_room.gd"

func _on_tree_entered():
	up_socket = CLOSED
	down_socket = CLOSED
	right_socket = CLOSED
	left_socket = OPEN
	sockets = [right_socket, down_socket, left_socket, up_socket]
	treasure_room = false
