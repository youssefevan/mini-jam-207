extends Node2D

@export var world_size := 2048
@export var player : Leader

@onready var cell = preload("res://scenes/cell.tscn")
@onready var tank = preload("res://scenes/tank_cell.tscn")
@onready var factory = preload("res://scenes/factory_cell.tscn")
@onready var leader = preload("res://scenes/leader.tscn")
@onready var player_scene = preload("res://scenes/player.tscn")

var can_spawn_wave := true

func _ready():
	var p = player_scene.instantiate()
	p.global_position = Vector2.ZERO
	player = p
	
	var c = cell.instantiate()
	p.add_child(c)
	
	add_child(p)
	
	spawn_enemy(50)

func get_good_spot():
	var good_spot = false
	var spawn_pos = Vector2.ZERO
	
	while not good_spot:
		var posx = randf_range(-world_size+64, world_size-64)
		var posy = randf_range(-world_size+64, world_size-64)
		
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
		l.cell_color = Color.from_hsv(
			randf(), randf_range(0.5, 0.9), randf_range(0.8, 1.0)
			)
		
		var e = enemy_type.instantiate()
		l.add_child(e)
		
		add_child(l)
		
		spawn_enemy(amount - 1)
