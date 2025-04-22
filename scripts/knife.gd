extends CharacterBody2D

const SPEED = 200.0
var direction = -1

const left_limit = 300
const right_limit = 800

@onready var anim_player = $knifemoove


func _ready() -> void:
	global_position.x = right_limit
	anim_player.play("knifemoove")


func _physics_process(delta: float) -> void:

	# Déplacement
	velocity.x = direction * SPEED

	# Bascule de direction aux limites
	if global_position.x >= right_limit:
		direction = -1
		$Sprite2D2.scale.x = -direction
	elif global_position.x <= left_limit:
		direction = 1
		$Sprite2D2.scale.x = -direction
	move_and_slide()
