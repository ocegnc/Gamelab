extends Area2D

@onready var sprite = $AnimatedSprite2D
#var maze = preload("res://scenes/Maze1.tscn").instantiate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = randi_range(0, 19)
	connect("body_entered",_on_body_entered)
	add_to_group("bad-aliments")

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("BEURKKKKK")
		sprite.visible = false
		#maze.make_loose_time()
		queue_free()

		
