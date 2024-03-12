extends Camera2D

@export var target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if target:
		position = target.position

func _physics_process(delta):
	if !target:
		return
		
	position = lerp(position, target.position, 0.08)
