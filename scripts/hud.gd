extends Control
class_name HUD

@export var stopwatch: Stopwatch  # Sera assigné depuis Maze1
@onready var stopwatch_label: Label = $Stopwatchlabel  # Assurez-vous que le chemin correspond à votre structure

func _process(delta):
	print("Stopwatch time: ", stopwatch.time if stopwatch else "null")
	if stopwatch and stopwatch_label:
		stopwatch_label.text = stopwatch.time_to_string()
