extends StaticBody2D
class_name Door

@export var health := 10000
@export var hurt_color : Color

func _physics_process(delta):
	$Label.text = str(health)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player"):
		health -= 1
		
		$Sprite2D.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = hurt_color
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color.WHITE
		
		if health <= 0:
			call_deferred("free")
