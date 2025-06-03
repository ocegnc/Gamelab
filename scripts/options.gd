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
		$Panel/MusicToggle.text = "   Music: NO"
	else:
		$Panel/MusicToggle.text = "   Music: YES"
	Global.music_on = !Global.music_on


func _on_sound_effects_toggle_pressed() -> void:
	if Global.soundeffects_on:
		print("Effects stopped")
		$Panel/SoundEffectsToggle.text = "   Sound effects: NO"
	else:
		$Panel/SoundEffectsToggle.text = "   Sound effects: YES"
	Global.soundeffects_on = !Global.soundeffects_on
