extends Node2D

var segments: Array[RigidBody2D] = []
var BODY_SEGMENT = preload("worm_segment.tscn")
@export var wiggle: Wiggle = Wiggle.NONE
@export var collidable: bool = true
@export var freeze: bool = false
@export var segment_count: int = 3
@export var latched_node: PhysicsBody2D
@export var wiggle_speed: int = 8
signal added_length

enum Wiggle {
	NONE,
	SQUASH,
	STRETCH,
	OSCILLATE
}

func _ready():
	for i in range(segment_count):
		add_segment()
	if latched_node != null:
		latch(latched_node)
	added_length.emit()

func _physics_process(delta):
	if wiggle == Wiggle.NONE:
		for i in range(len(segments)):
			segments[i].set_angular_damp(0)
	if wiggle == Wiggle.SQUASH:
		for i in range(len(segments)):
			#segments[i].set_angular_damp(i**4)
			segments[i].set_angular_damp(15)
			var dir = 1 if i % 2 == 0 else -1
			if abs(segments[i].rotation_degrees) < 45:
				segments[i].set_angular_velocity(dir * wiggle_speed)
	if wiggle == Wiggle.OSCILLATE:
		for i in range(len(segments)):
			segments[i].set_angular_velocity(sin(15 * Time.get_ticks_msec() / 1000.0) * wiggle_speed)

func add_segments(count):
	if count > 0:
		call_deferred("add_segment")
		call_deferred("add_segments", count - 1)
	else:
		added_length.emit()

func add_segment():
	var segment = BODY_SEGMENT.instantiate()
	var joint: PinJoint2D = segment.get_node("Joint")
	if len(segments) > 0:
		joint.node_a = segments[-1].get_path()
		segments[-1].get_node("CollisionShape2D/Tail").add_child(segment)
		#segments[-1].get_node("CollisionShape2D/Tail").call_deferred("add_child", segment)
		#segments[-1].get_node("CollisionShape2D/Tail").add_child(segment)
	else:
		add_child(segment)
	segments.append(segment)

func latch(body):
	latched_node = body
	segments[0].get_node("Joint").node_a = latched_node.get_path()

func set_freeze(f):
	for segment in segments:
		segment.set_deferred("freeze", f)

func _on_added_length():
	for segment in segments:
		segment.set_collision_mask_value(0b10, collidable)
		segment.set_collision_layer_value(0b1, collidable)

