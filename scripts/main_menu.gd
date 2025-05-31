extends Control

@onready var player_name_input = $player_name_input

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_started_pressed() -> void:
	var player_name_input = $VBoxContainer/player_name_input
	var player_name = player_name_input.text.strip_edges()
	if player_name == "":
		player_name = "Player"  # valeur par défaut si vide
	# Passer le nom au niveau de jeu via autoload singleton ou via paramètres
	Global.player_name = player_name
	get_tree().change_scene_to_file("res://scenes/Maze1.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
