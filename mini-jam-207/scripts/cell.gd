extends CharacterBody2D
class_name Cell

@onready var bullet = load("res://scenes/bullet.tscn")

var leader : Leader
var team_id := -1

@export var max_speed := 100.0
var move_dir := Vector2.ZERO
var friction := 3.0
var aim_speed := 10.0
var seperation_strength := 500.0
var health
@export var max_health := 5

@export var firerate := 1.0
var can_shoot := true

var attack_range := 260000

@export var target_color : Color
@export var hurt_color := Color.WHITE

var target_dir = 0

var target_enemy

var swapping := false

var starting_pos : Vector2
var enemies_in_range = []

var aim_timer := randf() * 0.1

@export var col_size := 60.0

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
	
	var key = Global.get_key(global_position)
	Global.add_cell(self)
	
	if leader:
		if global_position.distance_squared_to(leader.global_position) > 400.0:
			move_dir = global_position.direction_to(leader.global_position)
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
	
	if leader.player_controlled and leader.cell_count < 12:
		call_deferred("aim", delta)
		#aim(delta)
	else:
		aim_timer -= delta
		if aim_timer <= 0:
			call_deferred("aim", delta)
			#aim(delta)
			aim_timer = 0.1
	$Gun.rotation = lerp_angle($Gun.rotation, target_dir, aim_speed * delta)
	
	global_position = clamp(
		global_position,
		Vector2(-Global.world_size, -Global.world_size),
		Vector2(Global.world_size, Global.world_size)
	)
	
	move_and_slide()

func get_neighbors():
	var out = []
	var base = Global.get_key(global_position)
	
	for x in range(-1, 2): # surrounding grid cells
		for y in range(-1, 2): # surrounding grid cells
			var key = base + Vector2i(x, y)
			if Global.grid.has(key):
				out += Global.grid[key]
	
	return out

func get_seperation_force():
	var force = Vector2.ZERO
	var neighbors = get_neighbors()
	
	for i in neighbors:
		if i != self:
			var offset = global_position - i.global_position
			var distance = global_position.distance_squared_to(i.global_position)
			
			if distance > 0 and distance < (col_size*col_size):
				force += offset.normalized() / sqrt(distance)
	
	return force * seperation_strength

func aim(delta):
	var neighbors = get_neighbors()
	var closest
	var closest_dist = INF
	
	for i in neighbors:
		if is_instance_valid(i):
			if i is Cell:
				if i != self and i.team_id != team_id and !i.swapping:
					var distance = global_position.distance_squared_to(i.global_position)
					
					if distance < closest_dist and distance < attack_range:
						closest_dist = distance
						closest = i
	
	target_enemy = closest
		
	if target_enemy:
		target_dir = global_position.direction_to(target_enemy.global_position).angle()
		shoot()
	elif leader.player_controlled:
		target_dir = global_position.direction_to(get_global_mouse_position()).angle()

func shoot():
	if can_shoot and !swapping:
		can_shoot = false
		
		var b = bullet.instantiate()
		b.global_position = $Gun/Muzzle.global_position
		b.rotation = $Gun.rotation
		b.set_leader(leader)
		
		get_parent().get_parent().add_child(b)
		
		await get_tree().create_timer(firerate).timeout
		can_shoot = true

func swap_sides(new_leader):
	swapping = true
	
	enemies_in_range = []
	
	set_leader(new_leader)
	
	if new_leader.player_controlled:
		$SFX.play()
	
	# prevents visually teleporting on reparent
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	call_deferred("reparent", new_leader)
	await get_tree().create_timer(0.02).timeout
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
	
	await get_tree().create_timer(2.0).timeout
	swapping = false
	
	#$AttackRange/Collider.disabled = true
	#$AttackRange/Collider.disabled = false
	
	health = max_health

func set_leader(new_leader):
	leader = new_leader
	target_color = new_leader.cell_color
	
	remove_from_group(str(team_id))
	add_to_group(str(new_leader.team_id))
	$Hurtbox.remove_from_group(str(team_id))
	$Hurtbox.add_to_group(str(new_leader.team_id))
	team_id = new_leader.team_id

func die():
	call_deferred("free")
#
#func _on_seperator_body_entered(body):
	#neighbors.append(body)
#
#func _on_seperator_body_exited(body):
	#neighbors.erase(body)

func _on_hurtbox_area_entered(area):
	if !area.is_in_group(str(team_id)) and !swapping:
		health -= 1
		
		if health <= 0:
			if leader.player_controlled:
				$Hit.play()
			
			swap_sides(area.leader)
			return
		
		$Sprite.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = target_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite.modulate = target_color


#func _on_attack_range_body_entered(body):
	#if body is Cell and !body.is_in_group(str(team_id)) and !swapping:
		#enemies_in_range.append(body)
#
#func _on_attack_range_body_exited(body):
	#enemies_in_range.erase(body)
