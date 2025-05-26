extends Area2D

@onready var sprite = $AnimatedSprite2D

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
		has_collided = true
		$SoundEffect.play()
		sprite.visible = false
		await $SoundEffect.finished
		queue_free()
