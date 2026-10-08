extends Node

# ==============================================================================
# CONFIGURACIÓN DEL MUNDO INFINITO Y ZONAS
# ==============================================================================
@export_group("Configuración del Mundo")
# Ancho de cada zona en tiles (ej. 250 tiles = 4000px)
@export var zone_width_tiles: int = 250
# Altura base del suelo y profundidad
@export var ground_level: int = 20
@export var ground_depth: int = 15

@export_group("Configuración de Enemigos")
@export var orc_scene: PackedScene = preload("res://scenes/enemies/orc.tscn")
# Cantidad exacta de orcos a generar por zona
@export var orcs_per_zone: int = 4
@export var ghost_scene: PackedScene = preload("res://scenes/enemies/ghost.tscn")
# Cantidad exacta de orcos a generar por zona
@export var ghost_per_zone: int = 0
# Margen en tiles desde el inicio (x=0) para que el jugador aparezca seguro
@export var safe_start_tiles: int = 15

@export_group("Configuración de Monedas")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
# Cantidad exacta de monedas repartidas por el suelo de cada zona
@export var coins_per_zone: int = 20
# Las monedas no caen (no son cuerpos físicos): su base queda sobre el suelo
@export var coin_ground_offset: float = 8.0

# Capas hijas que alimenta el generador:
#   solid_map_layer -> ground_tile.png (tierra con colisión)
#   grass_map_layer -> grass_tile.png (franja de hierba, solo visual)
@onready var solid_layer: TileMapLayer = $solid_map_layer
@onready var grass_layer: TileMapLayer = $grass_map_layer

# Referencia al jugador (hermano de este nodo dentro de la raíz "game")
@onready var player: CharacterBody2D = get_parent().get_node_or_null("player")

# Diccionario para rastrear lo instanciado en cada zona
# Clave: zone_index (int), Valor: {"orcs": Array[Node2D], "coins": Array[Node2D]}
var loaded_zones: Dictionary = {}
var current_player_zone: int = -1

func _ready() -> void:
	solid_layer.clear()
	grass_layer.clear()
	
	# Posicionar al jugador en el inicio del mundo
	if player:
		player.position = Vector2(safe_start_tiles * 16 + 8, ground_level * 16 - 32)
	
	# Evaluar la zona inicial al arrancar
	_update_zones_around_player()

func _process(_delta: float) -> void:
	if not player:
		return
		
	# Calcular en qué zona se encuentra el jugador actualmente
	var player_tile_x: int = int(player.position.x / 16.0)
	var new_zone: int = int(player_tile_x / zone_width_tiles)
	
	# Si el jugador cambió de zona, actualizamos qué zonas deben estar cargadas
	if new_zone != current_player_zone:
		current_player_zone = new_zone
		_update_zones_around_player()

# ==============================================================================
# CAPAS DE TILE
# ==============================================================================
# Las variantes solo cambian de fila, nunca dentro de una misma fila:
# así el terreno queda continuo y no se ven huecos tipo lego.
func _paint_grass(x: int) -> void:
	grass_layer.set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0))

# Fila 0 del tileset de tierra = superficie, fila 2 = cuerpo con colisión.
# (Las filas 1 y 3 quedan fuera: alguna celda no tiene colisión definida.)
func _paint_ground(x: int) -> void:
	solid_layer.set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0))
	for y in range(ground_level + 1, ground_level + ground_depth):
		solid_layer.set_cell(Vector2i(x, y), 0, Vector2i(y % 3, 2))

# ==============================================================================
# GESTIÓN DE CARGA Y DESCARGA DE ZONAS
# ==============================================================================
func _update_zones_around_player() -> void:
	# Definimos las zonas a mantener cargadas: La zona actual y la siguiente (y opcionalmente la anterior)
	# Si estás en la zona 0, se cargarán la 0 y la 1.
	var zones_to_keep: Array[int] = [current_player_zone, current_player_zone + 1]
	
	# 1. Cargar las zonas que no estén cargadas aún
	for z_idx in zones_to_keep:
		if z_idx >= 0 and not loaded_zones.has(z_idx):
			_load_zone(z_idx)
			
	# 2. Descargar las zonas que hayan quedado fuera de alcance
	var active_zone_keys = loaded_zones.keys()
	for z_idx in active_zone_keys:
		if z_idx not in zones_to_keep:
			_unload_zone(z_idx)

func _load_zone(zone_index: int) -> void:
	var start_x: int = zone_index * zone_width_tiles
	var end_x: int = start_x + zone_width_tiles
	
	# A) Generar el terreno de la zona en las dos capas
	for x in range(start_x, end_x):
		_paint_grass(x)
		_paint_ground(x)
				
	# B) Generar la cantidad fija de Orcos para esta zona
	var zone_orcs: Array[Node2D] = []
	if orc_scene:
		var spawn_y_pixels: float = (ground_level * 16) - 16
		
		for i in range(orcs_per_zone):
			# Generar una posición X aleatoria dentro del rango de esta zona
			var min_x_tile: float = max(start_x, safe_start_tiles)
			var rand_tile_x: float = randf_range(min_x_tile, end_x - 1)
			var spawn_x_pixels: float = rand_tile_x * 16
			
			var new_orc = orc_scene.instantiate() as Node2D
			new_orc.position = Vector2(spawn_x_pixels, spawn_y_pixels)
			
			get_parent().add_child.call_deferred(new_orc)
			zone_orcs.append(new_orc)

		for i in range(ghost_per_zone):
			# Generar una posición X aleatoria dentro del rango de esta zona
			var min_x_tile: float = max(start_x, safe_start_tiles)
			var rand_tile_x: float = randf_range(min_x_tile, end_x - 1)
			var spawn_x_pixels: float = rand_tile_x * 16
			
			var new_ghost = ghost_scene.instantiate() as Node2D
			new_ghost.position = Vector2(spawn_x_pixels, spawn_y_pixels)
			
			get_parent().add_child.call_deferred(new_ghost)
			zone_orcs.append(new_ghost)
	
	# C) Repartir monedas por el suelo de la zona
	var zone_coins: Array[Node2D] = []
	if coin_scene:
		var min_x_tile: float = max(start_x, safe_start_tiles)
		var coin_y_pixels: float = (ground_level * 16) - coin_ground_offset
		
		for i in range(coins_per_zone):
			var coin_tile_x: float = randf_range(min_x_tile, end_x - 1)
			
			var new_coin = coin_scene.instantiate() as Node2D
			new_coin.position = Vector2(coin_tile_x * 16.0, coin_y_pixels)
			
			get_parent().add_child.call_deferred(new_coin)
			zone_coins.append(new_coin)
	
	# Guardar lo instanciado de la zona cargada
	loaded_zones[zone_index] = {"orcs": zone_orcs, "coins": zone_coins}

func _unload_zone(zone_index: int) -> void:
	var start_x: int = zone_index * zone_width_tiles
	var end_x: int = start_x + zone_width_tiles
	
	# A) Borrar las celdas de las dos capas en esa zona
	for x in range(start_x, end_x):
		for y in range(ground_level, ground_level + ground_depth):
			grass_layer.erase_cell(Vector2i(x, y))
			solid_layer.erase_cell(Vector2i(x, y))
			
	# B) Eliminar y destruir todo lo instanciado en esa zona
	if loaded_zones.has(zone_index):
		var zone_content: Dictionary = loaded_zones[zone_index]
		for key in ["orcs", "coins"]:
			for node in zone_content.get(key, []):
				if is_instance_valid(node):
					node.queue_free()
		loaded_zones.erase(zone_index)
	
	# C) Las monedas que soltaron los orcos no están registradas, se buscan por posición
	var zone_min_x: float = start_x * 16
	var zone_max_x: float = end_x * 16
	for coin in get_tree().get_nodes_in_group("coins"):
		var coin_node := coin as Node2D
		if is_instance_valid(coin_node) and coin_node.global_position.x >= zone_min_x and coin_node.global_position.x < zone_max_x:
			coin_node.queue_free()
