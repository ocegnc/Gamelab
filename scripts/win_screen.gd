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

	var player_name = Global.player_name.strip_edges()
	if player_name == "":
		player_name = "unknown"
	# Affiche le score du joueur
	if Global.player_score == 0:
		score_label.text = "Nothing to eat ... you should try again !!"
	else:
		score_label.text = "Good job %s ! You have collected %d aliments" % [player_name, Global.player_score]

	# Affiche le tableau des scores
	# Supprimer tous les enfants avant d’ajouter les nouveaux
	for child in score_list.get_children():
		child.queue_free()
		
	for i in range(min(5, Global.scores.size())):
		var entry = Global.scores[i]
		var name = str(entry["name"]).strip_edges()
		if name == "":
			name = "unknown"
		var score = entry["score"]
		var label = Label.new()
		label.text = "%d. %s : %d" % [i + 1, name, score]
		score_list.add_child(label)

func _sort_scores(a, b):
	# Tri décroissant par score
	return b["score"] - a["score"]

func _on_home_button_pressed() -> void:
	Global.player_score = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_replay_pressed() -> void:
	Global.player_score = 0
	get_tree().change_scene_to_file("res://scenes/Maze1.tscn") 


func _on_replay_button_pressed() -> void:
	pass # Replace with function body.
