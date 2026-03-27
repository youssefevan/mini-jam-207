extends Cell
class_name Tank

func shoot():
	if can_shoot and !swapping:
		can_shoot = false
		
		# wait first to allow cell to adjust aim
		await get_tree().create_timer(firerate).timeout
		
		var b = bullet.instantiate()
		b.global_position = $Gun/Muzzle.global_position
		b.rotation = $Gun.rotation
		b.add_to_group(bullet_group)
		b.target_color = bullet_color
		get_tree().get_root().add_child(b)
		
		var b1 = bullet.instantiate()
		b1.global_position = $Gun/Muzzle1.global_position
		b1.rotation = $Gun.rotation
		b1.add_to_group(bullet_group)
		b1.target_color = bullet_color
		get_tree().get_root().add_child(b1)
		
		var b2 = bullet.instantiate()
		b2.global_position = $Gun/Muzzle2.global_position
		b2.rotation = $Gun.rotation
		b2.add_to_group(bullet_group)
		b2.target_color = bullet_color
		get_tree().get_root().add_child(b2)
		
		can_shoot = true
