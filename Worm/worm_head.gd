extends RigidBody2D


var contact_position: Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):
	if state.get_contact_count() > 0:
		contact_position = state.get_contact_local_position(0)
		print(contact_position)
