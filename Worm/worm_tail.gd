extends Node2D

var segments = []
var body_segment = preload("worm_segment.tscn")
@export var segment_count: int = 3
@export var latched_node: PhysicsBody2D

func _ready():
	for i in range(segment_count):
		add_segment()
	if latched_node != null:
		latch(latched_node)

func add_segments(count):
	call_deferred("add_segment")
	if count > 1:
		call_deferred("add_segments", count - 1)

func add_segment():
	var segment = body_segment.instantiate()
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
