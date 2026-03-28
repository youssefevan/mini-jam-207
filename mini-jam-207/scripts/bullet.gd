extends Area2D
class_name Bullet

@export var speed = 250.0
var dir = Vector2.RIGHT

var target_color = Color.WHITE

var leader : Leader
var team_id : int

func _ready():
	dir = Vector2.RIGHT.rotated(rotation)
	$Sprite.modulate = target_color

func _physics_process(delta):
	global_position += dir * speed * delta

func set_leader(new_leader):
	leader = new_leader
	team_id = new_leader.team_id
	add_to_group(str(new_leader.team_id))
	target_color = new_leader.cell_color

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("free")

func _on_area_entered(area):
	if !area.is_in_group(str(team_id)):
		call_deferred("free")

func _on_body_entered(body):
	if body.get_collision_layer_value(2):
		call_deferred("free")
