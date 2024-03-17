extends Node2D

var HEAD = preload("worm_head.tscn")
var TAIL = preload("worm_tail.tscn")
var HOST = preload("res://host.tscn")
var BLOOD = preload("res://blood.tscn")

@onready var stop_force_timer: Timer = $StopForce
@onready var death_timer: Timer = $Death
@onready var blood_timer: Timer = $Blood
var worm_speed = 10000
var mouse_held = 0
@onready var head: Polygon2D = $CollisionShape2D/Polygon2D
@onready var camera: Camera2D = $Camera
@onready var dialogue: Label = $Dialogue

@export var spring: Curve
var hosts = []
var worm: RigidBody2D
var gestating: bool = true
var first_host: RigidBody2D
var dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	if gestating:
		first_host = HOST.instantiate()
		first_host.action = first_host.State.IDLE
		#first_host.get_node("Man").modulate = Color(0, 1, 0)
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
	death_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Parasite.time_remaining = death_timer.time_left
	Parasite.max_time = death_timer.wait_time
	Parasite.gestating = gestating
	
	
func _physics_process(delta):
	if not gestating and not dead:
		if Input.is_action_just_released("fling") and stop_force_timer.is_stopped():
			mouse_held = (Time.get_ticks_msec() - mouse_held) / 1000.0
			var sample = spring.sample(mouse_held)
			fling(worm_speed * sample)
		if Input.is_action_just_pressed("squash"):
			mouse_held = Time.get_ticks_msec()
		if Input.is_action_pressed("squash"):
			stop_force_timer.stop()
			worm.tail.wiggle = Parasite.Wiggle.SQUASH
		
func fling(speed):
	if worm.latched_body == null:
		var dir: Vector2 = (worm.get_node("CollisionShape2D/Nose").global_position - worm.global_position).normalized()
		var desired_dir: Vector2 = (worm.get_global_mouse_position() - worm.get_node("CollisionShape2D/Nose").global_position).normalized()
		_on_stop_force_timeout()
		worm.tail.wiggle = Parasite.Wiggle.NONE
		worm.add_constant_force(speed * len(worm.get_node("WormTail").segments) * desired_dir)
		stop_force_timer.start()

func _on_body_entered(body: PhysicsBody2D):
	if body.get_collision_layer_value(0b10):
		latch(body)

func latch(body):
	if worm.is_inside_tree() and not dead:
		worm.constant_force = Vector2(0, 0)
		death_timer.stop()
		camera.target = body
		body.action = body.State.PAIN
		hosts.append(body)
		worm.latch(body)
		$Kill.start()
		blood_timer.start()

func unlatch():
	worm.unlatch()
	blood_timer.stop()
	if Parasite.host_count > 0:
		death_timer.start()
	
func _on_stop_force_timeout():
	worm.constant_force = Vector2(0, 0)
	if worm.latched_body == null:
		worm.tail.wiggle = Parasite.Wiggle.NONE

func _on_kill_timeout():
	var added_length = 0
	camera.target = worm
	for host in hosts:
		host.die()
		Parasite.host_count -= 1
		if Parasite.host_count == 0:
			Parasite.next_level.emit()
		added_length += 3
	hosts.clear()
	
	unlatch()
	worm.tail.call_deferred("add_segments", added_length)
	fling(worm_speed * 1.5)

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


func _on_death_timeout():
	Parasite.death.emit()
	dead = true


func _on_blood_timeout():
	var blood = BLOOD.instantiate()
	blood.top_level = true
	blood.global_position = hosts[-1].global_position
	blood.global_rotation = Parasite.rng.randf_range(-PI, PI)
	
	hosts[-1].add_child(blood)
