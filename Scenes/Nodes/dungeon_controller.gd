extends Node2D

const CELLSIZE = 500

const OPEN = 1
const CLOSED = 0

#limits for dungeon generation
const MIN_ROOMS = 8
const MAX_ROOMS = 25
const LEFT_LIMIT = -3
const RIGHT_LIMIT = 3
const UP_LIMIT = -3
const DOWN_LIMIT = 3
var treasure_room_spawned: bool = false
var room_count = 0

const GRID_CENTER = Vector2(0, 0)

var current_cell_pos = Vector2(0, 0)

var cell_with_player

#used for cycling through sockets
var direction_dictionary = {
	0 : Vector2.RIGHT,
	1 : Vector2.DOWN,
	2 : Vector2.LEFT,
	3 : Vector2.UP
}

var current_room

#array of spaces that already have rooms
var full_cells = []

#all possible rooms
var room_0 = preload("res://Scenes/Rooms/room_0.tscn") as PackedScene
var room_1 = preload("res://Scenes/Rooms/room_1.tscn") as PackedScene
var room_2 = preload("res://Scenes/Rooms/room_2.tscn") as PackedScene
var room_3 = preload("res://Scenes/Rooms/room_3.tscn") as PackedScene
var room_4 = preload("res://Scenes/Rooms/room_4.tscn") as PackedScene
var room_5 = preload("res://Scenes/Rooms/room_5.tscn") as PackedScene
var room_6 = preload("res://Scenes/Rooms/room_6.tscn") as PackedScene
var room_7 = preload("res://Scenes/Rooms/room_7.tscn") as PackedScene
var room_8 = preload("res://Scenes/Rooms/room_8.tscn") as PackedScene
var room_9 = preload("res://Scenes/Rooms/room_9.tscn") as PackedScene
var room_10 = preload("res://Scenes/Rooms/room_10.tscn") as PackedScene
var treasure_room_up = preload("res://Scenes/Rooms/treasure_room_up.tscn") as PackedScene
var treasure_room_down = preload("res://Scenes/Rooms/treasure_room_down.tscn") as PackedScene
var treasure_room_right = preload("res://Scenes/Rooms/treasure_room_right.tscn") as PackedScene
var treasure_room_left = preload("res://Scenes/Rooms/treasure_room_left.tscn") as PackedScene
var cap_room_up = preload("res://Scenes/Rooms/cap_room_up.tscn") as PackedScene
var cap_room_down = preload("res://Scenes/Rooms/cap_room_down.tscn") as PackedScene
var cap_room_right = preload("res://Scenes/Rooms/cap_room_right.tscn") as PackedScene
var cap_room_left = preload("res://Scenes/Rooms/cap_room_left.tscn") as PackedScene

#array of all possible rooms
var room_master_list = [room_0, room_1, room_2, room_3, room_4, room_5, room_6, room_7, room_8, room_9, room_10, treasure_room_up, treasure_room_down, treasure_room_right, cap_room_up, cap_room_down, cap_room_right, cap_room_left]
#array of all rooms with right enterances
var right_room_master_list = [room_0, room_1, room_3, room_6, room_8, room_9, room_10, treasure_room_right, cap_room_right]
#array of all rooms with left enterances
var left_room_master_list = [room_0, room_1, room_4, room_5, room_7, room_8, room_10, treasure_room_left, cap_room_left]
#array of all rooms with up enterances
var up_room_master_list = [room_0, room_2, room_5, room_6, room_7, room_8, room_9, treasure_room_up, cap_room_up]
#array of all rooms with down enterances
var down_room_master_list = [room_0, room_2, room_3, room_4, room_7, room_9, room_10, treasure_room_down, cap_room_down]
#array of all rooms with 3 openings
var three_entrance_master_list = [room_7, room_8, room_9, room_10]
#array of all rooms with 2 openings
var two_enterance_mast_list = [room_1, room_2, room_3, room_4, room_5, room_6]
#array of all cap rooms
var cap_room_master_list = [cap_room_up, cap_room_down, cap_room_right, cap_room_left]

#sets current room
func _on_new_room_entered(room):
	current_room = room
	current_cell_pos = room.grid_position
	#generates new rooms upon entering a room for the first time
	if(current_room.player_visited == false):
		generate_adjacent_rooms()

#given a cell, returns true if it has more than one adjacent rooms
func has_adjacent_rooms(cell: Vector2) -> bool:
	var adjacent_rooms = 0
	#if cell is blocked (does not equal -1), there is an adjacent room
	if (full_cells.find(cell + Vector2.RIGHT) != -1):
		adjacent_rooms += 1
	if (full_cells.find(cell + Vector2.LEFT) != -1):
		adjacent_rooms += 1
	if (full_cells.find(cell + Vector2.UP) != -1):
		adjacent_rooms += 1
	if (full_cells.find(cell + Vector2.DOWN) != -1):
		adjacent_rooms += 1
	if(adjacent_rooms > 1):
		return true
	else:
		return false

#creates the starting room, connects it to _on_new_room_entered, and generates adjacent rooms
func _ready():
	var room = room_0.instantiate()
	
	room.set_position(GRID_CENTER)
	room.grid_position = GRID_CENTER
	room.room_entered.connect(_on_new_room_entered)
	full_cells.append(room.grid_position)
	
	room_count += 1
	add_child(room)
	current_room = room
	generate_adjacent_rooms()

var s_direction
#iterates through room's sockets and generates a room if it is open
func generate_adjacent_rooms():
	s_direction = 0
	for socket in current_room.sockets:
		#if the socket is open
		if socket == OPEN:
			generate_room(s_direction, current_room)
			current_room.sockets[s_direction] = CLOSED
		s_direction += 1

#should get passed a room to generate from and a direction and then choose a 
#room to be generated for that direction
func generate_room(gen_direction, room):
	#sets the position of a new room
	var old_room_pos = room.grid_position
	var direction_angle = direction_dictionary.get(gen_direction)
	var new_room_grid_pos = old_room_pos + direction_angle
	var new_room_pos = new_room_grid_pos * CELLSIZE
	#generate the room based on a random number and set the references for the
	#old room and the new room, as well as all of the new room's important properties and
	#increment the number of rooms
	var rand
	var new_room
	#if the cell is full , do nothing
	if(full_cells.find(new_room_grid_pos) == -1):
		#if the room about to be spawned is on the edge or above spawn limit, make it a cap room
		if((new_room_grid_pos.x <= LEFT_LIMIT or new_room_grid_pos.x >= RIGHT_LIMIT or new_room_grid_pos.y >= DOWN_LIMIT or new_room_grid_pos.y <= UP_LIMIT) or room_count > MAX_ROOMS):
			match(s_direction):
				0: #right
					new_room = cap_room_right.instantiate()
					new_room.left_room = current_room
					room.right_room = new_room
					new_room.position = new_room_pos
					new_room.left_socket = CLOSED
				1: #down
					new_room = cap_room_down.instantiate()
					new_room.up_room = current_room
					current_room.down_room = new_room
					new_room.position = new_room_pos
					new_room.up_socket = CLOSED
				2: #left
					new_room = cap_room_left.instantiate()
					new_room.right_room = current_room
					current_room.left_room = new_room
					new_room.position = new_room_pos
					new_room.right_socket = CLOSED
				3: #up
					new_room = cap_room_up.instantiate()
					new_room.down_room = current_room
					current_room.up_room = new_room
					new_room.position = new_room_pos
					new_room.down_socket = CLOSED
		#if the room has surrounding rooms, make sure they can't have doors that lead to nowhere
		#elif(has_adjacent_rooms(new_room_grid_pos)):
		elif(false):
			#var comp_rooms = find_compatible_rooms(new_room_grid_pos)
			#new_room = comp_rooms[0].instantiate()
			match(s_direction):
				0: #right
					new_room.left_room = current_room
					room.right_room = new_room
					new_room.position = new_room_pos
					new_room.left_socket = CLOSED
				1: #down
					new_room.up_room = current_room
					current_room.down_room = new_room
					new_room.position = new_room_pos
					new_room.up_socket = CLOSED
				2: #left
					new_room.right_room = current_room
					current_room.left_room = new_room
					new_room.position = new_room_pos
					new_room.right_socket = CLOSED
				3: #up
					new_room.down_room = current_room
					current_room.up_room = new_room
					new_room.position = new_room_pos
					new_room.down_socket = CLOSED
		#if room count is greater than 5 and no treasure room has spawned, spawn a treasure room
		elif(room_count > 5 and treasure_room_spawned == false):
			match(s_direction):
				0: #right
					new_room = treasure_room_right.instantiate()
					new_room.left_room = current_room
					room.right_room = new_room
					new_room.position = new_room_pos
					new_room.left_socket = CLOSED
				1: #down
					new_room = treasure_room_down.instantiate()
					new_room.up_room = current_room
					current_room.down_room = new_room
					new_room.position = new_room_pos
					new_room.up_socket = CLOSED
				2: #left
					new_room = treasure_room_left.instantiate()
					new_room.right_room = current_room
					current_room.left_room = new_room
					new_room.position = new_room_pos
					new_room.right_socket = CLOSED
				3: #up
					new_room = treasure_room_up.instantiate()
					new_room.down_room = current_room
					current_room.up_room = new_room
					new_room.position = new_room_pos
					new_room.down_socket = CLOSED
		#if the room count is below min, spawn no treasure rooms or cap rooms
		elif(room_count < MIN_ROOMS):
			match(s_direction):
				0: #right
					rand = randi() % (right_room_master_list.size() - 2)
					new_room = right_room_master_list[rand].instantiate()
					new_room.left_room = current_room
					room.right_room = new_room
					new_room.position = new_room_pos
					new_room.left_socket = CLOSED
				1: #down
					rand = randi() % (down_room_master_list.size() - 2)
					new_room = down_room_master_list[rand].instantiate()
					new_room.up_room = current_room
					current_room.down_room = new_room
					new_room.position = new_room_pos
					new_room.up_socket = CLOSED
				2: #left
					rand = randi() % (left_room_master_list.size() - 2)
					new_room = left_room_master_list[rand].instantiate()
					new_room.right_room = current_room
					current_room.left_room = new_room
					new_room.position = new_room_pos
					new_room.right_socket = CLOSED
				3: #up
					rand = randi() % (up_room_master_list.size() - 2)
					new_room = up_room_master_list[rand].instantiate()
					new_room.down_room = current_room
					current_room.up_room = new_room
					new_room.position = new_room_pos
					new_room.down_socket = CLOSED
		#else, normal generation
		else:
			match(s_direction):
				0: #right
					rand = randi() % right_room_master_list.size()
					new_room = right_room_master_list[rand].instantiate()
					new_room.left_room = current_room
					room.right_room = new_room
					new_room.position = new_room_pos
					new_room.left_socket = CLOSED
				1: #down
					rand = randi() % down_room_master_list.size()
					new_room = down_room_master_list[rand].instantiate()
					new_room.up_room = current_room
					current_room.down_room = new_room
					new_room.position = new_room_pos
					new_room.up_socket = CLOSED
				2: #left
					rand = randi() % left_room_master_list.size()
					new_room = left_room_master_list[rand].instantiate()
					new_room.right_room = current_room
					current_room.left_room = new_room
					new_room.position = new_room_pos
					new_room.right_socket = CLOSED
				3: #up
					rand = randi() % up_room_master_list.size()
					new_room = up_room_master_list[rand].instantiate()
					new_room.down_room = current_room
					current_room.up_room = new_room
					new_room.position = new_room_pos
					new_room.down_socket = CLOSED
		if(new_room.treasure_room == true):
			treasure_room_spawned = true
		new_room.grid_position = old_room_pos + direction_angle
		new_room.room_entered.connect(_on_new_room_entered)
		full_cells.append(new_room.grid_position)
		room_count += 1
		call_deferred("add_child", new_room)


