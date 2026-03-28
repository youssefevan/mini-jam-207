extends Node2D
class_name Leader

var move_dir := Vector2.ZERO
var max_speed := 200.0
var friction = 10.0

var enemies_in_range = []

var cell_count := 0
var target_zoom := 0.7

var game_over := false

var cell = preload("res://scenes/cell.tscn")

@export var player_controlled := false
@export var cell_color : Color
@export var team_id := 0

var wander_time := 0.0
var target_wander_dir := Vector2.ZERO
var game_over_time := 5.0

func _ready():
	if player_controlled:
		team_id = 0
	
	add_to_group(str(team_id))
	cell_setup()
	
	if !player_controlled:
		setup_wander()

func cell_setup():
	game_over_time = 5.0
	cell_count = 0
	for i in get_children():
		if i is Cell:
			i.set_leader(self)
			cell_count += 1
	
	handle_zoom()

func handle_zoom():
	if cell_count < 10:
		target_zoom = 0.7
	elif cell_count >= 10 and cell_count < 20:
		target_zoom = 0.6
	elif cell_count >= 20 and cell_count < 30:
		target_zoom = 0.5
	elif cell_count >= 30 and cell_count < 40:
		target_zoom = 0.4

func setup_wander():
	wander_time = randf_range(0.5, 4.0)
	target_wander_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _process(delta):
	if player_controlled:
		$Camera.zoom = lerp($Camera.zoom, Vector2(target_zoom, target_zoom), 3.0 * delta)

func _physics_process(delta):
	if !game_over:
		if player_controlled:
			move_dir = lerp(move_dir, global_position.direction_to(get_global_mouse_position()), friction * delta)
			global_position += move_dir * max_speed * delta
		
		else:
			wander_time -= delta
			if wander_time <= 0:
				setup_wander()
			
			move_dir = lerp(move_dir, target_wander_dir, friction * delta)
			global_position += move_dir * (max_speed/2) * delta
	
		global_position.x = clampf(global_position.x, -get_parent().world_size, get_parent().world_size)
		global_position.y = clampf(global_position.y, -get_parent().world_size, get_parent().world_size)

func _on_child_entered_tree(node):
	if node is Cell:
		cell_setup()
		
		if game_over == true:
			get_parent().toggle_dead_menu()
			game_over = false

func _on_child_exiting_tree(node):
	if node is Cell:
		cell_count -= 1
		
		if cell_count == 0 and !game_over:
			game_over = true
			if player_controlled:
				get_parent().toggle_dead_menu()
		
		handle_zoom()
