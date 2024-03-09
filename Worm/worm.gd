extends RigidBody2D

var body_segment = preload("worm_segment.tscn")

@onready var stop_force_timer: Timer = $StopForce
var worm_speed = 6000
@onready var segments = [self]
@onready var head: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print(segments)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_down") and stop_force_timer.is_stopped():
		var dir: Vector2 = ($CollisionShape2D/Nose.global_position - global_position).normalized()
		var desired_dir: Vector2 = (get_global_mouse_position() - $CollisionShape2D/Nose.global_position).normalized()
		add_constant_force(worm_speed * len(segments) * desired_dir)
		$StopForce.start()
	if Input.is_action_just_pressed("ui_up"):
		add_segment()

func add_segment():
	var segment = body_segment.instantiate()
	var joint: PinJoint2D = segment.get_node("Joint")
	joint.node_a = segments[-1].get_path()
	segments[-1].get_node("CollisionShape2D/Tail").add_child(segment)
	segments.append(segment)


func _on_stop_force_timeout():
	constant_force = Vector2(0, 0)
	stop_force_timer.stop()


func _on_body_entered(body):
	if body.name == "Host":
		latch(body)

func latch(body):
	var joint: PinJoint2D = PinJoint2D.new()
	set_head_invisible(true)
	set_segment_non_collidable(1)
	body.add_child(joint)
	joint.node_a = body.get_path()
	joint.node_b = segments[1].get_path()

func set_head_visible(vis):
	head.visible = vis
	set_collision_layer_value(0, vis)

func set_segment_non_collidable(index):
	pass
