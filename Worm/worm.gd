extends Node

var HEAD = preload("worm_head.tscn")
var TAIL = preload("worm_tail.tscn")

@onready var stop_force_timer: Timer = $StopForce
var worm_speed = 6000
@onready var head: Polygon2D = $CollisionShape2D/Polygon2D

var hosts = []
var worm: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	worm = HEAD.instantiate()
	worm.connect("body_entered", _on_body_entered)
	add_child(worm)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right"):
		unlatch()
	if Input.is_action_just_pressed("ui_down") and stop_force_timer.is_stopped():
		fling(worm_speed)
		
func fling(speed):
	var dir: Vector2 = (worm.get_node("CollisionShape2D/Nose").global_position - worm.global_position).normalized()
	var desired_dir: Vector2 = (worm.get_global_mouse_position() - worm.get_node("CollisionShape2D/Nose").global_position).normalized()
	worm.add_constant_force(speed * len(worm.get_node("WormTail").segments) * desired_dir)
	stop_force_timer.start()

func _on_body_entered(body):
	if body.name == "Host":
		latch(body)

func latch(body):
	print("Latching")
	if worm.is_inside_tree():
		var host_tail = TAIL.instantiate()
		body.add_child(host_tail)
		host_tail.latch(body)
		hosts.append(body)
		remove_child(worm)
		$Kill.start()

func unlatch():
	if len(hosts) > 0:
		worm.global_position = hosts[-1].global_position
	add_child(worm)
	
func _on_stop_force_timeout():
	worm.constant_force = Vector2(0, 0)


func _on_kill_timeout():
	var added_length = 0
	for host in hosts:
		host.die()
		added_length += 3
	
	unlatch()
	for i in range(added_length):
		worm.get_node("WormTail").add_segment()
	fling(worm_speed * 1.5)
