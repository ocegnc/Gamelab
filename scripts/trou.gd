extends Area2D

# Variable pour stocker la position d'origine de la baguette


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enregistrer la position d'origine de la baguette
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body) -> void:
	if body is CharacterBody2D:
		print("Touched")
		GameState.instance.score = 0
		get_tree().reload_current_scene()
