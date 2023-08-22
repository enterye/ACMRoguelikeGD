extends Node2D

var collapsed: bool = false
var possible_tiles: Array = []
var entropy
var stored_tile

func createCell(collapsed_state: bool, tiles: Array):
	collapsed = collapsed_state
	possible_tiles = tiles
	entropy = tiles.size()

func updateTiles(tiles: Array):
	possible_tiles = tiles
	entropy = tiles.size()
