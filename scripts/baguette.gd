extends CharacterBody2D

const SPEED = 50.0  # Vitesse normale
const BOOST_SPEED = 150.0  # Vitesse d'accélération

var direction_x = 1  # 1 = droite, -1 = gauche
var direction_y = 0  # 1 = bas, -1 = haut, 0 = neutre

var origin_position: Vector2  # Position d'origine

@onready var anim_player = $Run

func _ready() -> void: 
	if not has_meta("is_main_instance"):
		origin_position = global_position

func _physics_process(delta: float) -> void:
	# Changer la direction horizontale
	if Input.is_action_just_pressed("ui_right"):
		direction_x = 1
	elif Input.is_action_just_pressed("ui_left"):
		direction_x = -1
	
	# Changer la direction verticale
	if Input.is_action_just_pressed("ui_up"):
		direction_y = -1
	elif Input.is_action_just_pressed("ui_down"):
		direction_y = 1

	# Déplacement en continu dans la dernière direction connue
	velocity.x = direction_x * SPEED
	velocity.y = direction_y * SPEED

	# Accélération si une touche est maintenue
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		velocity.x = direction_x * BOOST_SPEED
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		velocity.y = direction_y * BOOST_SPEED

	# Gestion des animations
	if velocity.x != 0 or velocity.y != 0:
		anim_player.play("run")
	else:
		anim_player.stop()

	move_and_slide()
# Reset la position du personnage
func reset_position() -> void:
	velocity = Vector2.ZERO 
	direction_x = 1  # Reset vers la droite par défaut
	direction_y = 0  # Reset du mouvement vertical
	
func reset_position_trou() -> void:
	velocity = Vector2.ZERO 
	direction_x = 1  # Reset vers la droite par défaut
	direction_y = 0  # Reset du mouvement vertical
