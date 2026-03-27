extends Cell
class_name Factory

@onready var cell = preload("res://scenes/cell.tscn")
@onready var tank = preload("res://scenes/tank_cell.tscn")

var spawn_entity

var target_angle = 0

func _physics_process(delta):
	aim(delta)
	
	if health <= 0:
		$Label.text = ""
	else:
		$Label.text = str(health)
	
	$Sprite.rotation = lerp_angle($Sprite.rotation, target_angle, 5.0 * delta)

func shoot():
	if can_shoot and !swapping:
		can_shoot = false
		
		var b
		
		if randf() < 0.1:
			b = tank.instantiate()
		else:
			b = cell.instantiate()
		
		if spawn_entity:
			spawn_entity.add_child(b)
		else:
			b.global_position = $Gun/Muzzle.global_position
			get_tree().get_root().add_child(b)
		
		b.global_position = $Gun/Muzzle.global_position
		
		target_angle += deg_to_rad(45.0)
		
		await get_tree().create_timer(firerate).timeout
		can_shoot = true
#
#func swap_sides(follow_node, col : Color, b_col: Color):
	#super.swap_sides(follow_node, col, b_col)
	#spawn_entity = follow_node

func handle_swap():
	die()
