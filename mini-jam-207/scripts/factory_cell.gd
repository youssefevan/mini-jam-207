extends Cell
class_name Factory

@onready var cell = preload("res://scenes/cell.tscn")
@onready var tank = preload("res://scenes/tank_cell.tscn")

var spawn_entity

var target_angle = 0

func _physics_process(delta):
	super._physics_process(delta)
	
	$Sprite.rotation = lerp_angle($Sprite.rotation, target_angle, 5.0 * delta)

func shoot():
	if can_shoot and !swapping:
		can_shoot = false
		
		var b
		
		if randf() < 0.1:
			b = tank.instantiate()
		else:
			b = cell.instantiate()
		
		get_parent().add_child(b)
		b.global_position = $Gun/Muzzle.global_position
		
		health -= 1
		
		target_angle += deg_to_rad(45.0)
		
		await get_tree().create_timer(firerate).timeout
		can_shoot = true

func swap_sides(new_leader):
	call_deferred('free')
