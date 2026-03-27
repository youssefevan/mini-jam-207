extends Area2D
class_name Bullet

@export var speed = 250.0
var dir = Vector2.RIGHT

var target_color = Color.WHITE

func _ready():
	dir = Vector2.RIGHT.rotated(rotation)
	$Sprite.modulate = target_color

func _physics_process(delta):
	global_position += dir * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("free")

func _on_area_entered(area):
	if area.is_in_group(get_groups()[0]) == false:
		call_deferred("free")

func _on_body_entered(body):
	if body.get_collision_layer_value(2):
		call_deferred("free")
