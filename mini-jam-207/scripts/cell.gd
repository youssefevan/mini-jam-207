extends CharacterBody2D
class_name Cell

var target

var max_speed := 300.0
var move_dir := Vector2.ZERO
var friction := 1.0
var aim_speed := 10.0

var seperation_strength := 500.0

var health := 5

var neighbors = []

func _physics_process(delta):
	if target and global_position.distance_squared_to(target.global_position) > 200.0:
		move_dir = global_position.direction_to(target.global_position)
		velocity = lerp(velocity, move_dir * max_speed, friction * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	
	velocity += get_seperation_force()
	
	aim()
	
	move_and_slide()

func aim():
	if target:
		var closest
		for i in target.enemies_in_range:
			if closest == null:
				closest = i
			elif global_position.distance_squared_to(i.global_position) > global_position.distance_squared_to(closest.global_position):
				closest = i
		
		if closest:
			$Gun.look_at(closest.global_position)

func get_seperation_force():
	var force = Vector2.ZERO
	
	for i in neighbors:
		var offset = global_position - i.global_position
		var distance = offset.length()
		
		if distance > 0:
			force += offset.normalized() / distance
	
	return force * seperation_strength

func _on_seperator_body_entered(body):
	if body is Cell:
		neighbors.append(body)

func _on_seperator_body_exited(body):
	if body in neighbors:
		neighbors.erase(body)
