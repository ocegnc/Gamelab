extends Area2D

@onready var sprite = $AnimatedSprite2D
#var maze = preload("res://scenes/Maze1.tscn").instantiate()
signal bad_aliment_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = randi_range(0, 19)
	connect("body_entered",_on_body_entered)
	add_to_group("bad-aliments")

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var has_collided := false

func _on_body_entered(body: Node2D) -> void:
	if has_collided:
		return

	if body is CharacterBody2D:
		print("BEURKKKK")
		has_collided = true
		sprite.visible = false
		if Global.soundeffects_on:
			$SoundEffect.play()
			await $SoundEffect.finished
		queue_free()
		if emit_signal("bad_aliment_collected") : 
			print("Signal bad_aliment_collected émis !")

		


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
