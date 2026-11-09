extends Node

# ==============================================================================
# MUNDO PROCEDURAL POR CHUNKS
# ==============================================================================

## Tamaño de un tile en píxeles. Único sitio donde se define.
const TILE_SIZE := 16
## Chunks extra a cada lado que se mantienen cargados: los enemigos no
## desaparecen al cruzar una costura (solo se liberan 2 chunks más atrás).
const KEEP_CHUNKS_SIDE := 2

@export_group("World")
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

@export_group("Terrain")
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
## Lista de escenas de enemigos (respaldo si un bioma no define las suyas).
@export var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/orc.tscn"),
	preload("res://scenes/enemies/mutant_toad.tscn"),
	preload("res://scenes/enemies/werewolf.tscn"),
	preload("res://scenes/enemies/slime.tscn"),
	preload("res://scenes/enemies/skeleton.tscn"),
	preload("res://scenes/enemies/archer.tscn")
]
## Cantidades base por chunk, en el mismo orden que las escenas.
@export var enemy_counts_per_chunk: Array[int] = [4, 2, 1, 2, 2, 2]

@export_group("Biomas")
## Biomas del mundo; el primero es el de la zona segura.
@export var biomes: Array[Biome] = [
	preload("res://resources/world/biomes/pradera.tres"),
	preload("res://resources/world/biomes/bosque_rojo.tres"),
	preload("res://resources/world/biomes/nieve.tres")
]
## Frecuencia del ruido que reparte los biomas (por chunk); más bajo = biomas más grandes.
@export var biome_frequency: float = 0.12
## Contraste del ruido de biomas; más alto = extremos más frecuentes.
@export var biome_contrast: float = 2.0
## Bloques que dura la transición de color entre biomas (0 = un chunk completo).
@export var biome_transition_tiles: int = 0
## Nodos (Sprite2D) de los bosques y de la capa verde de la montaña que se tiñen con el bioma.
@export var forest_tint_paths: Array[NodePath] = [
	^"../far_forest/Sprite2D",
	^"../near_forest/Sprite2D",
	^"../mountains/Sprite2DGreen",
]
## Nodos (Sprite2D) de la piedra de la montaña, que usan el `rock_color` del bioma.
@export var rock_tint_paths: Array[NodePath] = [
	^"../mountains/Sprite2D",
]

@export_group("Spawns")
## Margen en tiles para no aparecer pegado al borde del chunk.
@export var enemy_spawn_margin_tiles: int = 2
## Tiles de margen seguro tras el spawn del jugador antes del primer enemigo.
@export var enemy_safe_gap_tiles: int = 20
## Chunks iniciales con menos enemigos (cuenta base × multiplicador).
@export var enemy_ramp_first_chunks: int = 2
## Multiplicador de enemigos en esos primeros chunks.
@export var enemy_ramp_first_multiplier: float = 0.5
## Subida del multiplicador por cada chunk más allá del tramo inicial.
@export var enemy_ramp_per_chunk: float = 0.2
## Tope del multiplicador de enemigos por chunk.
@export var enemy_ramp_max_multiplier: float = 1.8

@export_group("Monedas")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
@export var coins_per_chunk: int = 2
## Altura sobre el suelo a la que aparecen las monedas: después caen, rebotan y
## se asientan con su propia gravedad (`scripts/collectables/coin.gd`).
@export var coin_spawn_height: float = 40.0

@export_group("Chunks")
@export var chunk_scene: PackedScene = preload("res://scenes/world/chunk.tscn")

@onready var player: CharacterBody2D = get_parent().get_node_or_null("player")
@onready var _template_solid: TileMapLayer = get_node_or_null("solid_map_layer")
@onready var _template_grass: TileMapLayer = get_node_or_null("grass_map_layer")

var _noise := FastNoiseLite.new()
var _biome_noise := FastNoiseLite.new()
var _seed: int = 0
var _camera: Camera2D
var _loaded_chunks: Dictionary = {}
var _chunk_data: Dictionary = {}
var _defeated_spawns: Dictionary = {}
var _collected_spawns: Dictionary = {}
var _last_first: int = 999999
var _last_last: int = -999999
var _forest_tint_nodes: Array[CanvasItem] = []
var _rock_tint_nodes: Array[CanvasItem] = []
var _last_biome_tile: int = -999999


func _ready() -> void:
	# Los enemigos lo buscan por grupo para leer la configuración del mundo.
	add_to_group("world_generator")
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

	_biome_noise.seed = _seed + 1000
	_biome_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	# El bioma se decide por bloque: la frecuencia exportada sigue siendo por chunk.
	_biome_noise.frequency = biome_frequency / float(maxi(chunk_width_tiles, 1))

	if player:
		_camera = player.get_node_or_null("Camera2D") as Camera2D
		var spawn_x := safe_start_tiles * TILE_SIZE + TILE_SIZE / 2
		var spawn_y := _height_at(safe_start_tiles) * TILE_SIZE - player_spawn_height_tiles * TILE_SIZE
		player.position = Vector2(spawn_x, spawn_y)

	for path in forest_tint_paths:
		var node := get_node_or_null(path) as CanvasItem
		if node:
			_forest_tint_nodes.append(node)
	for path in rock_tint_paths:
		var node := get_node_or_null(path) as CanvasItem
		if node:
			_rock_tint_nodes.append(node)

	_update_chunks(true)
	_update_biome_tint(true)


func _process(_delta: float) -> void:
	if player:
		_update_chunks(false)
		_update_biome_tint(false)


# ==============================================================================
# ALTURA DEL TERRENO
# ==============================================================================
func _height_at(tile_x: int) -> int:
	var terrain := _terrain_at_tile(tile_x)
	return _height_at_with(tile_x, float(terrain["amplitude"]), float(terrain["frequency"]))


## Altura con los modificadores de bioma ya mezclados (los pasa el chunk).
func _height_at_with(tile_x: int, amplitude: float, frequency: float) -> int:
	if tile_x >= 0 and tile_x < safe_start_tiles:
		return base_height
	var h := _noise_height(tile_x, amplitude, frequency)
	if tile_x >= safe_start_tiles and tile_x < safe_start_tiles + start_blend_tiles:
		var t := float(tile_x - safe_start_tiles) / float(maxi(1, start_blend_tiles))
		return roundi(lerpf(base_height, h, t))
	return h


## Menos enemigos en los primeros chunks y bastantes más cuanto más lejos.
func _enemy_count_multiplier(chunk_x: int) -> float:
	if chunk_x < enemy_ramp_first_chunks:
		return enemy_ramp_first_multiplier
	var steps := float(chunk_x - enemy_ramp_first_chunks) + 1.0
	return minf(1.0 + enemy_ramp_per_chunk * steps, enemy_ramp_max_multiplier)


func _noise_height(tile_x: int, amplitude: float = 1.0, frequency: float = 1.0) -> int:
	# 3 samples para algo de suavizado sin aplanar demasiado.
	var value := 0.0
	for offset in range(-1, 2):
		value += _noise.get_noise_1d(float(tile_x + offset) * frequency)
	value /= 3.0
	return clampi(roundi(base_height + value * height_amplitude * amplitude), min_height, max_height)


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
	# Mantener cargados los chunks vecinos aunque la vista ya no los toque.
	first -= KEEP_CHUNKS_SIDE
	last += KEEP_CHUNKS_SIDE

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


## True cuando el chunk que contiene `world_x` ya está instanciado. Lo usa la
## caída inicial: sin mundo debajo, la caída no puede terminar.
func is_ready_at(world_x: float) -> bool:
	var coord_x := floori(world_x / float(chunk_width_tiles * TILE_SIZE))
	return _loaded_chunks.has(Vector2i(coord_x, 0))


## Índice del bioma de un bloque. Todo el primer chunk (incluidos los bloques
## negativos) es la zona segura con el primer bioma.
func _biome_index_at_tile(tile_x: int) -> int:
	if biomes.is_empty():
		return -1
	if tile_x < chunk_width_tiles:
		return 0
	var total := 0.0
	for biome in biomes:
		total += maxf(biome.spawn_weight, 0.0)
	if total <= 0.0:
		return 0
	# Mismo ruido de antes, muestreado bloque a bloque en vez de por chunk.
	var roll := _biome_noise.get_noise_1d(float(tile_x))
	roll = clampf(roll * biome_contrast + 0.5, 0.0, 1.0) * total
	for i in biomes.size():
		roll -= maxf(biomes[i].spawn_weight, 0.0)
		if roll <= 0.0:
			return i
	return biomes.size() - 1


## Bioma del bloque que contiene `world_x`; lo usan las partículas de ambiente.
func biome_at_world_x(world_x: float) -> Biome:
	var index := _biome_index_at_tile(floori(world_x / float(TILE_SIZE)))
	if index < 0:
		return null
	return biomes[index]


## Bioma del chunk para enemigos y recuentos: el del bloque central.
func _biome_for_chunk(chunk_x: int) -> Biome:
	var index := _biome_index_at_tile(chunk_x * chunk_width_tiles + chunk_width_tiles / 2)
	if index < 0:
		return null
	return biomes[index]


## Bloques que dura la transición entre dos biomas (0 = un chunk completo).
func _transition_tiles() -> int:
	return biome_transition_tiles if biome_transition_tiles > 0 else chunk_width_tiles


func _transition_half_tiles() -> int:
	return maxi(_transition_tiles() / 2, 0)


## Recuento de biomas en la ventana de transición de un bloque.
func _biome_counts_at_tile(tile_x: int) -> Dictionary:
	var half := _transition_half_tiles()
	var counts: Dictionary = {}
	for i in range(-half, half + 1):
		_add_biome_count(counts, tile_x + i)
	return counts


func _add_biome_count(counts: Dictionary, tile_x: int) -> void:
	var index := _biome_index_at_tile(tile_x)
	if index >= 0:
		counts[index] = int(counts.get(index, 0)) + 1


func _remove_biome_count(counts: Dictionary, tile_x: int) -> void:
	var index := _biome_index_at_tile(tile_x)
	if index < 0:
		return
	var remaining := int(counts.get(index, 0)) - 1
	if remaining <= 0:
		counts.erase(index)
	else:
		counts[index] = remaining


## Tinte de un canal del bioma en un bloque ("grass", "forest" o "rock").
func _biome_color_at_tile(tile_x: int, channel: String) -> Color:
	if biomes.is_empty():
		return Color.WHITE
	return _mixed_biome_color(_biome_counts_at_tile(tile_x), channel)


## Media de los colores de los biomas contados en la ventana. Cada bioma puede
## dar un color distinto para el césped, los bosques y la piedra de la montaña.
func _mixed_biome_color(counts: Dictionary, channel: String = "grass") -> Color:
	var samples := 0
	for index in range(biomes.size()):
		samples += int(counts.get(index, 0))
	if samples <= 0:
		return Color.WHITE
	var total := Color(0.0, 0.0, 0.0, 0.0)
	for index in range(biomes.size()):
		var biome := biomes[index]
		var color := biome.grass_color
		match channel:
			"forest":
				color = biome.forest_color
			"rock":
				color = biome.rock_color
		total += color * float(counts.get(index, 0))
	return total / float(samples)


## Media de los modificadores de terreno de la ventana. Orden fijo por índice
## para que dos chunks calculen exactamente el mismo float en su costura.
func _mixed_terrain(counts: Dictionary) -> Dictionary:
	var samples := 0
	var amplitude := 0.0
	var frequency := 0.0
	for index in range(biomes.size()):
		var weight := float(counts.get(index, 0))
		if weight <= 0.0:
			continue
		samples += int(weight)
		amplitude += biomes[index].terrain_amplitude_multiplier * weight
		frequency += biomes[index].terrain_frequency_multiplier * weight
	if samples <= 0:
		return {"amplitude": 1.0, "frequency": 1.0}
	return {
		"amplitude": amplitude / float(samples),
		"frequency": frequency / float(samples),
	}


## Modificadores del terreno ya mezclados para un bloque.
func _terrain_at_tile(tile_x: int) -> Dictionary:
	if biomes.is_empty():
		return {"amplitude": 1.0, "frequency": 1.0}
	return _mixed_terrain(_biome_counts_at_tile(tile_x))


## Datos de bioma del chunk (más la columna extra): colores del césped y
## modificadores del terreno en una sola pasada de ventana deslizante.
func _chunk_biome_data(chunk_x: int) -> Dictionary:
	var width := chunk_width_tiles
	var tints := PackedColorArray()
	var amplitudes := PackedFloat64Array()
	var frequencies := PackedFloat64Array()
	tints.resize(width + 1)
	amplitudes.resize(width + 1)
	frequencies.resize(width + 1)
	if biomes.is_empty():
		tints.fill(Color.WHITE)
		amplitudes.fill(1.0)
		frequencies.fill(1.0)
		return {"tints": tints, "amplitude": amplitudes, "frequency": frequencies}
	var half := _transition_half_tiles()
	var start_x := chunk_x * width
	var counts: Dictionary = {}
	for tile_x in range(start_x - half, start_x + half + 1):
		_add_biome_count(counts, tile_x)
	for i in range(width + 1):
		tints[i] = _mixed_biome_color(counts)
		var terrain := _mixed_terrain(counts)
		amplitudes[i] = float(terrain["amplitude"])
		frequencies[i] = float(terrain["frequency"])
		_remove_biome_count(counts, start_x + i - half)
		_add_biome_count(counts, start_x + i + half + 1)
	return {"tints": tints, "amplitude": amplitudes, "frequency": frequencies}


## Aplica el tinte del bioma actual a los bosques de fondo. Se actualiza al
## cambiar de bloque, no de chunk, para que el cambio sea continuo.
func _update_biome_tint(force: bool) -> void:
	if (_forest_tint_nodes.is_empty() and _rock_tint_nodes.is_empty()) or not player:
		return
	var tile_x := floori(player.global_position.x / float(TILE_SIZE))
	if not force and tile_x == _last_biome_tile:
		return
	_last_biome_tile = tile_x
	var forest := _biome_color_at_tile(tile_x, "forest")
	var rock := _biome_color_at_tile(tile_x, "rock")
	for node in _forest_tint_nodes:
		node.modulate = forest
	for node in _rock_tint_nodes:
		node.modulate = rock


func _generate_chunk(coord: Vector2i) -> Dictionary:
	var heights := PackedInt32Array()
	heights.resize(chunk_width_tiles)
	var start_x := coord.x * chunk_width_tiles
	# Colores del césped y modificadores del terreno del chunk en una sola pasada.
	var biome_data := _chunk_biome_data(coord.x)
	var amplitudes: PackedFloat64Array = biome_data["amplitude"]
	var frequencies: PackedFloat64Array = biome_data["frequency"]
	for i in range(chunk_width_tiles):
		heights[i] = _height_at_with(start_x + i, amplitudes[i], frequencies[i])
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
	var max_x := chunk_width_tiles - enemy_spawn_margin_tiles - 1
	# En el chunk del spawn los enemigos empiezan un poco más allá del jugador,
	# no en el chunk siguiente (antes había que andar media pantalla y pico).
	var enemy_min_x := min_x
	if coord.x == 0:
		enemy_min_x = maxi(enemy_min_x, safe_start_tiles + enemy_safe_gap_tiles)

	# Enemigos del bioma; si no define, los de la lista general.
	var biome := _biome_for_chunk(coord.x)
	var scenes: Array[PackedScene] = enemy_scenes
	var counts: Array[int] = enemy_counts_per_chunk
	if biome and not biome.enemy_scenes.is_empty():
		scenes = biome.enemy_scenes
		counts = biome.enemy_counts

	# Tipos del chunk antes de repartir las X (uno por enemigo).
	var spawn_scenes: Array[PackedScene] = []
	# Los primeros chunks van al 50 % y a partir de ahí cada chunk suma más.
	var count_multiplier := _enemy_count_multiplier(coord.x)
	for idx in range(scenes.size()):
		var count := 0
		if idx < counts.size():
			count = maxi(floori(float(counts[idx]) * count_multiplier), 0)
		for i in range(count):
			spawn_scenes.append(scenes[idx])

	# Reparto uniforme: un hueco por enemigo a lo ancho del chunk, con algo de
	# ruido para que no queden en fila. Antes cada enemigo tiraba su X al azar y
	# se apelotonaban todos en la misma zona del chunk.
	var enemies: Array[Dictionary] = []
	var total := spawn_scenes.size()
	var slot_width := float(maxi(max_x - enemy_min_x + 1, 1)) / float(maxi(total, 1))
	var jitter := maxi(floori(slot_width * 0.25), 0)
	for k in range(total):
		var spawn_id := "e:%d:%d:%d" % [coord.x, coord.y, k]
		# Consumir el RNG siempre para que las posiciones no cambien al persistir bajas.
		var offset_px := rng.randi_range(-jitter, jitter) if jitter > 0 else 0
		var local_x := clampi(
			enemy_min_x + floori((float(k) + 0.5) * slot_width) + offset_px,
			enemy_min_x,
			max_x
		)
		if _defeated_spawns.has(spawn_id) or spawn_scenes[k] == null:
			continue
		enemies.append({
			"id": spawn_id,
			"scene": spawn_scenes[k],
			"position": Vector2(local_x * TILE_SIZE, heights[local_x] * TILE_SIZE)
		})

	var coins: Array[Dictionary] = []
	for i in range(coins_per_chunk):
		var spawn_id := "c:%d:%d:%d" % [coord.x, coord.y, i]
		# Mismo motivo que con los enemigos: no alterar el orden del RNG.
		var local_x := rng.randi_range(min_x, max_x)
		if _collected_spawns.has(spawn_id):
			continue
		coins.append({
			"id": spawn_id,
			"position": Vector2(local_x * TILE_SIZE, heights[local_x] * TILE_SIZE - coin_spawn_height)
		})

	return {"heights": heights, "edge_left": edge_left, "edge_right": edge_right, "edge_right_next": edge_right_next, "enemies": enemies, "coins": coins, "biome": biome, "tints": biome_data["tints"]}


func _load_chunk(coord: Vector2i) -> void:
	if not _chunk_data.has(coord):
		_chunk_data[coord] = _generate_chunk(coord)
	var data: Dictionary = _chunk_data[coord]

	var tints: PackedColorArray = data.get("tints", PackedColorArray())
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
		swap_left_right,
		tints
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
