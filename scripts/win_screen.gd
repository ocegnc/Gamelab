extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var score_label = $Panel2/ScoreLabel
@onready var score_list = $Panel2/ScoreList  # un VBoxContainer ou ItemList

func _ready() -> void:
	# Ajoute le dernier score dans la liste globale
	Global.scores.append({"name": Global.player_name, "score": Global.player_score})
	# Optionnel : trier la liste par score décroissant
	Global.scores.sort_custom(self._sort_scores)

	# Affiche le score du joueur
	score_label.text = "Good job %s ! You have collected %d aliments" % [Global.player_name, Global.player_score]

	# Affiche le tableau des scores
	# Supprimer tous les enfants avant d’ajouter les nouveaux
	for child in score_list.get_children():
		child.queue_free()
		
	for entry in Global.scores:
		var name = entry["name"]
		var score = entry["score"]
		var label = Label.new()
		label.text = "%s : %d" % [name, score]
		#label.add_color_override("font_color", Color(160, 107, 39))
		score_list.add_child(label)
		

func _sort_scores(a, b):
	# Tri décroissant par score
	return b["score"] - a["score"]


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
