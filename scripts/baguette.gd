extends CharacterBody2D

# Variables de mouvement
var current_speed = 50.0
const BASE_SPEED = 50.0
const BOOST_SPEED = 150.0

# Variables de contrôle
var direction_x = 1  # 1 = droite, -1 = gauche
var direction_y = 0  # 1 = bas, -1 = haut, 0 = neutre
var origin_position: Vector2
var is_knockback = false
var knockback_velocity = Vector2.ZERO

# Système de victoire
var aliments_ramasses = 0
var total_aliments = 4

# Références



var score = 0



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
	
	handle_movement_input()
	calculate_velocity()
	apply_boost()
	update_animation()
	move_and_slide()

func handle_movement_input():
	if Input.is_action_just_pressed("ui_right"):
		direction_x = 1
	elif Input.is_action_just_pressed("ui_left"):
		direction_x = -1
	
	if Input.is_action_just_pressed("ui_up"):
		direction_y = -1
	elif Input.is_action_just_pressed("ui_down"):
		direction_y = 1

func calculate_velocity():
	velocity.x = direction_x * current_speed
	velocity.y = direction_y * current_speed

func apply_boost():
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		velocity.x = direction_x * BOOST_SPEED
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		velocity.y = direction_y * BOOST_SPEED

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
func aliment_ramasse():
	aliments_ramasses += 1
	print(aliments_ramasses)
	if aliments_ramasses == 6:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
		print("win")
