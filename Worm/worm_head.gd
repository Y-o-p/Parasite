extends RigidBody2D


var contact_position: Vector2 = Vector2()
@onready var tail = $WormTail
var latched_body: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Parasite.worm_rid = get_rid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):
	if state.get_contact_count() > 0:
		contact_position = state.get_contact_local_position(0)
	if latched_body != null:
		var dir = (latched_body.global_position - global_position)
		state.apply_force(100 * dir)
	Parasite.worm_pos = global_position

func latch(body):
	latched_body = body
	set_collision_mask_value(0b10, false)
	set_collision_layer_value(0b1, false)
	tail.segments[0].set_collision_mask_value(0b10, false)
	tail.segments[0].set_collision_layer_value(5, false)
	tail.segments[1].set_collision_mask_value(0b10, false)
	tail.segments[1].set_collision_layer_value(5, false)
	tail.wiggle = Parasite.Wiggle.OSCILLATE

func unlatch():
	latched_body = null
	set_collision_mask_value(0b10, true)
	set_collision_layer_value(0b1, true)
	tail.segments[0].set_collision_mask_value(0b10, true)
	tail.segments[0].set_collision_layer_value(5, true)
	tail.segments[1].set_collision_mask_value(0b10, true)
	tail.segments[1].set_collision_layer_value(5, true)
	tail.wiggle = Parasite.Wiggle.NONE
