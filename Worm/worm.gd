extends Node

var HEAD = preload("worm_head.tscn")
var TAIL = preload("worm_tail.tscn")
var HOST = preload("res://host.tscn")

@onready var stop_force_timer: Timer = $StopForce
var worm_speed = 6000
@onready var head: Polygon2D = $CollisionShape2D/Polygon2D
@onready var camera: Camera2D = $Camera
@onready var dialogue: Label = $Dialogue

var hosts = []
var worm: RigidBody2D
var gestating: bool = true
var first_host: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if gestating:
		first_host = HOST.instantiate()
		first_host.get_node("Man").modulate = Color(0, 1, 0)
		add_child(first_host)
		
		camera.target = first_host
		camera.desired_size = 1.0
	else:
		spawn()

func spawn():
	worm = HEAD.instantiate()
	worm.connect("body_entered", _on_body_entered)
	add_child(worm)
	camera.target = worm
	camera.desired_size = 1
	worm.tail.set_deferred("wiggle_speed", 15)
	gestating = false
	remove_child(first_host)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if not gestating:
		if Input.is_action_just_pressed("ui_right"):
			unlatch()
		if Input.is_action_just_released("fling") and stop_force_timer.is_stopped():
			fling(worm_speed)
		if Input.is_action_just_pressed("squash"):
			worm.tail.wiggle = Parasite.Wiggle.SQUASH
		
func fling(speed):
	var dir: Vector2 = (worm.get_node("CollisionShape2D/Nose").global_position - worm.global_position).normalized()
	var desired_dir: Vector2 = (worm.get_global_mouse_position() - worm.get_node("CollisionShape2D/Nose").global_position).normalized()
	worm.tail.wiggle = Parasite.Wiggle.NONE
	worm.add_constant_force(speed * len(worm.get_node("WormTail").segments) * desired_dir)
	stop_force_timer.start()

func _on_body_entered(body: PhysicsBody2D):
	if body.get_collision_layer_value(0b10):
		latch(body)

func latch(body):
	if worm.is_inside_tree():
		camera.target = body
		var host_tail = TAIL.instantiate()
		host_tail.latched_node = body
		host_tail.wiggle = Parasite.Wiggle.OSCILLATE
		host_tail.segment_count = len(worm.tail.segments)
		host_tail.collidable = false
		body.add_child(host_tail)
		var entry_angle = body.global_position.angle_to_point(worm.contact_position)
		host_tail.rotate(-PI/2.0 + entry_angle)
		host_tail.latch(body)
		hosts.append(body)
		worm.set_deferred("freeze", true)
		worm.get_node("WormTail").set_freeze(true)
		#worm.set_freeze_mode(RigidBody2D.FREEZE_MODE_KINEMATIC)
		#worm.set_freeze_enabled(true)
		call_deferred("remove_child", worm)
		$Kill.start()

func unlatch():
	if len(hosts) > 0:
		worm.global_position = hosts[-1].global_position
	worm.set_deferred("freeze", false)
	worm.get_node("WormTail").set_freeze(false)
	add_child(worm)
	
func _on_stop_force_timeout():
	worm.constant_force = Vector2(0, 0)
	worm.tail.wiggle = Parasite.Wiggle.NONE

func _on_kill_timeout():
	var added_length = 0
	camera.target = worm
	for host in hosts:
		host.die()
		Parasite.host_count -= 1
		added_length += 3
	hosts.clear()
	
	unlatch()
	worm.tail.call_deferred("add_segments", added_length)
	call_deferred("fling", worm_speed * 1.5)

func _on_dialogue_finished_line():
	pass
	#camera.desired_size += 0.2

func _on_dialogue_started_line():
	if camera != null:
		camera.desired_size += 0.2

func _on_dialogue_out_of_dialogue():
	if gestating:
		spawn()
		fling(worm_speed)
		dialogue.hide()
