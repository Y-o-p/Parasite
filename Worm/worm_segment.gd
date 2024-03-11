extends RigidBody2D

@export var wiggle: Parasite.Wiggle = Parasite.Wiggle.NONE
@export var speed: float = 3.0
@export var parent_segment: RigidBody2D
@onready var joint: PinJoint2D = $Joint

func _ready():
	joint.node_a = parent_segment.get_path()

func _integrate_forces(state):
	if wiggle == Parasite.Wiggle.SQUASH:
		if abs(rotation_degrees) < 70:
			var dir = sign(rotation_degrees)
			if dir == 0:
				dir = Array([-1, 1])[randi_range(0, 1)]
			state.apply_torque(dir * speed * 5000)
	if wiggle == Parasite.Wiggle.OSCILLATE:
		var dir = -sign(rotation_degrees)
		state.set_angular_velocity(sin(10 * Time.get_ticks_msec() / 1000.0) * speed)
