extends Node

var tutorial = [
	"It is safe inside",
	"You are outgrowing your home",
	"On those nearby, FEED"
]

var is_tutorial = false

func _ready():
	get_tree().change_scene_to_file("res://Levels/level_1.tscn")
	is_tutorial = true

enum Wiggle {
	NONE,
	SQUASH,
	STRETCH,
	OSCILLATE
}
