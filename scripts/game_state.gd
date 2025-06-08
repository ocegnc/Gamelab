extends Node

var score = 0:
	set(value):
		score = value
		emit_signal("score_updated", score)
signal score_updated

# Singleton pattern
static var instance: GameState

func _init():
	instance = self
