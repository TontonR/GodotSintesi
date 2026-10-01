extends TileMapLayer

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
@export var orc_scene: PackedScene = preload("res://orc.tscn")
# Cantidad exacta de orcos a generar por zona
@export var orcs_per_zone: int = 8
# Margen en tiles desde el inicio (x=0) para que el jugador aparezca seguro
@export var safe_start_tiles: int = 15

# Referencia al jugador
@onready var player: CharacterBody2D = get_node_or_null("/root/game/player")

# Diccionario para rastrear los orcos instanciados en cada zona
# Clave: zone_index (int), Valor: Array[Node2D] (los orcos de esa zona)
var loaded_zones: Dictionary = {}
var current_player_zone: int = -1

func _ready() -> void:
	clear()
	
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
	
	# A) Generar Tiles del terreno de la zona
	for x in range(start_x, end_x):
		# Capa superficial (Hierba)
		set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0))
		# Capas inferiores (Tierra)
		for y in range(ground_level + 1, ground_level + ground_depth):
			if y == ground_level + 1:
				set_cell(Vector2i(x, y), 0, Vector2i(2, 1))
			else:
				set_cell(Vector2i(x, y), 0, Vector2i(2, 2))
				
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
			
	# Guardar los orcos en la lista de la zona cargada
	loaded_zones[zone_index] = zone_orcs

func _unload_zone(zone_index: int) -> void:
	var start_x: int = zone_index * zone_width_tiles
	var end_x: int = start_x + zone_width_tiles
	
	# A) Borrar las celdas del TileMap en esa zona
	for x in range(start_x, end_x):
		for y in range(ground_level, ground_level + ground_depth):
			erase_cell(Vector2i(x, y))
			
	# B) Eliminar y destruir todos los orcos pertenecientes a esa zona
	if loaded_zones.has(zone_index):
		for orc in loaded_zones[zone_index]:
			if is_instance_valid(orc):
				orc.queue_free()
		loaded_zones.erase(zone_index)
