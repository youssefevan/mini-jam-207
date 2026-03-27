extends Node2D

var move_dir := Vector2.ZERO
var max_speed := 200.0
var friction = 10.0

var enemies_in_range = []

var cell_count := 0
var target_zoom := 0.7

@export var cell_color : Color

func _ready():
	cell_setup()

func cell_setup():
	cell_count = 0
	for i in get_children():
		if i is Cell:
			cell_count += 1
			i.swap_sides(self, cell_color)
	
	if cell_count < 10:
		target_zoom = 0.7
	elif cell_count >= 10 and cell_count < 20:
		target_zoom = 0.6
	elif cell_count >= 20 and cell_count < 30:
		target_zoom = 0.5
	elif cell_count >= 30 and cell_count < 40:
		target_zoom = 0.4

func _process(delta):
	$Camera.zoom = lerp($Camera.zoom, Vector2(target_zoom, target_zoom), 3.0 * delta)

func _physics_process(delta):
	move_dir = lerp(move_dir, global_position.direction_to(get_global_mouse_position()), friction * delta)
	global_position += move_dir * max_speed * delta
	
	global_position.x = clampf(global_position.x, -get_parent().world_size, get_parent().world_size)
	global_position.y = clampf(global_position.y, -get_parent().world_size, get_parent().world_size)

func _on_child_entered_tree(node):
	if node is Cell:
		cell_setup()
