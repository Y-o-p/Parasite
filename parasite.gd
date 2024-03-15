extends Node

var tutorial = [
	"It is safe inside",
	"You are outgrowing your home",
	"On those nearby, FEED"
]

var levels = [
	"res://Levels/level_1.tscn",
	"res://Levels/level_2.tscn"
]

var current_level = -1
var is_tutorial = false
var host_count = -1

func _ready():
	is_tutorial = true
	next_level()

func _process(delta):
	print(host_count)
	if host_count == 0:
		next_level()

func next_level():
	current_level += 1
	if current_level < len(levels):
		get_tree().change_scene_to_file(levels[current_level])

enum Wiggle {
	NONE,
	SQUASH,
	STRETCH,
	OSCILLATE
}
