extends Node2D

var player : Leader

@onready var cell = preload("res://scenes/cell.tscn")
@onready var tank = preload("res://scenes/tank_cell.tscn")
@onready var factory = preload("res://scenes/factory_cell.tscn")
@onready var leader = preload("res://scenes/leader.tscn")
@onready var player_scene = preload("res://scenes/player.tscn")

@export var override_game_size := false
@export var number_of_cells := 50

var can_spawn_wave := true

var score_update_time = 1.0

func _ready():
	$AudioStreamPlayer.volume_db = Global.volume
	for i in get_tree().get_root().get_children():
		if i is Bullet:
			i.queue_free()
	
	var p = player_scene.instantiate()
	p.global_position = Vector2.ZERO
	player = p
	
	var c = cell.instantiate()
	c.max_health = 10
	p.add_child(c)
	
	add_child(p)
	
	if override_game_size:
		spawn_enemy(number_of_cells)
	else:
		spawn_enemy(Global.game_size)

func get_good_spot():
	var good_spot = false
	var spawn_pos = Vector2.ZERO
	
	while not good_spot:
		var posx = randf_range(-Global.world_size+64, Global.world_size-64)
		var posy = randf_range(-Global.world_size+64, Global.world_size-64)
		
		var dist_to_player = Vector2(posx, posy).distance_to(player.global_position)
		
		if dist_to_player > 500:
			spawn_pos = Vector2(posx, posy)
			good_spot = true
	
	return spawn_pos

func spawn_enemy(amount):
	if amount > 0:
		var rand_enemy = randi_range(0, 9)
		var enemy_type
		
		if rand_enemy == 0:
			enemy_type = factory
		elif rand_enemy > 0 and rand_enemy < 7:
			enemy_type = cell
		else:
			enemy_type = tank
		
		var l = leader.instantiate()
		l.global_position = get_good_spot()
		l.team_id = amount
		
		var value = float(amount)/Global.game_size
		value = 0.1 + value * 0.8
		
		l.cell_color = Color.from_hsv(value, randf_range(0.5, 0.9), randf_range(0.8, 1.0))
		
		var e = enemy_type.instantiate()
		l.add_child(e)
		
		add_child(l)
		
		spawn_enemy(amount - 1)

func _physics_process(delta):
	score_update_time -= delta
	
	if score_update_time <= 0 and player.game_over == false:
		var game_won = true
		for i in get_children():
			if i is Leader:
				if not i.player_controlled:
					if i.game_over == false:
						game_won = false
						continue
		
		if game_won == true:
			$CanvasLayer/Menu/VBoxContainer/Label.text = "you won!"
			$CanvasLayer/Menu.visible = true
		
		score_update_time = 1.0
	

func toggle_dead_menu():
	$CanvasLayer/Menu.visible = !$CanvasLayer/Menu.visible

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
