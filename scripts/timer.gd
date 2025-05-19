extends Node
class_name Stopwatch

var time = 0.0
var stopped = false 

func _process(delta):
	if not stopped:
		time += delta  # Accumule le temps

func time_to_string() -> String:
	var msec = fmod(time, 1) * 100
	var sec = fmod(time, 60)
	var min = fmod(time, 3600) / 60
	return "%02d:%02d:%02d" % [min, sec, msec]
