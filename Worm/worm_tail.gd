extends Node2D

var segments: Array[RigidBody2D] = []
var BODY_SEGMENT = preload("worm_segment.tscn")
@export var wiggle: Parasite.Wiggle = Parasite.Wiggle.NONE
@export var collidable: bool = true
@export var freeze: bool = false
@export var segment_count: int = 3
@export var latched_node: PhysicsBody2D
@export var wiggle_speed: int = 8
@export var speed_curve: Curve
signal added_length

func _ready():
	add_segments(segment_count)
	if latched_node != null:
		latch(latched_node)
	added_length.emit()

func _physics_process(delta):
	for segment in segments:
		segment.wiggle = wiggle

func add_segments(count):
	for i in range(count):
		var segment = BODY_SEGMENT.instantiate()
		if len(segments) > 0:
			segment.parent_segment = segments[-1]
			segments[-1].get_node("CollisionShape2D/Tail").add_child(segment)
		else:
			segment.parent_segment = latched_node
			add_child(segment)
		segments.append(segment)
	added_length.emit()

func latch(body):
	latched_node = body
	segments[0].get_node("Joint").node_a = latched_node.get_path()

func set_freeze(f):
	for segment in segments:
		segment.set_deferred("freeze", f)

func _on_added_length():
	for i in range(len(segments)):
		segments[i].set_collision_mask_value(0b10, collidable)
		segments[i].set_collision_layer_value(0b1, collidable)
		segments[i].speed = 10#i * 5 * speed_curve.sample(float(i) / len(segments))


