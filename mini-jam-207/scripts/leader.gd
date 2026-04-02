extends Node2D
class_name Leader

var move_dir := Vector2.ZERO
var max_speed := 200.0
var friction = 10.0

var enemies_in_range = []

var cell_count := 0
var target_zoom := 0.7

var game_over := false

var cell = load("res://scenes/cell.tscn")

@export var player_controlled := false
@export var cell_color : Color
@export var team_id := 0
@export var debug := false

var wander_time := 0.0
var target_wander_dir := Vector2.ZERO
var game_over_time := 5.0

var steer_dir := Vector2.ZERO

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
	if cell_count < 6:
		target_zoom = 0.7
	elif cell_count >= 6 and cell_count < 12:
		target_zoom = 0.6
	elif cell_count >= 12 and cell_count < 24:
		target_zoom = 0.5
	elif cell_count >= 24:
		target_zoom = 0.4

func setup_wander():
	wander_time = randf_range(0.5, 4.0)
	target_wander_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	steer_dir = Vector2.ZERO

func _process(delta):
	if debug:
		queue_redraw()
	
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
			
			# steer away from world bounds
			var margin := 64.0
			
			if global_position.x > Global.world_size - margin:
				steer_dir.x -= 1
			elif global_position.x < -Global.world_size + margin:
				steer_dir.x += 1
			else:
				steer_dir.x = lerpf(steer_dir.x, 0.0, friction * delta)
			
			if global_position.y > Global.world_size - margin:
				steer_dir.y -= 1
			elif global_position.y < -Global.world_size + margin:
				steer_dir.y += 1
			else:
				steer_dir.y = lerpf(steer_dir.y, 0.0, friction * delta)
			
			steer_dir = steer_dir.normalized()
			
			if steer_dir != Vector2.ZERO:
				move_dir = lerp(move_dir, steer_dir, friction * delta)
			else:
				move_dir = lerp(move_dir, target_wander_dir, friction * delta)
			
			global_position += move_dir * (max_speed/2) * delta
	
		global_position.x = clampf(global_position.x, -Global.world_size, Global.world_size)
		global_position.y = clampf(global_position.y, -Global.world_size, Global.world_size)

func _draw():
	if debug:
		var end_point = move_dir.normalized() * 100.0
		draw_line(Vector2.ZERO, end_point, cell_color, 4.0)
		draw_circle(Vector2.ZERO, 20.0, cell_color)

func _on_child_entered_tree(node):
	if node is Cell:
		cell_setup()
		
		if game_over == true:
			if player_controlled:
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
