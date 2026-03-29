extends Sprite2D

var world
var pos_offset

func _ready():
	world = get_tree().get_root().get_node("World")
	pos_offset = Vector2(get_parent().size.x/2, get_parent().size.y/2)

func _physics_process(delta):
	position.x = (world.player.global_position.x / (Global.world_size * 2)) * get_parent().size.x
	position.y = (world.player.global_position.y / (Global.world_size * 2)) * get_parent().size.y
	
	position += pos_offset
