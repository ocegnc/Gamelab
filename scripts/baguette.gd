extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -400.0

var SCORE = 3
var origin_position: Vector2  # Var to stock position 

@onready var anim_player = $Run

func _ready() -> void:
	# Register the origin position of the baguette
	origin_position = global_position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var horizontal_direction := Input.get_axis("ui_left", "ui_right")
	var vertical_direction := Input.get_axis("ui_up", "ui_down")
	if horizontal_direction or vertical_direction:
		velocity.x = horizontal_direction * SPEED
		velocity.y = vertical_direction * SPEED
		anim_player.play("run") 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		anim_player.stop()

	move_and_slide()

# Reset baguette position
func reset_position() -> void:
	global_position = origin_position
	velocity = Vector2.ZERO 

	
