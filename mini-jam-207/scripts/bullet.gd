extends Area2D
class_name Bullet

var speed = 220.0
var dir = Vector2.RIGHT

@export var crit_color : Color

func _ready():
	dir = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	global_position += dir * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("free")
