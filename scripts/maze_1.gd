extends Node2D
@onready var tile_map_layer = $TileMapLayer
@onready var player = preload("res://scenes/baguette.tscn")
@onready var trap_scene = preload("res://scenes/traps.tscn")
@onready var trou_scene = preload("res://scenes/traps/trou.tscn")
@onready var knife_scene = preload("res://scenes/traps/knife.tscn")
@onready var aliment_scene = preload("res://scenes/aliments.tscn")
@onready var GameState = preload("res://scripts/game_state.gd")
@onready var label: Label
@onready var scorelabel : Label
var floor_tile_top := Vector2i(1,2)
var floor_tile := Vector2i(2,3)
var floor_tile_bottom := Vector2i(3,3)
var wall_tile_top := Vector2i(1,0)
var wall_tile_bottom := Vector2i(8,2)
var wall_tile := Vector2i(1,1)
var wall_tile_broke := Vector2i(5,1)
var wall_tile_broke_bottom := Vector2i(5,2)
var wall_tile_left_side := Vector2i(7,2)
var wall_tile_right_side := Vector2i(9,2)
var wall_tile_left_side_top := Vector2i(6,3)
var wall_tile_right_side_top := Vector2i(4,3)
var tile_ketchup := Vector2i(3, 1)
var tile_ketchup_bottom := Vector2i(3, 2)
var tile_mayo := Vector2i(4, 1)
var tile_mayo_bottom := Vector2i(4, 2)
var wall_corner_left := Vector2i(7, 0)
var wall_corner_right := Vector2i(9, 0)
var wall_corner_left_bottom := Vector2i(7, 4)
var wall_corner_right_bottom := Vector2i(9, 4)
var wall_corner_right3 := Vector2i(10, 2)
var wall_corner_left3 := Vector2i(11, 2)
var wall_angle_right := Vector2i(10, 4)
var wall_angle_left := Vector2i(11, 4)


 # Constants defining the grid size, cell size, and room parameters
const WIDTH = 80  # Augmenté pour accommoder 9 salles
const HEIGHT = 80
var FIXED_ROOMS = []
var sizes = [7, 8, 9, 11, 14]
var positions = [
 	# Format: [x, y, width, height]
 	# Première ligne (haut)
 	[5, 5],    # Haut-gauche
 	[25, 5],    # Haut-centre
 	[45, 5],    # Haut-droite
 
 	# Deuxième ligne (milieu)
 	[5, 26],    # Centre-gauche
 	[25, 26],  # Grande salle centrale
 	[45, 26],    # Centre-droite
 
 	# Troisième ligne (bas)
 	[5, 45],    # Bas-gauche
 	[25, 45],    # Bas-centre
 	[45, 45]     # Bas-droite
 ]

	
const ROOM_TEMPLATES = [
 	# Format: [largeur, hauteur]
 	[5, 5],  # Petite salle carrée
 	[7, 7],  # Salle moyenne
 	[10, 10], # Salle rectangulaire large
 	[5, 10], # Salle rectangulaire haute
 	[8, 8]   # Grande salle carrée
 ]
 # Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []
 
func _ready():
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1
	scorelabel=Label.new()
	scorelabel.name="ScoreLabel"
	scorelabel.text="Score: 0"
	scorelabel.position = Vector2(20, 20)  # Position différente du timer
	scorelabel.add_theme_font_size_override("font_size", 30)
	scorelabel.add_theme_color_override("font_color", Color.WHITE)
	GameState.instance.score_updated.connect(_on_score_updated)
	scorelabel.text = "Score: 0"
	
	
	label = Label.new()
	label.name = "TimerLabel"
	label.text = "00:00:00"
	label.position = Vector2(get_viewport().size.x / 2 - 50, 20)  # Position centrée en haut
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.WHITE)
	canvas_layer.add_child(scorelabel)
	canvas_layer.add_child(label)
	add_child(canvas_layer)
	
	# Mettez à jour dans _process
var time = 0.0
func _process(delta):
	time += delta
	var msec = fmod(time, 1) * 100
	var sec = fmod(time, 60)
	var min = fmod(time, 3600) / 60
	label.text = "%02d:%02d:%02d" % [min, sec, msec]
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)



func _on_score_updated(new_score):
	if scorelabel:
		scorelabel.text = "Score: %d" % new_score
		print("Score mis à jour: ", new_score) 




func update_score(value: int):
	if scorelabel:
		scorelabel.text = "Score: %d" % value



func generate_dungeon():
	# Génération des salles avec taille carrée aléatoire
	for pos in positions:
		var size = sizes[randi() % sizes.size()]
		FIXED_ROOMS.append([pos[0], pos[1], size, size])

	print("FIXED_ROOMS = ", FIXED_ROOMS)
	
	# Place toutes les salles d'abord
	for room_data in FIXED_ROOMS:
		var room = Rect2(room_data[0], room_data[1], room_data[2], room_data[3])
		place_room(room)
		rooms.append(room)
 
	# Connecte toutes les salles adjacentes
	if rooms.size() == 9:
 		# Ligne du haut
		connect_rooms(rooms[0], rooms[1])
		connect_rooms(rooms[1], rooms[2])
 
 		# Ligne du milieu
		connect_rooms(rooms[3], rooms[4])
		connect_rooms(rooms[4], rooms[5])
 
 		# Ligne du bas
		connect_rooms(rooms[6], rooms[7])
		connect_rooms(rooms[7], rooms[8])
 
		# Colonnes verticales
		connect_rooms(rooms[0], rooms[3])
		connect_rooms(rooms[3], rooms[6])
 
		connect_rooms(rooms[1], rooms[4])
		connect_rooms(rooms[4], rooms[7])
 
		connect_rooms(rooms[2], rooms[5])
		connect_rooms(rooms[5], rooms[8])
 
 
func generate_room():
	# Choisis un template aléatoire parmi ceux disponibles
	var template = ROOM_TEMPLATES[randi() % ROOM_TEMPLATES.size()]
	var width = template[0]
	var height = template[1]
 
	# Positionne la salle aléatoirement dans la grille
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
 
	return Rect2(x, y, width, height)
 
 # Attempts to place the room on the grid, ensuring no overlap with existing rooms
func place_room(room):
	# Check if the room overlaps with any existing floors (cells set to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:  # If the cell is already a floor
				return false  # Room cannot be placed, return false
 
	# If no overlap is found, mark the room area as floors (set cells to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # 0 represents a floor
	return true  # Room successfully placed, return true
 
 # Connects two rooms with a corridor, allowing for a customizable corridor width
func connect_rooms(room1, room2, corridor_width=1):
	# Determine the starting point for the corridor (center of room1)
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
 	# Determine the ending point for the corridor (center of room2)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
 
	var current = start
 
	# First, move horizontally towards the end point
	while current.x != end.x:
		# Move one step left or right
		current.x += 1 if end.x > current.x else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
 				# Ensure we don't go out of grid bounds
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
	# Then, move vertically towards the end point
	while current.y != end.y:
		# Move one step up or down
		current.y += 1 if end.y > current.y else -1
 		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
func is_floor_edge_tile(tile: Vector2i) -> bool:
	return tile == floor_tile_top or tile == tile_ketchup_bottom or tile == tile_mayo_bottom or tile == wall_tile_broke_bottom

func is_wall_decor_tile(tile: Vector2i) -> bool:
	return tile == wall_tile or tile == wall_tile_broke or tile == tile_ketchup or tile == tile_mayo

func is_valid_tile(tile: Vector2i) -> bool:
	return tile != Vector2i(-1, -1)

func draw_dungeon():
	
	var fixed_room = FIXED_ROOMS[0]  # [x, y, width, height]
	var room_x = fixed_room[0]
	var room_y = fixed_room[1]
	var room_width = fixed_room[2]
	var room_height = fixed_room[3]

	var center_x = room_x + room_width / 2
	var center_y = room_y + room_height / 2

	var tile_coords = Vector2i(center_x, center_y)
	var baguette_pos = tile_map_layer.map_to_local(tile_coords)

	var baguette = player.instantiate()
	baguette.scale = Vector2(0.02, 0.02)
	baguette.position = baguette_pos
	add_child(baguette)
			
	for x in range(WIDTH):
		var y = 0
		while y <= HEIGHT - 6:
			var sequence = []
			for offset in range(6):
				sequence.append(grid[x][y + offset])

			# Vérifie que c’est bien un motif valide
			if sequence[3] == 0:
				# 1) wall_tile_top
				tile_map_layer.set_cell(Vector2i(x, y), 0, wall_tile_top)

				# 2) décor mural							
				var rand = randi() % 100
				var decor_tile = wall_tile

				if rand < 55:
					decor_tile = wall_tile
				elif rand < 70:
					decor_tile = tile_ketchup
				elif rand < 85:
					decor_tile = tile_mayo
				else:
					decor_tile = wall_tile_broke

				tile_map_layer.set_cell(Vector2i(x, y + 1), 0, decor_tile)

				# 3) top floor selon décor
				if decor_tile == tile_ketchup:
					tile_map_layer.set_cell(Vector2i(x, y + 2), 0, tile_ketchup_bottom)
				elif decor_tile == tile_mayo:
					tile_map_layer.set_cell(Vector2i(x, y + 2), 0, tile_mayo_bottom)
				elif decor_tile == wall_tile_broke:
					tile_map_layer.set_cell(Vector2i(x, y + 2), 0, wall_tile_broke_bottom)
				else:
					tile_map_layer.set_cell(Vector2i(x, y + 2), 0, floor_tile_top)

				# Déterminer la hauteur dynamique du sol
				var floor_start = y + 3
				var floor_height = 0
				while floor_start + floor_height < HEIGHT and grid[x][floor_start + floor_height] == 0:
					floor_height += 1

				# Poser les tuiles de sol
				for i in range(floor_height - 1):  # -1 pour laisser place au "bottom"
					tile_map_layer.set_cell(Vector2i(x, floor_start + i), 0, floor_tile)

				# Poser le sol du bas
				if floor_height > 0:
					tile_map_layer.set_cell(Vector2i(x, floor_start + floor_height - 1), 0, floor_tile_bottom)

				# Poser un mur de fin s'il y a encore de la place
				if floor_start + floor_height < HEIGHT:
					var end_wall_tile = wall_tile if randi() % 100 < 70 else wall_tile_broke
					tile_map_layer.set_cell(Vector2i(x, floor_start + floor_height), 0, end_wall_tile)
					# Poser une tuile en dessous du mur de fin si on est encore dans les limites
					var below_end_wall_pos = floor_start + floor_height + 1
					if below_end_wall_pos < HEIGHT:
						tile_map_layer.set_cell(Vector2i(x, below_end_wall_pos), 0, wall_tile_bottom)  # ou autre tuile

				# Sauter tout ce qu’on vient de traiter
				y += 3 + floor_height + 2  # 3 (haut) + sol + mur de fin

			else:
				# Aucun motif → effacer la colonne actuelle sur cette bande
				tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(-1, -1))
				y += 1
		
	# 1. Phase : placement des tuiles de sol
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)

			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile)

	# 2. Phase : placement des murs + logique spéciale
	for x in range(1, WIDTH - 1):  # On évite les bords
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)

			if grid[x][y] == 1:
				var placed = false

				var right_tile = tile_map_layer.get_cell_atlas_coords(Vector2i(x + 1, y))
				var left_tile = tile_map_layer.get_cell_atlas_coords(Vector2i(x - 1, y))

				if is_valid_tile(left_tile) and is_valid_tile(right_tile):

					# --- CAS miroir (gauche + droite) ---
					# Cas 1 : bord de sol
					if (right_tile == floor_tile and is_floor_edge_tile(left_tile)) or (left_tile == floor_tile and is_floor_edge_tile(right_tile)):
						tile_map_layer.set_cell(tile_position, 0, floor_tile_top)
						placed = true

					# Cas 2 : mur mural
					elif (right_tile == floor_tile and is_wall_decor_tile(left_tile)) or (left_tile == floor_tile and is_wall_decor_tile(right_tile)):
						tile_map_layer.set_cell(tile_position, 0, wall_tile)
						placed = true

					# Cas 3 : coins spéciaux
					elif right_tile == floor_tile and left_tile == wall_tile_top:
						tile_map_layer.set_cell(tile_position, 0, wall_corner_left3)
						placed = true
					elif left_tile == floor_tile and right_tile == wall_tile_top:
						tile_map_layer.set_cell(tile_position, 0, wall_corner_right3)
						placed = true
						
					elif left_tile == floor_tile and right_tile == wall_tile_bottom:
						tile_map_layer.set_cell(tile_position, 0, wall_angle_right)
						placed = true
						
					elif right_tile == floor_tile and left_tile == wall_tile_bottom:
						tile_map_layer.set_cell(tile_position, 0, wall_angle_left)
						placed = true
						
				# Mur gauche si à droite c’est du sol
				elif x < WIDTH - 1 and grid[x + 1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_left_side)
					placed = true

				# Mur droit si à gauche c’est du sol
				elif x > 0 and grid[x - 1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_right_side)
					placed = true

			
 	# Ajouter les éléments dans les salles
	for room in rooms:
		var top_left_corner = Vector2i(room.position.x - 1, room.position.y - 3)
		var top_right_corner = Vector2i(room.position.x + room.size.x, room.position.y - 3)
	# Placer le coin gauche
		tile_map_layer.set_cell(top_left_corner, 0, wall_corner_left)
	# Placer le coin droit
		tile_map_layer.set_cell(top_right_corner, 0, wall_corner_right)
		
		var bottom_left_corner = Vector2i(room.position.x -1, room.position.y + room.size.y + 1)
		var bottom_right_corner = Vector2i(room.position.x + room.size.x, room.position.y + room.size.y + 1)
		tile_map_layer.set_cell(bottom_left_corner, 0, wall_corner_left_bottom)
		tile_map_layer.set_cell(bottom_right_corner, 0, wall_corner_right_bottom)
				
		# Placer les murs latéraux autour de l'entrée de chaque salle
		var left_side_pos1 = Vector2i(room.position.x - 1, room.position.y - 1)
		var left_side_pos2 = Vector2i(room.position.x - 1, room.position.y - 2)
		tile_map_layer.set_cell(left_side_pos1, 0, wall_tile_left_side)
		tile_map_layer.set_cell(left_side_pos2, 0, wall_tile_left_side)

		var right_side_pos1 = Vector2i(room.position.x + room.size.x, room.position.y - 1)
		var right_side_pos2 = Vector2i(room.position.x + room.size.x, room.position.y - 2)
		tile_map_layer.set_cell(right_side_pos1, 0, wall_tile_right_side)
		tile_map_layer.set_cell(right_side_pos2, 0, wall_tile_right_side)
		
		var bottom_left_side = Vector2i(room.position.x -1, room.position.y + room.size.y)
		var bottom_right_side = Vector2i(room.position.x + room.size.x, room.position.y + room.size.y)
		tile_map_layer.set_cell(bottom_left_side, 0, wall_tile_left_side)
		tile_map_layer.set_cell(bottom_right_side, 0, wall_tile_right_side)

	
		if room.size.x == 11 and room.size.y == 11:
			var wall_positions = [
			Vector2i(4,1), Vector2i(4,2), Vector2i(4,3),
			Vector2i(3,3), Vector2i(2,3), Vector2i(2,4),
			Vector2i(5,4), Vector2i(6,4), Vector2i(8,4),
			Vector2i(7,5),Vector2i(9,3),
			Vector2i(5,6), Vector2i(6,6), Vector2i(8,6),
			Vector2i(2,7), Vector2i(4,7), Vector2i(5,7), Vector2i(8,7),
			Vector2i(2,8), Vector2i(5,8), Vector2i(8,8),
			Vector2i(3,9), Vector2i(4,9), Vector2i(5,9), Vector2i(8,9), Vector2i(10,9)
			]
	
	# Place all walls
			for pos in wall_positions:
		# Convert to global coordinates and place wall
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile)
			var trou_local_pos = Vector2i(0, 8)
			var trou_global_pos = Vector2i(room.position) + trou_local_pos
	
	# Placement précis (en pixels)
			var trou = trou_scene.instantiate()
			
			trou.position = tile_map_layer.map_to_local(trou_global_pos) + Vector2(10, 0)
			add_child(trou)
			
			var aliment_positions = [
	Vector2i(2, 5),  # Position 1
	Vector2i(2, 1),  # Position 2
	Vector2i(9, 1)   # Position 3
]
			for pos in aliment_positions:
	# Conversion en coordonnées globales
				var global_pos = Vector2i(room.position) + pos
	
	# Création et placement de l'aliment
				var aliment = aliment_scene.instantiate()
				aliment.scale = Vector2(0.08, 0.08)  # Échelle réduite à 10%
				aliment.position = tile_map_layer.map_to_local(global_pos)
	
	# Option : Aligner parfaitement sur la grille (supprime les décalages pixels)
	# aliment.position = tile_map_layer.map_to_local(global_pos).snapped(Vector2(32, 32))
	
				add_child(aliment)
 		# Pièges dans les salles moyennes (7x7)
		if room.size.x == 7 and room.size.y == 7:
 	# Position au centre de la salle en coordonnées grille
			var wall_positions = [
		Vector2i(1,1), Vector2i(2,1),Vector2i(3,1), Vector2i(3,2),
		Vector2i(5,2), Vector2i(6,2),  # Note: (8,1) is outside 7x7
		Vector2i(2,3), Vector2i(5,3),
		Vector2i(3,4), Vector2i(5,4),
		Vector2i(2,5),Vector2i(2,6),
		Vector2i(5,6),
	]
	
	# Place all walls
			for pos in wall_positions:
		# Convert to global coordinates and place wall
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile)
			var aliment_pos = Vector2i(4, 3)  # Position centrale stratégique
			var aliment_global_pos = Vector2i(room.position.x + aliment_pos.x, room.position.y + aliment_pos.y)
			var aliment = aliment_scene.instantiate()
			aliment.scale = Vector2(0.1, 0.1)
			aliment.position = tile_map_layer.map_to_local(aliment_global_pos)
			add_child(aliment)
			
		if room.size.x == 9 and room.size.y == 9:
			var wall_positions = [
 			Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 4),
 			Vector2i(2, 5), Vector2i(3, 6), Vector2i(5, 6),
 			Vector2i(6, 5), Vector2i(7, 5), Vector2i(6, 2),
 			Vector2i(5, 2), Vector2i(5, 3), Vector2i(4, 3),
 			Vector2i(6, 6), Vector2i(4, 6)
			]
 	
 	# Placement des murs
			for pos in wall_positions:
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile)

 		
		if room.size.x == 14 and room.size.y == 14:
			var wall_positions = [
			Vector2i(4,1), Vector2i(7,1), 
			Vector2i(4,2), Vector2i(7,2), Vector2i(11,2),
			Vector2i(7,3), Vector2i(10,3),
			Vector2i(5,4), Vector2i(7,4), Vector2i(8,4), Vector2i(9,4), Vector2i(10,4),
			Vector2i(5,5), Vector2i(9,5),
			Vector2i(5,6), Vector2i(8,6),
			Vector2i(1,7), Vector2i(5,7), Vector2i(8,7),
			Vector2i(2,8), Vector2i(5,8), Vector2i(8,8),
			Vector2i(3,9), Vector2i(4,9), Vector2i(5,9), Vector2i(8,9), Vector2i(9,9), Vector2i(10,9), Vector2i(11,9),
			Vector2i(5,10), Vector2i(9,10),
			Vector2i(3,11), Vector2i(6,11), Vector2i(7,11), Vector2i(8,11), Vector2i(9,11), Vector2i(10,11)]
			
 	# Place all walls
			for pos in wall_positions:
 		# Convert to global coordinates and place wall
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile)

			var knife_local_pos = Vector2i(5, 4)
			var knife_global_pos = Vector2i(room.position) + knife_local_pos

			var knife = knife_scene.instantiate()
			add_child(knife)  # Ajout d'abord !
			knife.scale = Vector2(0.08, 0.08)  # Échelle plus raisonnable
			knife.position = tile_map_layer.map_to_local(knife_global_pos)

# Debug
			print("Knife placé à : ", knife.position)
			var trou_pos = Vector2i(room.position.x + 12, room.position.y + 12)
			var trou = trou_scene.instantiate()
			trou.position = tile_map_layer.map_to_local(trou_pos)
			add_child(trou)

	# 2. Aliments aux positions stratégiques
			var aliment_positions = [
		Vector2i(2,2),  # Haut-gauche
		Vector2i(12,3), # Haut-droite
		Vector2i(6,8),  # Centre
		Vector2i(3,12)]
	
			for pos in aliment_positions:
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				var aliment = aliment_scene.instantiate()
				aliment.scale = Vector2(0.1, 0.1)
				aliment.position = tile_map_layer.map_to_local(global_pos)
				add_child(aliment)



		if room.size.x == 8 and room.size.y == 8:
			var wall_positions = [
		Vector2i(3,1), 
		Vector2i(6,1), Vector2i(6,2),
		Vector2i(3,3), Vector2i(4,3), Vector2i(5,3),
		Vector2i(3,4), Vector2i(5,4),
		Vector2i(6,5), Vector2i(3,5),
		Vector2i(2,6), Vector2i(3,6), Vector2i(6,6),
		Vector2i(2,7)]
	
	# Placement direct comme avant
			for pos in wall_positions:
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile)
			var aliment_positions = [
	Vector2i(7, 7),  # Position 1
]
			var knife_local_pos = Vector2i(0, 7)
			var knife_global_pos = Vector2i(room.position) + knife_local_pos

			var knife = knife_scene.instantiate()
			add_child(knife)  # Ajout d'abord !
			knife.scale = Vector2(0.08, 0.08)  # Échelle plus raisonnable
			knife.position = tile_map_layer.map_to_local(knife_global_pos)
			for pos in aliment_positions:
	# Conversion en coordonnées globales
				var global_pos = Vector2i(room.position) + pos
	
	# Création et placement de l'aliment
				var aliment = aliment_scene.instantiate()
				aliment.scale = Vector2(0.08, 0.08)  # Échelle réduite à 10%
				aliment.position = tile_map_layer.map_to_local(global_pos)
				add_child(aliment)
