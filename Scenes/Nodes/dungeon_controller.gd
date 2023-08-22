extends Node2D

const CELLSIZE = 500

const OPEN = 1
const CLOSED = 0

signal room_added(this_room)
#limits for dungeon generation
const GRID_LIMIT = 7
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

var center_cell

#used for cycling through sockets
var direction_dictionary = {
	0 : Vector2.RIGHT,
	1 : Vector2.DOWN,
	2 : Vector2.LEFT,
	3 : Vector2.UP
}

var current_room

var current_cell
#array of spaces that already have rooms

#cell class
var cell = preload("res://Scenes/Nodes/wfc_cell.tscn")
var cell_list = []

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
var room_master_list = [room_0, room_1, room_2, room_3, room_4, room_5, room_6, room_7, room_8, room_9, room_10, treasure_room_up, treasure_room_down, treasure_room_right, treasure_room_left, cap_room_up, cap_room_down, cap_room_right, cap_room_left]
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

var test_list = [room_1, room_2]
#sets current room
func _on_new_room_entered(room, owner_cell):
	current_room = room
	current_cell_pos = room.grid_position

	current_cell = owner_cell
	
	#generates new rooms upon entering a room for the first time
	if(current_room.player_visited == false):
		var adjacent_cells = get_adjacent_cells(current_cell)
		for cells in adjacent_cells:
			if cells != null:
				update_cell_possible_rooms(cells)
		for cells in adjacent_cells:
			if cells != null:
				collapse_cell(cells)

#creates the starting room, connects it to _on_new_room_entered, and generates adjacent rooms
func _ready():
	initialize_cell_grid()
	center_cell = cell_list[24]
	collapse_center_cell(center_cell)

#frees memory by clearing all of the cells created to help with generation
func clear_cells():
	for c in cell_list:
		c.queue_free()

#collapses the cell in the center, always set the room to room_0
#also calls the update_cell_possible_rooms for all adjacent cells
func collapse_center_cell(this_cell):
	var room = room_0.instantiate()
	room.position = this_cell.position * CELLSIZE
	room.grid_position = this_cell.position
	room.room_entered.connect(_on_new_room_entered)
	current_room = room
	
	room.owner_cell = this_cell
	this_cell.stored_tile = room
	this_cell.collapsed = true
	
	room_count += 1
	add_child(room)
	
	var adjacent_cells = get_adjacent_cells(this_cell)

	for cells in adjacent_cells:
		if cells != null:
			update_cell_possible_rooms(cells)
	for cells in adjacent_cells:
		if cells != null:
			collapse_cell(cells)

#collapses a cell by choosing a random room within it's array
func collapse_cell(this_cell):
	var arraysize = this_cell.possible_tiles.size()
	
	var rand = randi() % arraysize
	var room = this_cell.possible_tiles[rand].instantiate()
	room.position = this_cell.position * CELLSIZE
	room.grid_position = this_cell.position
	room.room_entered.connect(_on_new_room_entered)
	
	room.owner_cell = this_cell
	this_cell.stored_tile = room
	this_cell.collapsed = true
	
	room_count += 1
	add_child(room)
	
	room_added.emit(room)

#given a cell, return it's adjacent rooms
func get_adjacent_rooms(this_cell) -> Array:
	var adjacent_rooms = []
	var this_cell_position = cell_list.find(this_cell)
	var cell_right
	var cell_down
	var cell_left
	var cell_up
	var room_right
	var room_down
	var room_left
	var room_up
	
	if this_cell_position + 1 < 49: #right cell
		cell_right = cell_list[this_cell_position + 1]
		if cell_right.collapsed:
			room_right = cell_right.stored_tile
			adjacent_rooms.append(room_right)
	if this_cell_position + 7 < 49: #down cell
		cell_down = cell_list[this_cell_position + 7]
		if cell_down.collapsed:
			room_down = cell_down.stored_tile
			adjacent_rooms.append(room_down)
	if this_cell_position - 1 > -1: #left cell
		cell_left = cell_list[this_cell_position - 1]
		if cell_left.collapsed:
			room_left = cell_left.stored_tile
			adjacent_rooms.append(room_left)
	if this_cell_position - 7 > -1: #up cell
		cell_up = cell_list[this_cell_position - 7]
		if cell_up.collapsed:
			room_up = cell_up.stored_tile
			adjacent_rooms.append(room_up)
	
	print(adjacent_rooms)
	return adjacent_rooms

#returns a list of the cells adjacent to this one
func get_adjacent_cells(this_cell) -> Array:
	var adjacent_cells = []
	var this_cell_position = cell_list.find(this_cell)
	
	var cell_right = null
	var cell_down = null
	var cell_left = null
	var cell_up = null
	
	if this_cell_position + 1 < 49: #right cell
		cell_right = cell_list[this_cell_position + 1]
		if cell_right.collapsed == true:
			cell_right = null
	if this_cell_position + 7 < 49: #down cell
		cell_down = cell_list[this_cell_position + 7]
		if cell_down.collapsed == true:
			cell_down = null
	if this_cell_position - 1 > -1: #left cell
		cell_left = cell_list[this_cell_position - 1]
		if cell_left.collapsed == true:
			cell_left = null
	if this_cell_position - 7 > -1: #up cell
		cell_up = cell_list[this_cell_position - 7]
		if cell_up.collapsed == true:
			cell_up = null
			
	adjacent_cells = [cell_right, cell_left, cell_down, cell_up]
	return adjacent_cells

#currently this only works from the direction of the room the player is in
#needs logic so that it updates tiles in every direction
#given a cell, update it's possible rooms
func update_cell_possible_rooms(updating_cell):
	#print(updating_cell)
	var new_list = updating_cell.possible_tiles.duplicate()
	#get adjacent rooms and save as null if there is none
	var adjacent_rooms = get_adjacent_rooms(updating_cell)
	
	for tile in updating_cell.possible_tiles:
		var test_to_room = tile.instantiate()
		test_to_room.grid_position = updating_cell.position
		test_to_room.position = Vector2(20000,20000)
		add_child(test_to_room)
		for room in adjacent_rooms:
			if(room.is_compatible_with(test_to_room) == false):
				new_list.erase(tile)
			test_to_room.queue_free()
	updating_cell.updateTiles(new_list)

#initalizes a grid of cells that will be used to generate the dungeon
func initialize_cell_grid():
	var startpos = Vector2(-3 , -3) #the top right cell of the grid
	var pos = startpos
	var col = 0
	var row = 0
	var grid_cell
	while(col < GRID_LIMIT):
		while(row < GRID_LIMIT):
			grid_cell = cell.instantiate()
			var list = room_master_list.duplicate()
			grid_cell.createCell(false, list)
			grid_cell.position = pos
			cell_list.append(grid_cell)
			add_child(grid_cell)
			pos += Vector2.RIGHT
			row += 1
		#last part of loop is to increment
		row = 0
		pos.x = -3
		pos += Vector2.DOWN
		col += 1


func _on_room_added(this_room):
	var direction = this_room.grid_position - current_room.grid_position
	match(direction):
		Vector2.RIGHT:
			this_room.left_room = current_room
			current_room.right_room = this_room
		Vector2.DOWN:
			this_room.up_room = current_room
			current_room.down_room = this_room
		Vector2.LEFT:
			this_room.right_room = current_room
			current_room.left_room = this_room
		Vector2.UP:
			this_room.down_room = current_room
			current_room.up_room = this_room
