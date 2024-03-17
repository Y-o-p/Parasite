extends RigidBody2D


enum State {
	IDLE,
	CONFUSED,
	SHOCKED,
	FEARFUL,
	PAIN,
	DEAD
}

var dead_host_sprite = preload("res://hostdead.png")
@export var action = State.IDLE

@onready var eyes: RayCast2D = $Eyes
@onready var direction: RayCast2D = $Direction
@onready var sprite: Sprite2D = $Torso

var desired_dir: Vector2 = Vector2(0, 0)
var worm_dir_tangent: Vector2 = Vector2(0, 0)
@export var noise: FastNoiseLite

# Called when the node enters the scene tree for the first time.
func _ready():
	global_rotation = Parasite.rng.randf_range(-PI, PI)


func _physics_process(delta):
	if action != State.DEAD:
		eyes.global_position = global_position
		direction.global_position = global_position
		
		# Looking at the worm
		eyes.set_target_position(Parasite.worm_pos - eyes.global_position)
		if eyes.is_colliding():
			var is_worm = eyes.get_collider_rid() == Parasite.worm_rid
			if is_worm:
				var t = Time.get_ticks_msec() / 100.0
				var rand_x = noise.get_noise_2d(t, 0) * 500;
				var rand_y = noise.get_noise_2d(0, t) * 500;
				worm_dir_tangent = ((Parasite.worm_pos - global_position).orthogonal() + Vector2(rand_x, rand_y)).normalized()
				desired_dir = worm_dir_tangent
				action = State.FEARFUL
		
		
		# Walking into a wall or host
		if direction.is_colliding():
			desired_dir = (direction.get_collision_normal() + worm_dir_tangent).normalized()
			direction.set_target_position(desired_dir * 100)
		

func _integrate_forces(state):
	if action == State.FEARFUL:
		var angle_difference = -desired_dir.angle_to($Facing.global_position - global_position)
		state.set_angular_velocity(2 * angle_difference)
		state.apply_force(150000 * desired_dir)
	if action == State.PAIN:
		var t = Time.get_ticks_msec() / 100.0
		var perlin = noise.get_noise_1d(t) * 3;
		state.set_angular_velocity(perlin)
	

func die():
	action = State.DEAD
	sprite.texture = dead_host_sprite
	$CollisionShape2D.disabled = true
	#queue_free()
