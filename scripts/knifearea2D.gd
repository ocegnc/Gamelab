extends Area2D

@export var knockback_force = 300.0
@export var knockback_duration = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Baguette"):
		print("Touched")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_dir, knockback_force, knockback_duration)
