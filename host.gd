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
@export var noise: FastNoiseLite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Looking at the worm
	eyes.set_target_position(Parasite.worm_pos - eyes.global_position)
	if eyes.is_colliding():
		var is_worm = eyes.get_collider_rid() == Parasite.worm_rid
		if is_worm:
			var t = Time.get_ticks_msec() / 100.0
			var rand_x = noise.get_noise_2d(t, 0) * 500;
			var rand_y = noise.get_noise_2d(0, t) * 500;
			worm_dir_tangent = ((Parasite.worm_pos - global_position).orthogonal() + Vector2(rand_x, rand_y)).normalized()
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
