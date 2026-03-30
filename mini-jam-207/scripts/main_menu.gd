extends Node2D

var world_size = 512

@onready var game = load("res://scenes/world.tscn")

func _ready():
	for i in get_tree().get_root().get_children():
		if i is Bullet:
			i.queue_free()

func _on_num_cells_value_changed(value):
	Global.game_size = int(value)
	
	$CanvasLayer/Menu/VBoxContainer/VBoxContainer/Label2.text = str("game size: ", Global.game_size)


func _on_start_pressed():
	
	### this caused leader placement bugs, so im cheating with a global script
	#var g = game.instantiate()
	#g.game_size = num_cells
	#
	#var main = get_tree().current_scene
	#
	#get_tree().root.add_child(g)
	#get_tree().current_scene = g
	#
	#main.queue_free()
	
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_button_pressed():
	pass # Replace with function body.
