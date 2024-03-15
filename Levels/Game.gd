extends Node

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var gray: ColorRect = $HUD/Gray
@onready var hosts_left_label: Label = $HUD/SubViewportContainer/SubViewport/Control/HostsLeft
@onready var time_remaining_label: Label = $HUD/SubViewportContainer/SubViewport/Control/TimeRemaining
@onready var death_label: Label = $HUD/SubViewportContainer/SubViewport/Control/Death
var game_over: bool = false
var interp: float = 0

func _init():
	Parasite.connect("next_level", on_next_level)
	Parasite.connect("death", on_death)

func _ready():
	Parasite.is_tutorial = true
	next_level()

func _process(delta):
	hosts_left_label.text = "Hosts: " + str(Parasite.host_count)
	time_remaining_label.text = "Time Remaining: " + str(Parasite.time_remaining)
	"shader_parameter/gray_ratio"
	if not game_over:
		if Parasite.time_remaining == 0.0:
			interp = lerp(interp, 0.0, 0.03)
		else:
			interp = lerp(interp, (Parasite.max_time - Parasite.time_remaining) / Parasite.max_time, 0.08)
	gray.material.set_shader_parameter("blur_amount", interp)
	gray.material.set_shader_parameter("gray_ratio", interp)

func _input(event):
	if event.is_action_released("restart"):
		restart()

func restart():
	animator.play("RESET")
	game_over = false
	if Parasite.level != null:
		remove_child(Parasite.level)
	Parasite.level = Parasite.levels[Parasite.current_level].instantiate()
	add_child(Parasite.level)

func next_level():
	Parasite.current_level += 1
	$HUD/NextLevel/Level.text = "Level " + str(Parasite.current_level + 2)
	if Parasite.current_level < len(Parasite.levels):
		if Parasite.level != null:
			remove_child(Parasite.level)
		Parasite.level = Parasite.levels[Parasite.current_level].instantiate()
		add_child(Parasite.level)

func on_death():
	animator.play("death")
	game_over = true

func on_next_level():
	animator.play("next_level")
