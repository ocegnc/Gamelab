extends CanvasLayer

@onready var play_button = $Panel/VBoxContainer/play_button
@onready var restart_button = $Panel/VBoxContainer/restart_button
@onready var menu_button = $Panel/VBoxContainer/Menu_button

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_play_pressed():
	get_tree().paused = false
	visible = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
