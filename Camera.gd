extends Camera2D

@export var target: Node2D
@export var desired_size: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if target:
		position = target.position

func _physics_process(delta):
	if !target:
		return
	
	var new_zoom = lerp(zoom.x, desired_size, 0.01)
	set_zoom(Vector2(new_zoom, new_zoom))
	position = lerp(position, target.position, 0.08)
