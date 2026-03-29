extends Node

var world_size := 1872
var game_size := 30

var grid = {}
var cell_size := 256

func get_key(pos):
	return Vector2i(pos / cell_size)

func add_cell(cell):
	var key = get_key(cell.global_position)
	if !grid.has(key):
		grid[key] = []
	grid[key].append(cell)

func _physics_process(delta):
	grid.clear()
	
