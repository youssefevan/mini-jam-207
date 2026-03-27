extends Node2D

var move_dir := Vector2.ZERO
var max_speed := 200.0
var friction = 10.0

var enemies_in_range = []

func _ready():
	cell_setup()

func cell_setup():
	for i in get_children():
		if i is Cell:
			i.target = self

func _physics_process(delta):
	move_dir = lerp(move_dir, global_position.direction_to(get_global_mouse_position()), friction * delta)
	global_position += move_dir * max_speed * delta

func _on_range_body_entered(body):
	if body is Cell and body not in get_children():
		enemies_in_range.append(body)

func _on_range_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)
