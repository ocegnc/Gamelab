extends Node2D
@onready var tile_map_layer = $TileMapLayer
@onready var player = preload("res://scenes/baguette.tscn")
@onready var trap_scene = preload("res://scenes/traps.tscn")
var floor_tile := Vector2i(0,2)
var wall_tile_top := Vector2i(1,0)
var wall_tile_bottom := Vector2i(5,0)
var wall_tile_left_side := Vector2i(0, 0)
var wall_tile_right_side := Vector2i(2, 0)
var tile_ketchup := Vector2i(3, 0)
var tile_mayo := Vector2i(4, 0)
 
# Constants defining the grid size, cell size, and room parameters
const WIDTH = 400
const HEIGHT = 300
const CELL_SIZE = 10
const MAX_ROOMS = 10

const ROOM_TEMPLATES = [
	# Format: [largeur, hauteur]
	[5, 5],  # Petite salle carrée
	[7, 7],  # Salle moyenne
	[10, 5], # Salle rectangulaire large
	[5, 10], # Salle rectangulaire haute
	[8, 8]   # Grande salle carrée
]
# Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []
 
# _ready is called when the node is added to the scene
func _ready():
	# Initialize the random number generator
	randomize()
	# Create the grid filled with walls
	initialize_grid()
	# Generate the dungeon by placing rooms and connecting them
	generate_dungeon()
	# Draw the dungeon on the screen
	draw_dungeon()
 
# Initializes the grid with all cells set to walls (represented by 1)
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])  # Add a new row to the grid
		for y in range(HEIGHT):
			grid[x].append(1)  # Fill each cell in the row with 1 (wall)
 
# Main function to generate the dungeon by placing rooms and connecting them
func generate_dungeon():
	for i in range(MAX_ROOMS):
		# Generate a room with random size and position
		var room = generate_room()
		# Attempt to place the room in the grid
		if place_room(room):
			# If this isn't the first room, connect it to the previous room
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)  # Connect the new room to the last placed room
			# Add the room to the list of rooms in the dungeon
			rooms.append(room)
 
# Generates a room with random width, height, and position within the grid
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
func connect_rooms(room1, room2, corridor_width=4):
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
		if room.size.x == 25 and room.size.y == 25:
			var ketchup_pos = Vector2i(room.position.x + 2, room.position.y + 2)
			tile_map_layer.set_cell(ketchup_pos, 0, tile_ketchup)
		
		# Pièges dans les salles moyennes (7x7)
		if room.size.x == 35 and room.size.y == 35:
	# Position au centre de la salle en coordonnées grille
			var center_x_grid = room.position.x + floor(room.size.x / 2.0)
			var center_y_grid = room.position.y + floor(room.size.y / 2.0)
	
	# Conversion en coordonnées mondiales
			var trap_pos = tile_map_layer.map_to_local(Vector2i(center_x_grid, center_y_grid))
	
			var trap = trap_scene.instantiate()
			trap.position = trap_pos
			add_child(trap)
