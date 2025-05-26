extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_music_toggle_pressed() -> void:
	if Global.music_on:
		print("Music stopped")
		#music_toggle_button.text = "🔇"
	else:
		pass
		#music_toggle_button.text = "🎵"

	Global.music_on = !Global.music_on
