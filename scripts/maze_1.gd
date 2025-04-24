extends Node2D
@onready var tile_map_layer = $TileMapLayer
@onready var player = preload("res://scenes/baguette.tscn")
@onready var trap_scene = preload("res://scenes/traps.tscn")
@onready var trou_scene = preload("res://scenes/traps/trou.tscn")
@onready var knife_scene = preload("res://scenes/traps/knife.tscn")
@onready var aliment_scene = preload("res://scenes/aliments.tscn")
var floor_tile := Vector2i(2,3)
var wall_tile_top := Vector2i(1,1)
var wall_tile_bottom := Vector2i(1,1)
var wall_tile_left_side := Vector2i(0, 1)
var wall_tile_right_side := Vector2i(2, 1)
var tile_ketchup := Vector2i(3, 1)
var tile_mayo := Vector2i(3, 1)

 # Constants defining the grid size, cell size, and room parameters
const WIDTH = 80  # Augmenté pour accommoder 9 salles
const HEIGHT = 80
const FIXED_ROOMS = [
 	# Format: [x, y, width, height]
 	# Première ligne (haut)
 	[10, 10, 9, 9],    # Haut-gauche
 	[26, 10, 14, 14],    # Haut-centre
 	[42, 10, 8, 8],    # Haut-droite
 
 	# Deuxième ligne (milieu)
 	[10, 26, 7, 7],    # Centre-gauche
 	[26, 26, 11, 11],  # Grande salle centrale
 	[42, 26, 7, 7],    # Centre-droite
 
 	# Troisième ligne (bas)
 	[10, 42, 7, 7],    # Bas-gauche
 	[26, 42, 7, 7],    # Bas-centre
 	[42, 42, 7, 7]     # Bas-droite
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
 
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)
 
func generate_dungeon():
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
 
 # Draws the dungeon on the screen by creating visual representations of the grid
func draw_dungeon():
 
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
 
			if grid[x][y] == 0:
 				# Cellule sol
				tile_map_layer.set_cell(tile_position, 0, floor_tile)
 
			elif grid[x][y] == 1:
				var placed = false
 
 	# Mur haut si dessous c'est du sol
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
		# Remplacement aléatoire par ketchup ou mayo
					var rand = randi() % 100  # Valeur entre 0 et 99
					if rand < 5:
						tile_map_layer.set_cell(tile_position, 0, tile_ketchup)  # 5% chance
					elif rand < 10:
						tile_map_layer.set_cell(tile_position, 0, tile_mayo)     # 5% chance
					else:
						tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
					placed = true
 
 				# Mur bas si au-dessus c'est du sol
				elif y > 0 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
					placed = true
 
 				# Mur gauche si à droite c'est du sol
				elif x < WIDTH - 1 and grid[x + 1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_left_side)
					placed = true
 
 				# Mur droit si à gauche c'est du sol
				elif x > 0 and grid[x - 1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_right_side)
					placed = true
 
 				# Sinon, ne rien placer
				if not placed:
					tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
 
			else:
 				# Cellule ni sol ni mur : vide
				tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
 
 
 	# Ajouter les éléments dans les salles
	for room in rooms:
		if room.size.x == 11 and room.size.y == 11:
			var wall_positions = [
			Vector2i(4,0), Vector2i(4,1), Vector2i(4,2), Vector2i(4,3),
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
				tile_map_layer.set_cell(global_pos, 0, wall_tile_left_side)
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
		Vector2i(5,2), Vector2i(6,2), Vector2i(7,2), Vector2i(7,1), Vector2i(8,1),  # Note: (8,1) is outside 7x7
		Vector2i(2,3), Vector2i(5,3),
		Vector2i(3,4), Vector2i(5,4), Vector2i(7,4),
		Vector2i(2,5),Vector2i(2,6), Vector2i(7,5),
		Vector2i(5,6), Vector2i(7,6)
	]
	
	# Place all walls
			for pos in wall_positions:
		# Convert to global coordinates and place wall
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile_left_side)

		if room.size.x == 9 and room.size.y == 9:
			var center_x_grid = room.position.x + floor(room.size.x / 2.0)
			var center_y_grid = room.position.y + floor(room.size.y / 2.0)
			var baguette_pos = tile_map_layer.map_to_local(Vector2i(center_x_grid, center_y_grid))
			var baguette = player.instantiate()
			baguette.scale = Vector2(0.02, 0.02)
			baguette.position = baguette_pos
			add_child(baguette)
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
				tile_map_layer.set_cell(global_pos, 0, wall_tile_left_side)

 		
		if room.size.x == 14 and room.size.y == 14:
			var wall_positions = [
			Vector2i(4,1), Vector2i(7,1), 
			Vector2i(4,2), Vector2i(7,2), Vector2i(11,2),
			Vector2i(7,3), Vector2i(10,3),
			Vector2i(5,4), Vector2i(7,4), Vector2i(8,4), Vector2i(9,4), Vector2i(10,4),
			Vector2i(5,5), Vector2i(9,5),
			Vector2i(5,6), Vector2i(8,6),
			Vector2i(0,7),Vector2i(1,7), Vector2i(5,7), Vector2i(8,7),
			Vector2i(2,8), Vector2i(5,8), Vector2i(8,8),
			Vector2i(3,9), Vector2i(4,9), Vector2i(5,9), Vector2i(8,9), Vector2i(9,9), Vector2i(10,9), Vector2i(11,9),
			Vector2i(5,10), Vector2i(9,10),
			Vector2i(3,11), Vector2i(6,11), Vector2i(7,11), Vector2i(8,11), Vector2i(9,11), Vector2i(10,11)]
			
 	# Place all walls
			for pos in wall_positions:
 		# Convert to global coordinates and place wall
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile_left_side)

			var knife_local_pos = Vector2i(4, 3)
			var knife_global_pos = Vector2i(room.position) + knife_local_pos

			var knife = knife_scene.instantiate()
			add_child(knife)  # Ajout d'abord !
			knife.scale = Vector2(0.1, 0.1)  # Échelle plus raisonnable
			knife.position = tile_map_layer.map_to_local(knife_global_pos)

# Debug
			print("Knife placé à : ", knife.position)




		if room.size.x == 8 and room.size.y == 8:
			var wall_positions = [
		Vector2i(3,0), Vector2i(3,1), 
		Vector2i(6,1), Vector2i(6,2),
		Vector2i(3,3), Vector2i(4,3), Vector2i(5,3),
		Vector2i(3,4), Vector2i(5,4),
		Vector2i(6,5), Vector2i(3,5),
		Vector2i(2,6), Vector2i(3,6), Vector2i(6,6),
		Vector2i(2,7)]
	
	# Placement direct comme avant
			for pos in wall_positions:
				var global_pos = Vector2i(room.position.x + pos.x, room.position.y + pos.y)
				tile_map_layer.set_cell(global_pos, 0, wall_tile_left_side)
			var aliment_positions = [
	Vector2i(7, 7),  # Position 1
]
			for pos in aliment_positions:
	# Conversion en coordonnées globales
				var global_pos = Vector2i(room.position) + pos
	
	# Création et placement de l'aliment
				var aliment = aliment_scene.instantiate()
				aliment.scale = Vector2(0.08, 0.08)  # Échelle réduite à 10%
				aliment.position = tile_map_layer.map_to_local(global_pos)
				add_child(aliment)
