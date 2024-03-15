@tool
extends TileMap

var starting_host_count: int

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_host_count = len(get_used_cells_by_id(0, -1, Vector2i(-1, -1), 2))
	Parasite.host_count = starting_host_count


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return

func get_hosts_left():
	return 
