extends Area2D

# Variable pour stocker la position d'origine de la baguette
@onready var screen_overlay := get_tree().root.get_node("Maze1/EffectLayer/ScreenOverlay") # Un ColorRect noir plein écran
var is_triggered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enregistrer la position d'origine de la baguette
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body) -> void:
	if is_triggered:
		return
	if not body is CharacterBody2D:
		return
	
	is_triggered = true
	print("🕳️ La baguette a touché un trou !")

	# Stopper les contrôles
	body.set_process(false)
	body.set_physics_process(false)

	# Animation : rotation + chute + réduction d’échelle
	var tween = create_tween()
	tween.tween_property(body, "rotation", deg_to_rad(720), 1.2)
	tween.parallel().tween_property(body, "scale", Vector2(0.1, 0.1), 1.2)
	tween.parallel().tween_property(body, "position:y", body.position.y + 100, 1.2)

	# Affichage du fondu écran noir
	screen_overlay.visible = true
	screen_overlay.color.a = 0
	tween.parallel().tween_property(screen_overlay, "color:a", 1.0, 1.2)

	await tween.finished
	await get_tree().create_timer(0.3).timeout

	Global.player_score = 0
	Global.skip_countdown_on_reload = true
	get_tree().reload_current_scene()
