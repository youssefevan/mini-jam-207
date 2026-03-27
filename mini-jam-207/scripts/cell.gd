extends CharacterBody2D
class_name Cell

@onready var bullet = preload("res://scenes/bullet.tscn")

var target

var max_speed := 300.0
var move_dir := Vector2.ZERO
var friction := 1.0
var aim_speed := 5.0
var seperation_strength := 500.0
var health := 5

var firerate := 0.5
var can_shoot := true

var target_color

var neighbors = []
var enemies_in_range = []

func _process(delta):
	if target_color:
		$Sprite.modulate = lerp($Sprite.modulate, target_color, 1.0 * delta)

func _physics_process(delta):
	if target and global_position.distance_squared_to(target.global_position) > 200.0:
		move_dir = global_position.direction_to(target.global_position)
		velocity = lerp(velocity, move_dir * max_speed, friction * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	
	velocity += get_seperation_force()
	
	aim(delta)
	
	move_and_slide()

func aim(delta):
	var closest
	if not enemies_in_range.is_empty():
		for i in enemies_in_range:
			if closest == null:
				closest = i
			elif global_position.distance_squared_to(i.global_position) < global_position.distance_squared_to(closest.global_position):
				closest = i
	
	if closest:
		var target_dir = global_position.direction_to(closest.global_position).angle()
		$Gun.rotation = lerp_angle($Gun.rotation, target_dir, aim_speed * delta)
		
		#shoot
		#if can_shoot
		
	else:
		if target:
			var target_dir = global_position.direction_to(get_global_mouse_position()).angle()
			$Gun.rotation = lerp_angle($Gun.rotation, target_dir, aim_speed * delta)

func get_seperation_force():
	var force = Vector2.ZERO
	
	for i in neighbors:
		var offset = global_position - i.global_position
		var distance = offset.length()
		
		if distance > 0:
			distance = max(distance, 10.0)
			force += offset.normalized() / distance
	
	return force * seperation_strength

func swap_sides(follow_node, col : Color):
	enemies_in_range = []
	
	target = follow_node
	target_color = col
	
	set_collision_layer_value(6, false)
	set_collision_layer_value(5, true)
	$AttackRange.set_collision_mask_value(5, false)
	$AttackRange.set_collision_mask_value(6, true)
	$Hurtbox.remove_from_group("enemy")
	$Hurtbox.add_to_group("player")

func _on_seperator_body_entered(body):
	neighbors.append(body)

func _on_seperator_body_exited(body):
	neighbors.erase(body)

func _on_hurtbox_area_entered(area):
	if area.is_in_group($Hurtbox.get_groups()[0]) == false:
		print("ouchie!")

func _on_attack_range_body_entered(body):
	if body is Cell:
		enemies_in_range.append(body)

func _on_attack_range_body_exited(body):
	enemies_in_range.erase(body)
