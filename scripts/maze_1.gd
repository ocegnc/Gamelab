extends Node2D
@onready var tile_map_layer = $TileMapLayer
@onready var player = preload("res://scenes/baguette.tscn")
@onready var trap_scene = preload("res://scenes/traps.tscn")
var floor_tile_top := Vector2i(1,2)
var floor_tile := Vector2i(2,3)
var floor_tile_bottom := Vector2i(3,3)
var wall_tile_top := Vector2i(1,0)
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

# Constants defining the grid size, cell size, and room parameters
const WIDTH = 60  # Augmenté pour accommoder 9 salles
const HEIGHT = 60
const FIXED_ROOMS = [
	# Format: [x, y, width, height]
	# Première ligne (haut)
	[10, 10, 9, 9],    # Haut-gauche
	[26, 10, 7, 7],    # Haut-centre
	[42, 10, 7, 7],    # Haut-droite
	
	# Deuxième ligne (milieu)
	[10, 26, 7, 7],    # Centre-gauche
	[26, 26, 10, 10],  # Grande salle centrale
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


				# Sauter tout ce qu’on vient de traiter
				y += 3 + floor_height + 1  # 3 (haut) + sol + mur de fin

			else:
				# Aucun motif → effacer la colonne actuelle sur cette bande
				tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(-1, -1))
				y += 1
		# Ajouter murs latéraux
	for x in range(1, WIDTH - 1):
		for y in range(HEIGHT):
			if tile_map_layer.get_cell_atlas_coords(Vector2i(x - 1, y)) == Vector2i(-1, -1):
				if grid[x][y] == 0:
				# Gauche
					if grid[x - 2][y] == 1:
						tile_map_layer.set_cell(Vector2i(x - 2, y), 0, wall_tile_left_side)
						tile_map_layer.set_cell(Vector2i(x - 1, y), 0, wall_tile_left_side_top)
				# Droite
					if grid[x + 2][y] == 1:
						tile_map_layer.set_cell(Vector2i(x + 2, y), 0, wall_tile_right_side)
						tile_map_layer.set_cell(Vector2i(x + 1, y), 0, wall_tile_right_side_top)
	# Ajouter les éléments dans les salles
	for room in rooms:
		if room.size.x == 25 and room.size.y == 25:
			var ketchup_pos = Vector2i(room.position.x + 2, room.position.y + 2)
			tile_map_layer.set_cell(ketchup_pos, 0, tile_ketchup)
		
		# Pièges dans les salles moyennes (7x7)
		if room.size.x == 7 and room.size.y == 7:
	# Position au centre de la salle en coordonnées grille
			var center_x_grid = room.position.x + floor(room.size.x / 2.0)
			var center_y_grid = room.position.y + floor(room.size.y / 2.0)
	
	# Conversion en coordonnées mondiales
			var trap_pos = tile_map_layer.map_to_local(Vector2i(center_x_grid, center_y_grid))
	
			var trap = trap_scene.instantiate()
			trap.position = trap_pos
			add_child(trap)
		if room.size.x == 9 and room.size.y == 9:
			var center_x_grid = room.position.x + floor(room.size.x / 2.0)
			var center_y_grid = room.position.y + floor(room.size.y / 2.0)
			var baguette_pos = tile_map_layer.map_to_local(Vector2i(center_x_grid, center_y_grid))
			var baguette = player.instantiate()
			baguette.scale = Vector2(0.009, 0.009)
			baguette.position = baguette_pos
			add_child(baguette)
