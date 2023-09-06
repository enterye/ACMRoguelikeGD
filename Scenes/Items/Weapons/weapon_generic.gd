extends Node2D

func flip():
	scale = Vector2(1, -1)
	
func unflip():
	scale = Vector2(1, 1)
