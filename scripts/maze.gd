extends TileMap

const TILE_LAYER = 0  # Layer du TileMap (0 par défaut)
#const GRID_SIZE = 2 #2*2 grid

# Liste des indices des tuiles principales dans le TileSet
const TILE_SET_INDICES = [0, 1]  # Ajuste selon ton TileSet

func get_template(x):
	var template=[]
	for i in range(x, x + 16):  # x → x+15 inclus
		for j in range(1, 17):   # y = 1 → 16 inclus
			template.append(Vector2i(i, j))
	return template
	
var first_template = get_template(24)
var second_template = get_template(40)
var all_templates = [ first_template,second_template]

func _ready():
	randomize()  # Assure un tirage aléatoire différent à chaque exécution
	place_random_tile()

# Fonction pour placer une tuile aléatoire au centre de l'écran
func place_random_tile():
	#var random_source = TILE_SET_INDICES[randi_range(0, TILE_SET_INDICES.size() - 1)]  # Choisir une tuile au hasard
	#var random_tileX = randi_range(0, 1) #choix au hasard d'une tuiles de la tiles (CHANGE BY 2)
	
	var tile_size = Vector2(16, 16)  # Taille de chaque tuile en pixels (à ajuster selon ton TileSet)
# Position désirée en pixels (ex: placer l'origine à 100px, 200px de l'écran)
	var desired_pixel_position = Vector2(200, 200)
	# Convertir la position en pixels en coordonnées de TileMap
	var grid_position = Vector2i(desired_pixel_position / tile_size)
	
	
	var num_source = 0
	var position
	for i in TILE_SET_INDICES:
		for j in all_templates:
			for k in j:
				set_cell(TILE_LAYER, grid_position+k, num_source, k)
		num_source+=1
	
	# WHEN WE WILL HAVE MORE TILES
	#var num_source = 0
	#for i in TILE_SET_INDICES:
		#set_cell(TILE_LAYER, center_pos, num_source, Vector2i(1, 0)) 
		#num_source+=1
#
