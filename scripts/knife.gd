extends CharacterBody2D

const SPEED = 10


const left_limit = 10
const right_limit = 10

@export var knockback_force = 300.0
@export var knockback_duration = 0.5

@onready var anim_player = $knifemoove
@onready var hitbox = $Hitbox/CollisionShape2D
var direction = -1


func _ready() -> void:
	global_position.x = right_limit
	anim_player.play("knifemoove")

func _physics_process(delta: float) -> void:	
	velocity.x=SPEED*direction
	move_and_slide()
	
func change_direction():
	direction *= -1
	$Sprite2D2.scale.x = -direction

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var knockback_dir = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_dir, knockback_force, knockback_duration)
