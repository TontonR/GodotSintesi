extends TileMapLayer

# Ancho del mundo en tiles
@export var world_width: int = 500
# Altura base del suelo (tile Y)
@export var ground_level: int = 12
# Profundidad del suelo (capas debajo de la superficie)
@export var ground_depth: int = 15
# Amplitud máxima de variación del terreno
@export var height_variation: int = 3
# Semilla del ruido
@export var noise_seed: int = randi()

var _noise: FastNoiseLite

func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = noise_seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.05
	_generate_world()

func _generate_world() -> void:
	clear()
	var heights: Array[int] = []
	for x in world_width:
		var h: int = ground_level + int(_noise.get_noise_1d(float(x)) * height_variation)
		heights.append(h)
	for x in world_width:
		var surface_y: int = heights[x]
		# Superficie: hierba
		set_cell(Vector2i(x, surface_y), 0, Vector2i(1, 0))
		# Suelo debajo
		for y in range(surface_y + 1, surface_y + ground_depth):
			set_cell(Vector2i(x, y), 0, Vector2i(2, 2))
	# Posicionar al jugador sobre el suelo
	var player_x: int = world_width / 4
	var player_ground: int = heights[player_x]
	var player: CharacterBody2D = get_node("/root/game/player")
	player.position = Vector2(player_x * 16 + 8, player_ground * 16 - 32)
