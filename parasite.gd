extends Node

var tutorial = [
	"It is safe inside",
	"You are outgrowing your home",
	"On those nearby, FEED"
]

var levels = [
	preload("res://Levels/level_1.tscn"),
	preload("res://Levels/level_2.tscn")
]

var max_time: float = 3.0
var time_remaining: float = 3.0

var current_level = -1
var is_tutorial = false
var host_count = -1
var level

signal next_level
signal death


enum Wiggle {
	NONE,
	SQUASH,
	STRETCH,
	OSCILLATE
}
