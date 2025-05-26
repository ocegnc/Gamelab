extends Node

var score = 0
signal score_updated

# Singleton pattern
static var instance: GameState

func _init():
	instance = self

func add_score(value: int):
	score += value
	emit_signal("score_updated", score)
