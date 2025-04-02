extends RigidBody2D

const SPEED = 100.0  # Vitesse du couteau
var direction = -1  # 1 = droite, -1 = gauche

var left_limit = 300  # Position X minimale
var right_limit = 800  # Position X maximale

@onready var anim_player = $knifemoove

func _ready() -> void:
	# Facultatif : Placer le couteau à une position de départ
	global_position.x = right_limit

func _process(delta: float) -> void:
	
	anim_player.play("knifemoove")
	
	
	# Déplacer le couteau
	global_position.x += direction * SPEED * delta

	# Changer de direction aux limites
	if global_position.x >= right_limit:
		direction = -1  # Repart vers la gauche
	elif global_position.x <= left_limit:
		direction = 1  # Repart vers la droite

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Touched")
		if body.has_method("reset_position"):
			pass
