extends StaticBody2D

func _physics_process(delta):
	var key = Global.get_key(global_position)
	Global.add_cell(self)
