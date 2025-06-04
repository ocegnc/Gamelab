extends CharacterBody2D
@onready var GameState = preload("res://scripts/game_state.gd")
# Variables de mouvement
var current_speed = 50.0
const BASE_SPEED = 50.0
const MAX_SPEED = 300.0
const ACCELERATION = 200.0
const DECELERATION = 400.0

# Variables de contrôle
var direction_x = 1  # 1 = droite, -1 = gauche
var direction_y = 0  # 1 = bas, -1 = haut, 0 = neutre
var origin_position: Vector2
var is_knockback = false
var knockback_velocity = Vector2.ZERO

# Système de victoire
var total_aliments = 4

@onready var score = $Score
@onready var anim_player = $Run
@onready var sprite = $Sprite2D

func _ready() -> void:
	if not has_meta("is_main_instance"):
		origin_position = global_position
	add_to_group("player")
	
	# Initialisation du système de victoire
	total_aliments = get_tree().get_nodes_in_group("aliments").size()

func _physics_process(delta: float) -> void:
	if is_knockback:
		velocity = knockback_velocity
		move_and_slide()
		return
	
	#score.text = "Score : " + str(Global.score)
	#print(score)
	
	handle_movement_input()
	update_speed(delta)
	calculate_velocity()
	update_animation()
	move_and_slide()

func handle_movement_input():
	# On vérifie les directions pressées
	var horizontal = 0
	var vertical = 0
	
	if Input.is_action_pressed("move_right"):
		horizontal = 1
	elif Input.is_action_pressed("move_left"):
		horizontal = -1
	
	if Input.is_action_pressed("move_up"):
		vertical = -1
	elif Input.is_action_pressed("move_down"):
		vertical = 1
	
	# Priorité : si horizontal est différent de zéro, on bouge horizontalement seulement
	# Sinon on bouge verticalement
	if horizontal != 0:
		direction_x = horizontal
		direction_y = 0
	elif vertical != 0:
		direction_y = vertical
		direction_x = 0
	# Si aucune touche, on garde la dernière direction (pas de remise à zéro)

	
	# Ne PAS remettre direction_x ou direction_y à zéro au relâchement de la touche
	# Cela permet de garder la dernière direction même quand aucune touche n'est pressée

func update_speed(delta: float) -> void:
	var is_accelerating = Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") \
						or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")
	
	if is_accelerating:
		current_speed = min(current_speed + ACCELERATION * delta, MAX_SPEED)
	else:
		current_speed = BASE_SPEED

func calculate_velocity():
	velocity.x = direction_x * current_speed
	velocity.y = direction_y * current_speed

func update_animation():
	if velocity.x != 0 or velocity.y != 0:
		anim_player.play("run")
	else:
		anim_player.stop()

func apply_knockback(direction: Vector2, force: float, duration: float = 0.3):
	if is_knockback:
		return
	
	is_knockback = true
	knockback_velocity = direction * force
	current_speed = BASE_SPEED * 0.3
	
	play_knockback_effects(duration)
	
	await get_tree().create_timer(duration).timeout
	reset_after_knockback()

func play_knockback_effects(duration: float):
	var flash_tween = create_tween()
	flash_tween.tween_property(sprite, "modulate:a", 0.5, 0.05)
	flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	flash_tween.set_loops(int(duration / 0.1))

func reset_after_knockback():
	current_speed = BASE_SPEED
	is_knockback = false
	knockback_velocity = Vector2.ZERO
																																																																																																		
# Fonction à appeler quand la baguette ramasse un aliment
