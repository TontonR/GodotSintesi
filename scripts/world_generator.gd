extends Node
## Procedural world by chunks. Owns the terrain height chain, the chunk
## streaming loop and the public API. Biome logic lives in WorldBiomeManager,
## decor selection/tinting in WorldDecorManager and entity spawning in
## WorldSpawner — each managed as a RefCounted, instantiated in _ready.

## Tile size in pixels. The only place where it is defined.
const TILE_SIZE := 16
## Extra chunks kept loaded on each side: enemies do not
## disappear when crossing a seam (only chunks 2 further back are freed).
const KEEP_CHUNKS_SIDE := 2

@export_group("World")
## World seed; 0 = random per run.
@export var world_seed: int = 0
## Width of each chunk in tiles.
@export var chunk_width_tiles: int = 256
## World bottom row. Terrain fills up to here. Must be greater than max_height.
@export var chunk_height_tiles: int = 140
## Flat tiles at the start so the player spawns safely.
@export var safe_start_tiles: int = 15
## Transition tiles between the flat start and the noise.
@export var start_blend_tiles: int = 24
## Extra margin in pixels to load the neighboring chunk before seeing it.
@export var load_margin_px: float = 96.0
## Height above the ground where the player spawns, in tiles.
@export var player_spawn_height_tiles: int = 6

@export_group("Terrain")
## Average ground height in tiles (the row grows downward).
@export var base_height: int = 60
## Maximum height variation; higher = bigger mountains.
@export var height_amplitude: float = 20.0
## Noise frequency; lower = wider mountains.
@export var noise_frequency: float = 0.007
@export var noise_octaves: int = 4
@export var noise_gain: float = 0.45
## Minimum ground row (highest peak). Do not go below 0.
@export var min_height: int = 5
## Maximum ground row (deepest valley).
@export var max_height: int = 110
## Maximum rise/drop between two neighboring columns, in tiles.
@export var max_step_tiles: int = 1

@export_group("Tiles")
## TileSet with the 3x3 atlas (surface, fill and reserved).
@export var solid_tile_set: TileSet
## Grass TileSet painted over the surface.
@export var grass_tile_set: TileSet
@export var tile_source_id: int = 0
## Atlas coordinate of tile 1 (top-left corner of the 3x3 block).
@export var tile_atlas_origin: Vector2i = Vector2i(0, 0)
## Enable if the left/right edges come out swapped.
@export var swap_left_right: bool = false

@export_group("Left wall")
## Columns painted left of tile 0 as a mountain.
@export var left_wall_tiles: int = 56
## First columns of the wall you can climb (1 tile each).
@export var left_wall_climb_tiles: int = 2
## Rows each wall column rises after the climbable stretch.
@export var left_wall_step_rows: int = 4

@export_group("Enemies")
## Enemy scene list (fallback if a biome does not define its own).
@export var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/orc.tscn"),
	preload("res://scenes/enemies/mutant_toad.tscn"),
	preload("res://scenes/enemies/werewolf.tscn"),
	preload("res://scenes/enemies/slime.tscn"),
	preload("res://scenes/enemies/skeleton.tscn"),
	preload("res://scenes/enemies/archer.tscn")
]
## Base counts per chunk, in the same order as the scenes.
@export var enemy_counts_per_chunk: Array[int] = [4, 2, 1, 2, 2, 2]

@export_group("Biomes")
## World biomes; the first one is the safe zone.
@export var biomes: Array[Biome] = [
	preload("res://resources/world/biomes/pradera.tres"),
	preload("res://resources/world/biomes/bosque_rojo.tres"),
	preload("res://resources/world/biomes/nieve.tres")
]
## Frequency of the noise that distributes biomes (per chunk).
@export var biome_frequency: float = 0.12
## Biome noise contrast; higher = extremes more frequent.
@export var biome_contrast: float = 2.0
## Lengths of the biome runs are rounded to this many tiles (0 = one chunk).
@export var biome_sector_tiles: int = 0
## Shortest a biome can last before it may change.
@export var min_biome_tiles: int = 512
## Longest a biome can last before it must change.
@export var max_biome_tiles: int = 2048
## Blocks the color transition between biomes lasts (0 = one full chunk).
@export var biome_transition_tiles: int = 0
## Nodes (Sprite2D) of the forests and the mountain's green layer.
@export var forest_tint_paths: Array[NodePath] = [
	^"../far_forest/Sprite2D",
	^"../near_forest/Sprite2D",
	^"../mountains/Sprite2DGreen",
]
## Nodes (Sprite2D) of the mountain rock.
@export var rock_tint_paths: Array[NodePath] = [
	^"../mountains/Sprite2D",
]
## Nodes (Sprite2D) of the mountain snow cap.
@export var snow_tint_paths: Array[NodePath] = [
	^"../mountains/Sprite2DSnow",
]
## Nodes (ColorRect) of the band under the mountains.
@export var base_tint_paths: Array[NodePath] = [
	^"../mountains/MountainBase",
]

@export_group("Spawns")
## Margin in tiles to avoid spawning glued to the chunk edge.
@export var enemy_spawn_margin_tiles: int = 2
## Safe margin tiles after the player spawn before the first enemy.
@export var enemy_safe_gap_tiles: int = 20
## Initial chunks with fewer enemies.
@export var enemy_ramp_first_chunks: int = 2
## Enemy multiplier in the first chunks.
@export var enemy_ramp_first_multiplier: float = 0.5
## Multiplier increase per chunk beyond the initial stretch.
@export var enemy_ramp_per_chunk: float = 0.2
## Cap on the per-chunk enemy multiplier.
@export var enemy_ramp_max_multiplier: float = 1.8

@export_group("Coins")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
@export var coins_per_chunk: int = 2
## Height above the ground where coins spawn.
@export var coin_spawn_height: float = 40.0

@export_group("Decor")
## Decor names the biomes use in `Biome.decor_kinds` (same order as arrays below).
@export var decor_names: Array[String] = [
	"bush_1", "bush_2", "tree", "tree_dead", "rock_1", "rock_2"
]
## Textures in `assets/map/decor`.
@export var decor_textures: Array[Texture2D] = [
	preload("res://assets/map/decor/Bush/bush_1.png"),
	preload("res://assets/map/decor/Bush/bush_2.png"),
	preload("res://assets/map/decor/Tree/tree.png"),
	preload("res://assets/map/decor/Tree/tree_dead.png"),
	preload("res://assets/map/decor/Rock/rock_1.png"),
	preload("res://assets/map/decor/Rock/rock_2.png"),
]
## Whether each texture takes the biome tint (same order).
@export var decor_tinted: Array[bool] = [true, true, true, false, false, false]
## Sprite scale (same order).
@export var decor_scales: Array[float] = [1.9, 1.9, 1.8, 1.8, 1.7, 1.7]
## Draw order inside the chunk; negative values go behind the grass row.
@export var decor_z_index: Array[int] = [0, 0, 0, 0, -1, -1]
## Bushes wobble and drop leaves while the player walks through them.
@export var decor_sways: Array[bool] = [true, true, false, false, false, false]
## Fallback weights for biomes without `decor_kinds`.
@export var decor_weights: Array[int] = [4, 4, 1, 1, 2, 2]
## Fallback decor per chunk for biomes without `decor_per_chunk`.
@export var decor_per_chunk: int = 16
## Margin in tiles to keep decor away from the chunk edges.
@export var decor_margin_tiles: int = 2
## Minimum gap in tiles between two decor props of the same chunk.
@export var decor_min_gap_tiles: int = 3
## Radius where a bush starts to bend and drop leaves (px).
@export var decor_sway_radius_px: float = 48.0

@export_group("Structures")
## Structures the biomes can name in `Biome.structure_kinds` (by `display_name`).
@export var structures: Array[WorldStructure] = [
	preload("res://resources/world/structures/tower_test.tres"),
	preload("res://resources/world/structures/ruin_test.tres"),
	preload("res://resources/world/structures/tent_test.tres")
]
## Minimum gap in tiles between two structures of the same chunk.
@export var structure_min_gap_tiles: int = 3

@export_group("Breakables")
## Crate scene spawned inside the type 2 ruins (T-0076).
@export var crate_scene: PackedScene = preload("res://scenes/world/breakable_block.tscn")
## Crates rolled per ruin; 0 disables them.
@export var crates_per_ruin: int = 2

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
## Slope-limited heights per chunk.
var _clamped_heights: Dictionary = {}
var _clamped_last: Dictionary = {}
var _last_first: int = 999999
var _last_last: int = -999999
var _last_biome_tile: int = -999999
## Mountain left of tile 0, left to right; chunk 0 only.
var _left_wall: PackedInt32Array = PackedInt32Array()

## Sub-managers (RefCounted, rebuilt per run).
var _biome: WorldBiomeManager
var _decor: WorldDecorManager
var _spawner: WorldSpawner


func _ready() -> void:
	add_to_group("world_generator")
	if solid_tile_set == null and _template_solid:
		solid_tile_set = _template_solid.tile_set
	if grass_tile_set == null and _template_grass:
		grass_tile_set = _template_grass.tile_set

	_seed = world_seed if world_seed != 0 else randi()
	if SaveGame.pending_seed != 0:
		_seed = SaveGame.pending_seed
		SaveGame.pending_seed = 0
	if SaveGame.pending_load:
		_seed = int(SaveGame.data.get("seed", _seed))

	_noise.seed = _seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = noise_frequency
	_noise.fractal_octaves = noise_octaves
	_noise.fractal_gain = noise_gain

	_build_biome_manager()
	_build_decor_manager()
	_build_spawner()

	if SaveGame.pending_load:
		_spawner.restore_state(SaveGame.data)

	if player:
		_camera = player.get_node_or_null("Camera2D") as Camera2D
		var spawn_x := safe_start_tiles * TILE_SIZE + TILE_SIZE / 2
		var spawn_y := _height_at(safe_start_tiles) * TILE_SIZE - player_spawn_height_tiles * TILE_SIZE
		player.position = Vector2(spawn_x, spawn_y)

	_update_chunks(true)
	_update_biome_tint(true)


func _process(_delta: float) -> void:
	if player:
		_keep_player_inside_world()
		_update_chunks(false)
		_update_biome_tint(false)


# ==============================================================================
# MANAGERS SETUP
# ==============================================================================

func _build_biome_manager() -> void:
	_biome = WorldBiomeManager.new()
	_biome.biomes = biomes
	_biome.chunk_width_tiles = chunk_width_tiles
	_biome.transition_tiles = biome_transition_tiles
	_biome.min_biome_tiles = min_biome_tiles
	_biome.max_biome_tiles = max_biome_tiles
	_biome.biome_sector_tiles = biome_sector_tiles
	_biome.biome_contrast = biome_contrast
	_biome.setup(_seed, biome_frequency)
	for path in forest_tint_paths:
		var node := get_node_or_null(path) as CanvasItem
		if node:
			_biome.forest_tint_nodes.append(node)
	for path in rock_tint_paths:
		var node := get_node_or_null(path) as CanvasItem
		if node:
			_biome.rock_tint_nodes.append(node)
	for path in snow_tint_paths:
		var node := get_node_or_null(path) as CanvasItem
		if node:
			_biome.snow_tint_nodes.append(node)
	for path in base_tint_paths:
		var node := get_node_or_null(path) as ColorRect
		if node:
			_biome.base_tint_nodes.append(node)


func _build_decor_manager() -> void:
	_decor = WorldDecorManager.new()
	_decor.decor_names = decor_names
	_decor.decor_textures = decor_textures
	_decor.decor_tinted = decor_tinted
	_decor.decor_scales = decor_scales
	_decor.decor_z_index = decor_z_index
	_decor.decor_sways = decor_sways
	_decor.decor_weights = decor_weights
	_decor.biome_manager = _biome


func _build_spawner() -> void:
	_spawner = WorldSpawner.new()
	_spawner.enemy_scenes = enemy_scenes
	_spawner.enemy_counts_per_chunk = enemy_counts_per_chunk
	_spawner.coin_scene = coin_scene
	_spawner.crate_scene = crate_scene
	_spawner.structures = structures
	_spawner.chunk_width_tiles = chunk_width_tiles
	_spawner.enemy_spawn_margin_tiles = enemy_spawn_margin_tiles
	_spawner.enemy_safe_gap_tiles = enemy_safe_gap_tiles
	_spawner.enemy_ramp_first_chunks = enemy_ramp_first_chunks
	_spawner.enemy_ramp_first_multiplier = enemy_ramp_first_multiplier
	_spawner.enemy_ramp_per_chunk = enemy_ramp_per_chunk
	_spawner.enemy_ramp_max_multiplier = enemy_ramp_max_multiplier
	_spawner.coins_per_chunk = coins_per_chunk
	_spawner.coin_spawn_height = coin_spawn_height
	_spawner.crates_per_ruin = crates_per_ruin
	_spawner.structure_min_gap_tiles = structure_min_gap_tiles
	_spawner.decor_sway_radius_px = decor_sway_radius_px
	_spawner.decor_manager = _decor


# ==============================================================================
# TERRAIN HEIGHT
# ==============================================================================

func _height_at(tile_x: int) -> int:
	if tile_x < 0:
		if left_wall_tiles <= 0:
			return base_height
		return _left_wall_height_at(clampi(tile_x, -left_wall_tiles, -1))
	var chunk_x := floori(float(tile_x) / float(chunk_width_tiles))
	var local := tile_x - chunk_x * chunk_width_tiles
	return _clamped_heights_for(chunk_x)[local + 1]


func _clamped_heights_for(chunk_x: int) -> PackedInt32Array:
	if _clamped_heights.has(chunk_x):
		return _clamped_heights[chunk_x]
	var chain: Array[int] = []
	var x := chunk_x
	while x > 0 and not _clamped_last.has(x - 1):
		chain.push_front(x)
		x -= 1
	chain.push_front(x)
	for cx in chain:
		if not _clamped_heights.has(cx):
			_build_clamped_heights(cx)
	return _clamped_heights[chunk_x]


func _build_clamped_heights(chunk_x: int) -> void:
	var start_x := chunk_x * chunk_width_tiles
	var biome_data := _biome.chunk_biome_data(chunk_x)
	var amplitudes: PackedFloat64Array = biome_data["amplitude"]
	var frequencies: PackedFloat64Array = biome_data["frequency"]
	var heights := PackedInt32Array()
	heights.resize(chunk_width_tiles + 2)
	var prev := base_height
	if chunk_x > 0:
		prev = int(_clamped_last[chunk_x - 1])
	heights[0] = prev
	for i in range(1, chunk_width_tiles + 2):
		var j := mini(i - 1, chunk_width_tiles)
		var h := _height_at_with(start_x + i - 1, amplitudes[j], frequencies[j])
		h = clampi(h, prev - max_step_tiles, prev + max_step_tiles)
		heights[i] = h
		prev = h
	_clamped_heights[chunk_x] = heights
	_clamped_last[chunk_x] = heights[chunk_width_tiles]


func _height_at_with(tile_x: int, amplitude: float, frequency: float) -> int:
	if tile_x < safe_start_tiles:
		return base_height
	var h := _noise_height(tile_x, amplitude, frequency)
	if tile_x >= safe_start_tiles and tile_x < safe_start_tiles + start_blend_tiles:
		var t := float(tile_x - safe_start_tiles) / float(maxi(1, start_blend_tiles))
		return roundi(lerpf(base_height, h, t))
	return h


func _noise_height(tile_x: int, amplitude: float = 1.0, frequency: float = 1.0) -> int:
	var value := 0.0
	for offset in range(-1, 2):
		value += _noise.get_noise_1d(float(tile_x + offset) * frequency)
	value /= 3.0
	return clampi(roundi(base_height + value * height_amplitude * amplitude), min_height, max_height)


func _left_wall_height_at(tile_x: int) -> int:
	var count := maxi(left_wall_tiles, 0)
	if count <= 0:
		return base_height
	if _left_wall.is_empty():
		_left_wall = _left_wall_heights()
	return _left_wall[clampi(tile_x + count, 0, count - 1)]


func _left_wall_heights() -> PackedInt32Array:
	var count := maxi(left_wall_tiles, 0)
	var heights := PackedInt32Array()
	heights.resize(count)
	var row := base_height
	for i in count:
		if i < left_wall_climb_tiles:
			row = maxi(row - 1, min_height)
		else:
			row = maxi(row - left_wall_step_rows, min_height)
		heights[count - 1 - i] = row
	return heights


func _keep_player_inside_world() -> void:
	var min_x := TILE_SIZE
	if left_wall_tiles > 0:
		min_x = -maxi(left_wall_tiles - 1, 0) * TILE_SIZE
	if player.global_position.x < min_x:
		player.global_position = Vector2(min_x, player.global_position.y)
		player.velocity.x = maxf(player.velocity.x, 0.0)


# ==============================================================================
# CHUNK STREAMING
# ==============================================================================

func _update_chunks(force: bool) -> void:
	if not player:
		return
	var center_x := player.global_position.x
	var zoom_x := 1.0
	if _camera:
		center_x = _camera.get_screen_center_position().x
		zoom_x = _camera.zoom.x
	var half_width := get_viewport().get_visible_rect().size.x / zoom_x * 0.5
	if absf(center_x - player.global_position.x) > half_width + load_margin_px:
		center_x = player.global_position.x
	var chunk_width_px := float(chunk_width_tiles * TILE_SIZE)
	var first := floori((center_x - half_width - load_margin_px) / chunk_width_px)
	var last := floori((center_x + half_width + load_margin_px) / chunk_width_px)
	var current := floori(player.global_position.x / chunk_width_px)
	first = mini(first, current)
	last = maxi(last, current)
	first -= KEEP_CHUNKS_SIDE
	last += KEEP_CHUNKS_SIDE
	first = maxi(first, 0)
	last = maxi(last, 0)
	if not force and first == _last_first and last == _last_last:
		return
	_last_first = first
	_last_last = last
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
	for coord in _chunk_data.keys():
		if coord.x < first or coord.x > last + 1:
			_chunk_data.erase(coord)
	for chunk_x in _clamped_heights.keys():
		if chunk_x < first or chunk_x > last + 1:
			_clamped_heights.erase(chunk_x)


func _update_biome_tint(force: bool) -> void:
	if not player:
		return
	var tile_x := floori(player.global_position.x / float(TILE_SIZE))
	_last_biome_tile = _biome.update_biome_tint(tile_x, force, _last_biome_tile)


func _generate_chunk(coord: Vector2i) -> Dictionary:
	var clamped := _clamped_heights_for(coord.x)
	var heights := PackedInt32Array()
	heights.resize(chunk_width_tiles)
	for i in range(chunk_width_tiles):
		heights[i] = clamped[i + 1]
	var biome_data := _biome.chunk_biome_data(coord.x)
	var edge_left := clamped[0]
	var edge_right := clamped[chunk_width_tiles + 1]
	var edge_right_next := _height_at(coord.x * chunk_width_tiles + chunk_width_tiles + 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:%d" % [_seed, coord.x, coord.y])
	var biome := _biome.biome_for_chunk(coord.x)

	# Enemies and coins
	var spawn_data := _spawner.roll_chunk_data(coord, biome, heights, rng)
	var enemies: Array[Dictionary] = spawn_data["enemies"]
	var coins: Array[Dictionary] = spawn_data["coins"]

	# Decor
	var decor_min_x := clampi(decor_margin_tiles, 0, chunk_width_tiles - 1)
	var decor_max_x := clampi(chunk_width_tiles - decor_margin_tiles - 1, decor_min_x, chunk_width_tiles - 1)
	var decor_count := decor_per_chunk
	if biome and biome.decor_per_chunk > 0:
		decor_count = biome.decor_per_chunk
	var decor: Array[Dictionary] = []
	var decor_span := decor_max_x - decor_min_x + 1
	var decor_slot := float(decor_span) / float(maxi(decor_count, 1))
	var decor_jitter := mini(floori(decor_slot * 0.3), maxi(decor_min_gap_tiles - 1, 0))
	var last_decor_x := -999999
	for i in range(maxi(decor_count, 0)):
		var kind := _decor.pick_decor_kind(biome, rng)
		var center := decor_min_x + floori((float(i) + 0.5) * decor_slot)
		var local_x := clampi(
			center + rng.randi_range(-decor_jitter, decor_jitter), decor_min_x, decor_max_x
		)
		if kind < 0:
			continue
		if local_x - last_decor_x < decor_min_gap_tiles:
			local_x = center
			if local_x - last_decor_x < decor_min_gap_tiles:
				continue
		var tint := Color.WHITE
		if kind < decor_tinted.size() and decor_tinted[kind]:
			tint = _decor.tint_at(coord.x * chunk_width_tiles + local_x, rng)
		decor.append({"kind": kind, "tint": tint, "x": local_x})
		last_decor_x = local_x
	_decor.apply_dead_tree_ratio(biome, decor, rng)
	decor.sort_custom(_decor.draws_before)

	# Structures
	var structures_here := _spawner.roll_structures(coord, biome, heights, enemies, rng)
	for entry in structures_here:
		if not bool(entry.get("flatten", false)):
			continue
		var span_half := int(entry["half"])
		var flat := int(entry["y"])
		for dx in range(-span_half, span_half + 1):
			var tile := clampi(int(entry["x"]) + dx, 0, chunk_width_tiles - 1)
			flat = mini(flat, int(heights[tile]))
		for dx in range(-span_half, span_half + 1):
			heights[clampi(int(entry["x"]) + dx, 0, chunk_width_tiles - 1)] = flat
		entry["y"] = flat
		_spawner.level_entities(enemies, coins, int(entry["x"]), span_half, flat)
	if not structures_here.is_empty():
		decor = _spawner.decor_outside_structures(decor, structures_here)

	return {
		"heights": heights,
		"edge_left": edge_left,
		"edge_right": edge_right,
		"edge_right_next": edge_right_next,
		"enemies": enemies,
		"coins": coins,
		"decor": decor,
		"structures": structures_here,
		"biome": biome,
		"tints": biome_data["tints"]
	}


func _load_chunk(coord: Vector2i) -> void:
	if not _chunk_data.has(coord):
		_chunk_data[coord] = _generate_chunk(coord)
	var data: Dictionary = _chunk_data[coord]
	var tints: PackedColorArray = data.get("tints", PackedColorArray())
	var chunk: WorldChunk = chunk_scene.instantiate()
	chunk.name = "Chunk_%d" % coord.x
	chunk.position = Vector2(coord.x * chunk_width_tiles * TILE_SIZE, 0)
	add_child(chunk)
	var wall := PackedInt32Array()
	if coord.x == 0 and left_wall_tiles > 0:
		if _left_wall.is_empty():
			_left_wall = _left_wall_heights()
		wall = _left_wall
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
		tints,
		wall
	)
	_spawner.spawn_chunk_entities(chunk, data)
	_loaded_chunks[coord] = chunk


func _unload_chunk(coord: Vector2i) -> void:
	var chunk := _loaded_chunks.get(coord) as WorldChunk
	if is_instance_valid(chunk):
		chunk.queue_free()
	_loaded_chunks.erase(coord)


## Frees every loaded chunk but keeps the run seed and persistent ids.
func unload_chunks() -> void:
	for coord in _loaded_chunks.keys():
		var chunk := _loaded_chunks.get(coord) as WorldChunk
		_loaded_chunks.erase(coord)
		if is_instance_valid(chunk):
			remove_child(chunk)
			chunk.queue_free()


# ==============================================================================
# PUBLIC API
# ==============================================================================

## True when the chunk containing `world_x` is already instantiated.
func is_ready_at(world_x: float) -> bool:
	var coord_x := floori(world_x / float(chunk_width_tiles * TILE_SIZE))
	return _loaded_chunks.has(Vector2i(coord_x, 0))


## Forces an immediate chunk rebuild around the player.
func refresh_chunks() -> void:
	_update_chunks(true)


## Tiles traveled from the spawn point.
func meters_at(world_x: float) -> int:
	var spawn_x := float(safe_start_tiles) * float(TILE_SIZE) + float(TILE_SIZE) * 0.5
	return floori((world_x - spawn_x) / float(TILE_SIZE))


## Seed of this run.
func current_seed() -> int:
	return _seed


## Ground Y in pixels at `world_x`.
func ground_y_at(world_x: float) -> float:
	return float(_height_at(floori(world_x / float(TILE_SIZE))) * TILE_SIZE)


## Chunk index (x) containing `world_x`.
func chunk_at_world_x(world_x: float) -> int:
	return maxi(floori(world_x / float(chunk_width_tiles * TILE_SIZE)), 0)


## Biome of the block containing `world_x`.
func biome_at_world_x(world_x: float) -> Biome:
	return _biome.biome_at_world_x(world_x, TILE_SIZE)


## Share (0..1) of the ambient blend window around `world_x` whose biome uses
## `ambient`; the ambient VFX chase this so leaves and snow crossfade.
func ambient_weight_at_world_x(world_x: float, ambient: String) -> float:
	return _biome.ambient_weight_at_world_x(world_x, TILE_SIZE, ambient)


## Start X in pixels of the next biome run to the right of `world_x`.
func next_biome_start_x(world_x: float) -> float:
	return _biome.next_biome_start_x(world_x, TILE_SIZE)


## Nearest structure X to the right of `world_x`; -1 when none in range.
func next_structure_x(world_x: float, search_chunks: int = 64) -> float:
	var first := chunk_at_world_x(world_x)
	for i in range(search_chunks):
		var coord := Vector2i(first + i, 0)
		if not _chunk_data.has(coord):
			_chunk_data[coord] = _generate_chunk(coord)
		var nearest := -1.0
		for entry in _chunk_data[coord]["structures"]:
			var x := (coord.x * chunk_width_tiles + int(entry["x"])) * TILE_SIZE + TILE_SIZE * 0.5
			if x > world_x + 1.0 and (nearest < 0.0 or x < nearest):
				nearest = x
		if nearest >= 0.0:
			return nearest
	return -1.0


## Persistent ids for save/load (defeated enemies, coins, broken crates).
func save_persistent_state() -> Dictionary:
	return _spawner.save_state()
