extends RigidBody2D


enum State {
	IDLE,
	CONFUSED,
	SHOCKED,
	FEARFUL,
	PAIN
}

@export var action = State.IDLE

@onready var eyes: RayCast2D = $Eyes
@onready var direction: RayCast2D = $Direction

var dir: Vector2 = Vector2(0, 0)
var worm_dir_tangent: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Looking at the worm
	eyes.set_target_position(Parasite.worm_pos - eyes.global_position)
	if eyes.is_colliding():
		var is_worm = eyes.get_collider_rid() == Parasite.worm_rid
		if is_worm:
			worm_dir_tangent = (Parasite.worm_pos - global_position).orthogonal().normalized()
			dir = worm_dir_tangent
			action = State.FEARFUL
	
	# Walking into a wall or host
	direction.set_target_position(100 * dir)
	if direction.is_colliding():
		dir = (direction.get_collision_normal() + worm_dir_tangent).normalized()
		

func _integrate_forces(state):
	if action == State.FEARFUL:
		state.apply_force(100000 * dir)
	

func die():
	queue_free()
