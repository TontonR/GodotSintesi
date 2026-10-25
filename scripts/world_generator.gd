extends Node

# ==============================================================================
# MUNDO PROCEDURAL POR CHUNKS
# ==============================================================================

## Tamaño de un tile en píxeles. Único sitio donde se define.
const TILE_SIZE := 16
## Tiles libres tras la zona segura antes de generar enemigos en el chunk 0.
const SPAWN_CLEARANCE_TILES := 6

@export_group("Mundo")
## Semilla del mundo; 0 = aleatoria por partida.
@export var world_seed: int = 0
## Ancho de cada chunk en tiles.
@export var chunk_width_tiles: int = 256
## Fila del fondo del mundo. El terreno se rellena hasta aquí. Debe ser mayor que max_height.
@export var chunk_height_tiles: int = 140
## Tiles planos al inicio para que el jugador aparezca seguro.
@export var safe_start_tiles: int = 15
## Tiles de transición entre el inicio plano y el ruido.
@export var start_blend_tiles: int = 24
## Margen extra en píxeles para cargar el chunk vecino antes de verlo.
@export var load_margin_px: float = 96.0
## Altura sobre el suelo a la que aparece el jugador, en tiles.
@export var player_spawn_height_tiles: int = 6

@export_group("Terreno")
## Altura media del suelo en tiles (la fila crece hacia abajo).
@export var base_height: int = 60
## Variación máxima de altura; más alto = montañas más grandes.
@export var height_amplitude: float = 20.0
## Frecuencia del ruido; más baja = montañas más anchas.
@export var noise_frequency: float = 0.007
@export var noise_octaves: int = 4
@export var noise_gain: float = 0.45
## Fila mínima del suelo (cumbre más alta). No bajar de 0.
@export var min_height: int = 5
## Fila máxima del suelo (valle más profundo).
@export var max_height: int = 110

@export_group("Tiles")
## TileSet con el atlas 3x3 (superficie, relleno y reservados).
@export var solid_tile_set: TileSet
## TileSet del césped que se pinta sobre la superficie.
@export var grass_tile_set: TileSet
@export var tile_source_id: int = 0
## Coordenada de atlas del tile 1 (esquina superior izquierda del bloque 3x3).
@export var tile_atlas_origin: Vector2i = Vector2i(0, 0)
## Activar si los bordes izquierdo/derecho salen intercambiados.
@export var swap_left_right: bool = false

@export_group("Enemigos")
## Lista de escenas de enemigos.
@export var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/orc.tscn"),
	preload("res://scenes/enemies/ghost.tscn")
]
## Cantidades por chunk, en el mismo orden que las escenas.
@export var enemy_counts_per_chunk: Array[int] = [4, 1]
## Margen en tiles para no aparecer pegado al borde del chunk.
@export var enemy_spawn_margin_tiles: int = 2

@export_group("Monedas")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
@export var coins_per_chunk: int = 8
## Las monedas no caen: su base queda sobre el suelo.
@export var coin_ground_offset: float = 8.0

@export_group("Chunks")
@export var chunk_scene: PackedScene = preload("res://scenes/world/chunk.tscn")

@onready var player: CharacterBody2D = get_parent().get_node_or_null("player")
@onready var _template_solid: TileMapLayer = get_node_or_null("solid_map_layer")
@onready var _template_grass: TileMapLayer = get_node_or_null("grass_map_layer")

var _noise := FastNoiseLite.new()
var _seed: int = 0
var _camera: Camera2D
var _loaded_chunks: Dictionary = {}
var _chunk_data: Dictionary = {}
var _defeated_spawns: Dictionary = {}
var _collected_spawns: Dictionary = {}
var _last_first: int = 999999
var _last_last: int = -999999


func _ready() -> void:
	# La capa antigua sigue en game.tscn como plantilla de TileSet.
	if solid_tile_set == null and _template_solid:
		solid_tile_set = _template_solid.tile_set
	if grass_tile_set == null and _template_grass:
		grass_tile_set = _template_grass.tile_set

	_seed = world_seed if world_seed != 0 else randi()
	_noise.seed = _seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = noise_frequency
	_noise.fractal_octaves = noise_octaves
	_noise.fractal_gain = noise_gain

	if player:
		_camera = player.get_node_or_null("Camera2D") as Camera2D
		var spawn_x := safe_start_tiles * TILE_SIZE + TILE_SIZE / 2
		var spawn_y := _height_at(safe_start_tiles) * TILE_SIZE - player_spawn_height_tiles * TILE_SIZE
		player.position = Vector2(spawn_x, spawn_y)

	_update_chunks(true)


func _process(_delta: float) -> void:
	if player:
		_update_chunks(false)


# ==============================================================================
# ALTURA DEL TERRENO
# ==============================================================================
func _height_at(tile_x: int) -> int:
	var h := _noise_height(tile_x)
	if tile_x >= 0 and tile_x < safe_start_tiles:
		return base_height
	if tile_x >= safe_start_tiles and tile_x < safe_start_tiles + start_blend_tiles:
		var t := float(tile_x - safe_start_tiles) / float(maxi(1, start_blend_tiles))
		return roundi(lerpf(base_height, h, t))
	return h


func _noise_height(tile_x: int) -> int:
	# 3 samples para algo de suavizado sin aplanar demasiado.
	var value := 0.0
	for offset in range(-1, 2):
		value += _noise.get_noise_1d(float(tile_x + offset))
	value /= 3.0
	return clampi(roundi(base_height + value * height_amplitude), min_height, max_height)


# ==============================================================================
# CARGA / DESCARGA DE CHUNKS
# ==============================================================================
func _update_chunks(force: bool) -> void:
	if not player:
		return

	# Centro real de la vista (respeta suavizado, drag y límites) y ancho
	# visible en coordenadas de mundo (viewport / zoom).
	var center_x := player.global_position.x
	var zoom_x := 1.0
	if _camera:
		center_x = _camera.get_screen_center_position().x
		zoom_x = _camera.zoom.x
	var half_width := get_viewport().get_visible_rect().size.x / zoom_x * 0.5
	var chunk_width_px := float(chunk_width_tiles * TILE_SIZE)
	var first := floori((center_x - half_width - load_margin_px) / chunk_width_px)
	var last := floori((center_x + half_width + load_margin_px) / chunk_width_px)

	# El chunk del jugador no se descarga nunca.
	var current := floori(player.global_position.x / chunk_width_px)
	first = mini(first, current)
	last = maxi(last, current)

	if not force and first == _last_first and last == _last_last:
		return
	_last_first = first
	_last_last = last

	# Primero los datos (solo los visibles + 1 a la derecha para anticipar).
	for x in range(first, last + 2):
		var coord := Vector2i(x, 0)
		if not _chunk_data.has(coord):
			_chunk_data[coord] = _generate_chunk(coord)

	for x in range(first, last + 1):
		var coord := Vector2i(x, 0)
		if not _loaded_chunks.has(coord):
			_load_chunk(coord)

	for coord in _loaded_chunks.keys():
		if coord.x < first or coord.x > last:
			_unload_chunk(coord)

	# Liberar datos de chunks que quedan lejos (fuera de first..last+1).
	for coord in _chunk_data.keys():
		if coord.x < first or coord.x > last + 1:
			_chunk_data.erase(coord)


func _generate_chunk(coord: Vector2i) -> Dictionary:
	var heights := PackedInt32Array()
	heights.resize(chunk_width_tiles)
	var start_x := coord.x * chunk_width_tiles
	for i in range(chunk_width_tiles):
		heights[i] = _height_at(start_x + i)
	# Alturas vecinas para elegir los tiles de borde izquierdo/derecho.
	var edge_left := _height_at(start_x - 1)
	var edge_right := _height_at(start_x + chunk_width_tiles)
	# Altura de la columna siguiente: el chunk pinta una columna extra para
	# tapar la grieta de 1 px entre las capas de dos chunks.
	var edge_right_next := _height_at(start_x + chunk_width_tiles + 1)

	# Misma semilla + mismo chunk = mismos spawns.
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:%d" % [_seed, coord.x, coord.y])

	var min_x := enemy_spawn_margin_tiles
	if coord.x == 0:
		# Hueco extra para que no aparezcan encima del spawn del jugador.
		min_x = maxi(min_x, safe_start_tiles + SPAWN_CLEARANCE_TILES)
	var max_x := chunk_width_tiles - enemy_spawn_margin_tiles - 1
	# Si la zona segura ocupa todo el chunk, no hay hueco para spawns.
	var has_room := min_x <= max_x
	if not has_room:
		min_x = 0
		max_x = 0

	var enemies: Array[Dictionary] = []
	var enemy_index := 0
	for idx in range(enemy_scenes.size()):
		var count := 0
		if idx < enemy_counts_per_chunk.size():
			count = enemy_counts_per_chunk[idx]
		for i in range(count):
			var spawn_id := "e:%d:%d:%d" % [coord.x, coord.y, enemy_index]
			enemy_index += 1
			# Consumir el RNG siempre para que las posiciones no cambien al persistir bajas.
			var local_x := rng.randi_range(min_x, max_x)
			if not has_room or _defeated_spawns.has(spawn_id) or enemy_scenes[idx] == null:
				continue
			enemies.append({
				"id": spawn_id,
				"scene": enemy_scenes[idx],
				"position": Vector2(local_x * TILE_SIZE, heights[local_x] * TILE_SIZE)
			})

	var coins: Array[Dictionary] = []
	for i in range(coins_per_chunk):
		var spawn_id := "c:%d:%d:%d" % [coord.x, coord.y, i]
		# Mismo motivo que con los enemigos: no alterar el orden del RNG.
		var local_x := rng.randi_range(min_x, max_x)
		if not has_room or _collected_spawns.has(spawn_id):
			continue
		coins.append({
			"id": spawn_id,
			"position": Vector2(local_x * TILE_SIZE, heights[local_x] * TILE_SIZE - coin_ground_offset)
		})

	return {"heights": heights, "edge_left": edge_left, "edge_right": edge_right, "edge_right_next": edge_right_next, "enemies": enemies, "coins": coins}


func _load_chunk(coord: Vector2i) -> void:
	if not _chunk_data.has(coord):
		_chunk_data[coord] = _generate_chunk(coord)
	var data: Dictionary = _chunk_data[coord]

	var chunk: WorldChunk = chunk_scene.instantiate()
	chunk.name = "Chunk_%d" % coord.x
	chunk.position = Vector2(coord.x * chunk_width_tiles * TILE_SIZE, 0)
	add_child(chunk)
	chunk.paint(
		data["heights"],
		data["edge_left"],
		data["edge_right"],
		data["edge_right_next"],
		solid_tile_set,
		tile_source_id,
		tile_atlas_origin,
		grass_tile_set,
		chunk_height_tiles,
		swap_left_right
	)
	_spawn_chunk_entities(chunk, data)
	_loaded_chunks[coord] = chunk


func _unload_chunk(coord: Vector2i) -> void:
	var chunk := _loaded_chunks.get(coord) as WorldChunk
	if is_instance_valid(chunk):
		chunk.queue_free()
	_loaded_chunks.erase(coord)


func _spawn_chunk_entities(chunk: WorldChunk, data: Dictionary) -> void:
	for entry in data["enemies"]:
		var spawn_id: String = entry["id"]
		if _defeated_spawns.has(spawn_id):
			continue
		var scene: PackedScene = entry["scene"]
		var enemy := scene.instantiate() as Node2D
		if enemy == null:
			continue
		# La base del collider queda sobre el suelo (el origen suele estar más arriba).
		# `spawn_y_offset` corrige los que tienen el dibujo más bajo que el collider.
		var spawn_pos: Vector2 = entry["position"]
		var offset: float = enemy.get("spawn_y_offset")
		enemy.position = spawn_pos - Vector2(0.0, _body_bottom(enemy) + offset)
		chunk.entities.add_child(enemy)
		if enemy.has_signal("died"):
			enemy.connect("died", _on_enemy_died.bind(spawn_id))

	for entry in data["coins"]:
		var spawn_id: String = entry["id"]
		if _collected_spawns.has(spawn_id):
			continue
		var coin := coin_scene.instantiate() as Node2D
		if coin == null:
			continue
		coin.position = entry["position"]
		chunk.entities.add_child(coin)
		if coin.has_signal("collected"):
			coin.connect("collected", _on_coin_collected.bind(spawn_id))


## Distancia del origen a la base del collider del cuerpo (para apoyarlo en el suelo).
func _body_bottom(enemy: Node2D) -> float:
	# shortcut: solo colliders directos RectangleShape2D; ampliar si cambia la forma.
	var bottom := 0.0
	for child in enemy.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node and shape_node.shape is RectangleShape2D:
			var rect := shape_node.shape as RectangleShape2D
			var local_bottom: float = shape_node.position.y + rect.size.y * 0.5 * shape_node.scale.y
			bottom = maxf(bottom, local_bottom * enemy.scale.y)
	return bottom


func _on_enemy_died(spawn_id: String) -> void:
	_defeated_spawns[spawn_id] = true


func _on_coin_collected(spawn_id: String) -> void:
	_collected_spawns[spawn_id] = true
