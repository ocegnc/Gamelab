extends Area2D

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = randi_range(0, 39)
	connect("body_entered",_on_body_entered)
	add_to_group("aliments")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D,) -> void:
	if body is CharacterBody2D:
		sprite.visible = false  # Cache le sprite
		queue_free()  # Supprime complètement le node
	if (body.name == "Baguette"):
		body.aliment_ramasse()
		
