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
		b.set_leader(leader)
		get_tree().get_root().add_child(b)
		
		var b1 = bullet.instantiate()
		b1.global_position = $Gun/Muzzle1.global_position
		b1.rotation = $Gun.rotation
		b1.set_leader(leader)
		get_tree().get_root().add_child(b1)
		
		var b2 = bullet.instantiate()
		b2.global_position = $Gun/Muzzle2.global_position
		b2.rotation = $Gun.rotation
		b2.set_leader(leader)
		get_tree().get_root().add_child(b2)
		
		can_shoot = true
