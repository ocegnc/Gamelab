extends Area2D

@onready var sprite = $AnimatedSprite2D
var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = randi_range(0, 19)
	connect("body_entered",_on_body_entered)
	add_to_group("aliments")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var has_collided := false

func _on_body_entered(body: Node2D) -> void:
	if has_collided:
		return

	if body is CharacterBody2D:
		Global.player_score += 1
		# Obtenir la scène principale et appeler sa méthode
		var maze = get_tree().get_current_scene()
		if maze.has_method("_on_score_updated"):
			maze._on_score_updated(Global.player_score)
			
		has_collided = true
		sprite.visible = false
		if Global.soundeffects_on:
			$SoundEffect.play()
			await $SoundEffect.finished
		queue_free()
		if main:
			main.mark_aliment_collected(self)
