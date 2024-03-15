extends Node

@onready var animator: AnimationPlayer = $AnimationPlayer

func _init():
	Parasite.connect("next_level", on_next_level)
	Parasite.connect("death", on_death)

func _ready():
	Parasite.is_tutorial = true
	next_level()

func _process(delta):
	$HUD/Control/HostsLeft.text = "Hosts: " + str(Parasite.host_count)
	$HUD/Control/TimeRemaining.text = "Time Remaining: " + str(Parasite.time_remaining)

func _input(event):
	if event.is_action_released("restart"):
		restart()

func restart():
	animator.play("RESET")
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

func on_next_level():
	animator.play("next_level")
