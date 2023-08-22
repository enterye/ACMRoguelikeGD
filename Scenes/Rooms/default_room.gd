extends Node2D

signal room_entered(room, cell)

#these are for the sockets
const OPEN = 1
const CLOSED = 0

var treasure_room: bool
#this is so the dungeon controller knows where the player is
var contains_player: bool
#this is so we don't spawn things more than once
var player_visited: bool = false

#this is for the wave function collapse
var right_neighbor_valid: Array
var down_neighbor_valid: Array
var left_neighbor_valid: Array
var up_neighbor_valid: Array

#this is so the dungeon controller knows which direction a room can be generated in
var right_socket
var left_socket
var up_socket
var down_socket
var sockets = [right_socket, down_socket, left_socket, up_socket]

#these are references to the room adjacent to the current room
var right_room
var down_room
var left_room
var up_room

#reference to owner cell
var owner_cell

#references to doors
var right_door
var left_door
var up_door
var down_door

var grid_position: Vector2

var main_character

#find whatever door the player has entered and moves them accordingly
func move_player_to_room(body):
	if(body == main_character) and main_character.can_teleport:
		var door = main_character.get_overlapping_areas()
		if(door == right_door):
			main_character.position = right_room.left_door.global_position
		elif(door == left_door):
			main_character.position = left_room.right_door.global_position
		elif(door == up_door):
			main_character.position = up_room.down_door.global_position
		elif(door == down_door):
			main_character.position = down_room.up_door.global_position
		main_character.start_door_timer()

#test whether on not a cell can be placed next to this cell given a dirction
func is_compatible_with(room) -> bool:
	var first_socket
	var second_socket
	var grid_pos = grid_position
	var new_room_grid_pos = room.grid_position
	var direction = new_room_grid_pos - grid_pos
	match(direction):
		Vector2.RIGHT:
			first_socket = right_socket
			second_socket = room.left_socket
		Vector2.DOWN:
			first_socket = down_socket
			second_socket = room.up_socket
		Vector2.LEFT:
			first_socket = left_socket
			second_socket = room.right_socket
		Vector2.UP:
			first_socket = up_socket
			second_socket = room.down_socket
	if(first_socket == second_socket):
		return true
	elif(second_socket == null):
		return true
	else:
		return false

#if the player enters the room, contains_player is true
func _on_area_2d_body_entered(body):
	if(body == main_character):
		room_entered.emit(self, owner_cell)
		contains_player = true
		player_visited = true

#if the player exits the room, contains_player is false
func _on_area_2d_body_exited(body):
	if(body == main_character):
		contains_player = false

#gets a reference to player as soon as the scene enters the main tree
#also connects the player_entered signal to dungeon_controller and
#sets references for all doors
func _on_tree_entered():
	main_character = get_parent().get_parent().get_child(2)
	for door in $Doors.get_children():
		door.body_entered.connect(move_player_to_room)
	right_door = $Doors/RightDoor
	left_door = $Doors/LeftDoor
	up_door = $Doors/UpDoor
	down_door = $Doors/DownDoor
