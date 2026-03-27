extends CharacterBody2D
class_name Cell

@onready var bullet = preload("res://scenes/bullet.tscn")

var target

@export var max_speed := 100.0
var move_dir := Vector2.ZERO
var friction := 3.0
var aim_speed := 10.0
var seperation_strength := 500.0
var health
@export var max_health := 5

@export var firerate := 1.0
@export var bullet_speed := 250.0
var can_shoot := true

@export var target_color : Color
@export var bullet_color : Color
@export var hurt_color := Color.WHITE
var bullet_group := "enemy"

var neighbors = []
var enemies_in_range = []
var target_enemy

var swapping := false

var starting_pos : Vector2

func _ready():
	starting_pos = global_position
	health = max_health

func _process(delta):
	if target_color:
		$Sprite.modulate = lerp($Sprite.modulate, target_color, 1.0 * delta)

func _physics_process(delta):
	if health <= 0:
		$Label.text = ""
	else:
		$Label.text = str(health)
	
	if target:
		if global_position.distance_squared_to(target.global_position) > 200.0:
			move_dir = global_position.direction_to(target.global_position)
			velocity = lerp(velocity, move_dir * max_speed, friction * delta)
		else:
			velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	elif target_enemy:
		if global_position.distance_squared_to(target_enemy.global_position) > 1000.0:
			move_dir = global_position.direction_to(target_enemy.global_position)
			velocity = lerp(velocity, move_dir * max_speed, friction * delta)
		else:
			velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	else:
		if global_position.distance_squared_to(starting_pos) > 1000.0:
			move_dir = global_position.direction_to(starting_pos)
			velocity = lerp(velocity, move_dir * max_speed, friction * delta)
		else:
			velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	
	velocity += get_seperation_force()
	
	aim(delta)
	
	move_and_slide()

func get_seperation_force():
	var force = Vector2.ZERO
	
	for i in neighbors:
		var offset = global_position - i.global_position
		var distance = offset.length()
		
		if distance > 0:
			force += offset.normalized() / distance
	
	return force * seperation_strength

func aim(delta):
	var closest
	if not enemies_in_range.is_empty():
		closest = enemies_in_range[0]
		for i in enemies_in_range:
			if global_position.distance_squared_to(i.global_position) < global_position.distance_squared_to(closest.global_position):
				closest = i
	
		target_enemy = closest
		
		var dist = global_position.distance_to(target_enemy.global_position)
		var lead_position = target_enemy.global_position + target_enemy.velocity * (dist / bullet_speed)
		var target_dir = global_position.direction_to(lead_position).angle()
		$Gun.rotation = lerp_angle($Gun.rotation, target_dir, aim_speed * delta)
		
		shoot()
		
	else:
		target_enemy = null
		if target:
			var target_dir = global_position.direction_to(get_global_mouse_position()).angle()
			$Gun.rotation = lerp_angle($Gun.rotation, target_dir, aim_speed * delta)

func shoot():
	if can_shoot and !swapping:
		can_shoot = false
		
		var b = bullet.instantiate()
		b.global_position = $Gun/Muzzle.global_position
		b.rotation = $Gun.rotation
		b.speed = bullet_speed
		b.add_to_group(bullet_group)
		b.target_color = bullet_color
		get_tree().get_root().add_child(b)
		
		await get_tree().create_timer(firerate).timeout
		can_shoot = true

func swap_sides(follow_node, col : Color, b_col: Color):
	enemies_in_range = []
	
	target = follow_node
	target_color = col
	bullet_color = b_col
	bullet_group = "player"
	
	set_collision_layer_value(6, false)
	set_collision_layer_value(5, true)
	$AttackRange.set_collision_mask_value(5, false)
	$AttackRange.set_collision_mask_value(6, true)
	$Hurtbox.remove_from_group("enemy")
	$Hurtbox.add_to_group("player")

func handle_swap():
	swapping = true
	
	# prevents visually teleporting on reparent
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	call_deferred("reparent", get_tree().get_root().get_node("World").player)
	await get_tree().create_timer(0.02).timeout
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
	
	await get_tree().create_timer(2.0).timeout
	swapping = false
	health = int(max_health/2)

func die():
	call_deferred("free")

func _on_seperator_body_entered(body):
	neighbors.append(body)

func _on_seperator_body_exited(body):
	neighbors.erase(body)

func _on_hurtbox_area_entered(area):
	if area.is_in_group($Hurtbox.get_groups()[0]) == false and !swapping:
		health -= 1
		
		if health <= 0:
			if area.is_in_group("player"):
				handle_swap()
				return
			else:
				die()
		
		$Sprite.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = target_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = target_color

func _on_attack_range_body_entered(body):
	if body is Cell:
		enemies_in_range.append(body)

func _on_attack_range_body_exited(body):
	enemies_in_range.erase(body)
