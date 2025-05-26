extends CharacterBody2D

const SPEED = 10

@export var knockback_force = 300.0
@export var knockback_duration = 0.5

@onready var anim_player = $knifemoove
@onready var hitbox = $Hitbox/CollisionShape2D
var direction = -1


func _ready() -> void:
	anim_player.play("knifemoove")

func _physics_process(delta: float) -> void:	
	velocity.x=SPEED*direction
	move_and_slide()
	
func change_direction():
	direction *= -1
	$Sprite2D2.scale.x = -direction
