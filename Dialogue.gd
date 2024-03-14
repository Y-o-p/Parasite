extends Label

@export var dialogue: Array[String] = [
	"First Line",
	"Second Line"
]

var current_line = -1

signal out_of_dialogue
signal started_line
signal finished_line

func _ready():
	next_line()

func _input(event):
	if event.is_action_released("fling"):
		next_line()

func next_line():
	current_line += 1
	if current_line < len(dialogue):
		started_line.emit()
		text = dialogue[current_line]
		visible_characters = 0
		$Talking.start()
	else:
		out_of_dialogue.emit()

func _on_talking_timeout():
	if current_line < len(dialogue):
		visible_characters += 1
		if visible_characters == len(dialogue[current_line]):
			$Talking.stop()
			finished_line.emit()
