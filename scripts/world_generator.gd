extends Node

# ==============================================================================
# PROCEDURAL WORLD BY CHUNKS
# ==============================================================================

## Tile size in pixels. The only place where it is defined.
const TILE_SIZE := 16
## Extra chunks kept loaded on each side: enemies do not
## disappear when crossing a seam (only chunks 2 further back are freed).
const KEEP_CHUNKS_SIDE := 2
## The mountain base band darkens the biome's forest color by this factor
## (the meadow's `#283D43` comes out of `forest_color` darkened 0.35).
const MOUNTAIN_BASE_DARKENING := 0.35

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
## Frequency of the noise that distributes biomes (per chunk); lower = bigger biomes.
@export var biome_frequency: float = 0.12
## Biome noise contrast; higher = extremes more frequent.
@export var biome_contrast: float = 2.0
## Lengths of the biome runs are rounded to this many tiles (0 = one chunk).
@export var biome_sector_tiles: int = 0
## Shortest a biome can last before it may change (avoids micro-biomes).
@export var min_biome_tiles: int = 1024
## Longest a biome can last before it has to change (avoids endless ones).
@export var max_biome_tiles: int = 4096
## Blocks the color transition between biomes lasts (0 = one full chunk).
@export var biome_transition_tiles: int = 0
## Nodes (Sprite2D) of the forests and the mountain's green layer tinted by the biome.
@export var forest_tint_paths: Array[NodePath] = [
	^"../far_forest/Sprite2D",
	^"../near_forest/Sprite2D",
	^"../mountains/Sprite2DGreen",
]
## Nodes (Sprite2D) of the mountain rock, which use the biome's `rock_color`.
@export var rock_tint_paths: Array[NodePath] = [
	^"../mountains/Sprite2D",
]
## Nodes (ColorRect) of the band under the mountains: they take a dark
## shade of the biome's `forest_color`.
@export var base_tint_paths: Array[NodePath] = [
	^"../mountains/MountainBase",
]

@export_group("Spawns")
## Margin in tiles to avoid spawning glued to the chunk edge.
@export var enemy_spawn_margin_tiles: int = 2
## Safe margin tiles after the player spawn before the first enemy.
@export var enemy_safe_gap_tiles: int = 20
## Initial chunks with fewer enemies (base count × multiplier).
@export var enemy_ramp_first_chunks: int = 2
## Enemy multiplier in those first chunks.
@export var enemy_ramp_first_multiplier: float = 0.5
## Multiplier increase per chunk beyond the initial stretch.
@export var enemy_ramp_per_chunk: float = 0.2
## Cap on the per-chunk enemy multiplier.
@export var enemy_ramp_max_multiplier: float = 1.8

@export_group("Coins")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
@export var coins_per_chunk: int = 2
## Height above the ground where coins spawn: they then fall, bounce and
## settle with their own gravity (`scripts/collectables/coin.gd`).
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
var _base_tint_nodes: Array[ColorRect] = []
var _last_biome_tile: int = -999999
## Biome runs already decided, in order: {start, index, length} in tiles.
var _biome_runs: Array[Dictionary] = []


func _ready() -> void:
	# Enemies find it by group to read the world configuration.
	add_to_group("world_generator")
	# The old layer stays in game.tscn as a TileSet template.
	if solid_tile_set == null and _template_solid:
		solid_tile_set = _template_solid.tile_set
	if grass_tile_set == null and _template_grass:
		grass_tile_set = _template_grass.tile_set

	_seed = world_seed if world_seed != 0 else randi()
	# New Game: the seed typed in the menu (0 = the random one above).
	if SaveGame.pending_seed != 0:
		_seed = SaveGame.pending_seed
		SaveGame.pending_seed = 0
	# Continue: same world and spawn state as the saved run.
	if SaveGame.pending_load:
		_seed = int(SaveGame.data.get("seed", _seed))
		_restore_persistent_state()
	_noise.seed = _seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = noise_frequency
	_noise.fractal_octaves = noise_octaves
	_noise.fractal_gain = noise_gain

	_biome_noise.seed = _seed + 1000
	_biome_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	# Biome is decided per block: the exported frequency is still per chunk.
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
	for path in base_tint_paths:
		var node := get_node_or_null(path) as ColorRect
		if node:
			_base_tint_nodes.append(node)

	_update_chunks(true)
	_update_biome_tint(true)


func _process(_delta: float) -> void:
	if player:
		_keep_player_inside_world()
		_update_chunks(false)
		_update_biome_tint(false)


# ==============================================================================
# TERRAIN HEIGHT
# ==============================================================================
func _height_at(tile_x: int) -> int:
	var terrain := _terrain_at_tile(tile_x)
	return _height_at_with(tile_x, float(terrain["amplitude"]), float(terrain["frequency"]))


## Height with biome modifiers already mixed (passed by the chunk).
func _height_at_with(tile_x: int, amplitude: float, frequency: float) -> int:
	# Nothing exists left of the start: flat ground, so chunk 0's left edge matches.
	if tile_x < safe_start_tiles:
		return base_height
	var h := _noise_height(tile_x, amplitude, frequency)
	if tile_x >= safe_start_tiles and tile_x < safe_start_tiles + start_blend_tiles:
		var t := float(tile_x - safe_start_tiles) / float(maxi(1, start_blend_tiles))
		return roundi(lerpf(base_height, h, t))
	return h


## The world only grows to the right. Walking off the left edge of chunk 0
## would drop the player into the void, so the edge works as a wall.
func _keep_player_inside_world() -> void:
	if player.global_position.x < TILE_SIZE:
		player.global_position = Vector2(TILE_SIZE, player.global_position.y)
		player.velocity.x = maxf(player.velocity.x, 0.0)


## Fewer enemies in the first chunks and many more the further away.
func _enemy_count_multiplier(chunk_x: int) -> float:
	if chunk_x < enemy_ramp_first_chunks:
		return enemy_ramp_first_multiplier
	var steps := float(chunk_x - enemy_ramp_first_chunks) + 1.0
	return minf(1.0 + enemy_ramp_per_chunk * steps, enemy_ramp_max_multiplier)


func _noise_height(tile_x: int, amplitude: float = 1.0, frequency: float = 1.0) -> int:
	# 3 samples for some smoothing without flattening too much.
	var value := 0.0
	for offset in range(-1, 2):
		value += _noise.get_noise_1d(float(tile_x + offset) * frequency)
	value /= 3.0
	return clampi(roundi(base_height + value * height_amplitude * amplitude), min_height, max_height)


# ==============================================================================
# CHUNK LOAD / UNLOAD
# ==============================================================================
func _update_chunks(force: bool) -> void:
	if not player:
		return

	# Real view center (respects smoothing, drag and limits) and visible
	# width in world coordinates (viewport / zoom).
	var center_x := player.global_position.x
	var zoom_x := 1.0
	if _camera:
		center_x = _camera.get_screen_center_position().x
		zoom_x = _camera.zoom.x
	var half_width := get_viewport().get_visible_rect().size.x / zoom_x * 0.5
	var chunk_width_px := float(chunk_width_tiles * TILE_SIZE)
	var first := floori((center_x - half_width - load_margin_px) / chunk_width_px)
	var last := floori((center_x + half_width + load_margin_px) / chunk_width_px)

	# The player's chunk is never unloaded.
	var current := floori(player.global_position.x / chunk_width_px)
	first = mini(first, current)
	last = maxi(last, current)
	# Keep neighboring chunks loaded even if the view no longer touches them.
	first -= KEEP_CHUNKS_SIDE
	last += KEEP_CHUNKS_SIDE
	# No chunk is generated to the left of the start: the world only grows
	# to the right, so nothing is spent on terrain the player never sees.
	first = maxi(first, 0)
	last = maxi(last, 0)

	if not force and first == _last_first and last == _last_last:
		return
	_last_first = first
	_last_last = last

	# Data first (only the visible ones + 1 to the right to anticipate).
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

	# Free data of chunks that are far away (outside first..last+1).
	for coord in _chunk_data.keys():
		if coord.x < first or coord.x > last + 1:
			_chunk_data.erase(coord)


## True when the chunk containing `world_x` is already instantiated. Used by the
## initial fall: without world below, the fall cannot end.
func is_ready_at(world_x: float) -> bool:
	var coord_x := floori(world_x / float(chunk_width_tiles * TILE_SIZE))
	return _loaded_chunks.has(Vector2i(coord_x, 0))


## Loads the chunks around the player right now. The game root calls it after
## restoring a saved position, so the ground exists on the next frame.
func refresh_chunks() -> void:
	_update_chunks(true)


## Seed of this run; the save stores it to rebuild the same world.
func current_seed() -> int:
	return _seed


## Spawn ids that must survive a save/load (killed enemies, taken coins).
func save_persistent_state() -> Dictionary:
	return {
		"defeated": PackedStringArray(_defeated_spawns.keys()),
		"collected": PackedStringArray(_collected_spawns.keys()),
	}


func _restore_persistent_state() -> void:
	for id in SaveGame.data.get("defeated", []):
		_defeated_spawns[String(id)] = true
	for id in SaveGame.data.get("collected", []):
		_collected_spawns[String(id)] = true


## Biome index of a block. The first run is the safe zone with the first biome.
## Runs are decided left to right and cached, so any block is cheap to query.
func _biome_index_at_tile(tile_x: int) -> int:
	if biomes.is_empty():
		return -1
	if tile_x < 0:
		tile_x = 0
	_ensure_biome_runs(tile_x)
	var index := int(_biome_runs[0]["index"])
	for run in _biome_runs:
		if tile_x < int(run["start"]):
			break
		index = int(run["index"])
	return index


## Decides new runs until the one containing `tile_x` exists.
func _ensure_biome_runs(tile_x: int) -> void:
	if _biome_runs.is_empty():
		_biome_runs.append(_make_biome_run(0, -1))
	while tile_x >= int(_biome_runs.back()["start"]) + int(_biome_runs.back()["length"]):
		var previous: Dictionary = _biome_runs.back()
		var start := int(previous["start"]) + int(previous["length"])
		_biome_runs.append(_make_biome_run(start, int(previous["index"])))


## A biome run: its biome never repeats the previous one and must already be
## unlocked at that distance. The length is rolled between `min_biome_tiles`
## and `max_biome_tiles`, so there are no micro-biomes and no endless stretches.
func _make_biome_run(start_tile: int, previous_index: int) -> Dictionary:
	var index := 0 if previous_index < 0 else _roll_biome_at(start_tile, previous_index)
	var sector := biome_sector_tiles if biome_sector_tiles > 0 else chunk_width_tiles
	var shortest := maxi(min_biome_tiles, sector)
	var longest := maxi(max_biome_tiles, shortest)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:biome:%d" % [_seed, start_tile])
	var length := shortest + rng.randi_range(0, (longest - shortest) / sector) * sector
	return {"start": start_tile, "index": index, "length": length}


## Weighted pick among the biomes unlocked at `tile_x`, never the previous one:
## the noise decides the order, not how long a biome lasts.
func _roll_biome_at(tile_x: int, previous_index: int) -> int:
	var allowed: Array[int] = []
	var total := 0.0
	for i in biomes.size():
		if i == previous_index:
			continue
		if biomes[i].min_distance_tiles > tile_x:
			continue
		var weight := maxf(biomes[i].spawn_weight, 0.0)
		if weight <= 0.0:
			continue
		allowed.append(i)
		total += weight
	if allowed.is_empty():
		return previous_index if previous_index >= 0 else 0
	var roll := clampf(_biome_noise.get_noise_1d(float(tile_x)) * biome_contrast + 0.5, 0.0, 1.0) * total
	for i in allowed:
		roll -= maxf(biomes[i].spawn_weight, 0.0)
		if roll <= 0.0:
			return i
	return allowed.back()


## Biome of the block containing `world_x`; used by ambient particles.
func biome_at_world_x(world_x: float) -> Biome:
	var index := _biome_index_at_tile(floori(world_x / float(TILE_SIZE)))
	if index < 0:
		return null
	return biomes[index]


## Chunk biome for enemies and counts: the one at the central block.
func _biome_for_chunk(chunk_x: int) -> Biome:
	var index := _biome_index_at_tile(chunk_x * chunk_width_tiles + chunk_width_tiles / 2)
	if index < 0:
		return null
	return biomes[index]


## Blocks the transition between two biomes lasts (0 = one full chunk).
func _transition_tiles() -> int:
	return biome_transition_tiles if biome_transition_tiles > 0 else chunk_width_tiles


func _transition_half_tiles() -> int:
	return maxi(_transition_tiles() / 2, 0)


## Biome counts in the transition window of a block.
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


## Biome channel tint at a block ("grass", "forest" or "rock").
func _biome_color_at_tile(tile_x: int, channel: String) -> Color:
	if biomes.is_empty():
		return Color.WHITE
	return _mixed_biome_color(_biome_counts_at_tile(tile_x), channel)


## Average of the biome colors counted in the window. Each biome can
## give a different color for grass, forests and mountain rock.
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


## Average of the window's terrain modifiers. Fixed order by index
## so two chunks compute exactly the same float at their seam.
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


## Terrain modifiers already mixed for a block.
func _terrain_at_tile(tile_x: int) -> Dictionary:
	if biomes.is_empty():
		return {"amplitude": 1.0, "frequency": 1.0}
	return _mixed_terrain(_biome_counts_at_tile(tile_x))


## Chunk biome data (plus the extra column): grass colors and
## terrain modifiers in a single sliding-window pass.
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


## Applies the current biome tint to the background forests, the mountain
## stone and the band under the mountains. Updated when the block changes,
## not the chunk, so the change is continuous.
func _update_biome_tint(force: bool) -> void:
	if (_forest_tint_nodes.is_empty() and _rock_tint_nodes.is_empty() and _base_tint_nodes.is_empty()) or not player:
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
	var base := forest.darkened(MOUNTAIN_BASE_DARKENING)
	for node in _base_tint_nodes:
		node.color = base


func _generate_chunk(coord: Vector2i) -> Dictionary:
	var heights := PackedInt32Array()
	heights.resize(chunk_width_tiles)
	var start_x := coord.x * chunk_width_tiles
	# Grass colors and chunk terrain modifiers in a single pass.
	var biome_data := _chunk_biome_data(coord.x)
	var amplitudes: PackedFloat64Array = biome_data["amplitude"]
	var frequencies: PackedFloat64Array = biome_data["frequency"]
	for i in range(chunk_width_tiles):
		heights[i] = _height_at_with(start_x + i, amplitudes[i], frequencies[i])
	# Neighbor heights to choose the left/right edge tiles.
	var edge_left := _height_at(start_x - 1)
	var edge_right := _height_at(start_x + chunk_width_tiles)
	# Height of the next column: the chunk paints an extra column to
	# cover the 1 px gap between two chunks' layers.
	var edge_right_next := _height_at(start_x + chunk_width_tiles + 1)

	# Same seed + same chunk = same spawns.
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:%d" % [_seed, coord.x, coord.y])

	var min_x := enemy_spawn_margin_tiles
	var max_x := chunk_width_tiles - enemy_spawn_margin_tiles - 1
	# In the spawn chunk enemies start a bit beyond the player,
	# not in the next chunk (before you had to walk over half a screen).
	var enemy_min_x := min_x
	if coord.x == 0:
		enemy_min_x = maxi(enemy_min_x, safe_start_tiles + enemy_safe_gap_tiles)

	# Biome enemies; if it does not define any, those from the general list.
	var biome := _biome_for_chunk(coord.x)
	var scenes: Array[PackedScene] = enemy_scenes
	var counts: Array[int] = enemy_counts_per_chunk
	if biome and not biome.enemy_scenes.is_empty():
		scenes = biome.enemy_scenes
		counts = biome.enemy_counts

	# Chunk types before distributing X positions (one per enemy).
	var spawn_scenes: Array[PackedScene] = []
	# The first chunks go at 50% and from there each chunk adds more.
	var count_multiplier := _enemy_count_multiplier(coord.x)
	for idx in range(scenes.size()):
		var count := 0
		if idx < counts.size():
			count = maxi(floori(float(counts[idx]) * count_multiplier), 0)
		for i in range(count):
			spawn_scenes.append(scenes[idx])

	# Uniform distribution: one slot per enemy across the chunk, with some
	# noise so they don't line up. Before, each enemy rolled its X at random and
	# they all bunched up in the same chunk area.
	var enemies: Array[Dictionary] = []
	var total := spawn_scenes.size()
	var slot_width := float(maxi(max_x - enemy_min_x + 1, 1)) / float(maxi(total, 1))
	var jitter := maxi(floori(slot_width * 0.25), 0)
	for k in range(total):
		var spawn_id := "e:%d:%d:%d" % [coord.x, coord.y, k]
		# Always consume the RNG so positions don't change when kills persist.
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
		# Same reason as with enemies: do not alter the RNG order.
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
		# The collider base rests on the ground (the origin is usually higher).
		# `spawn_y_offset` corrects those whose drawing is lower than the collider.
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


## Distance from the origin to the body collider base (to rest it on the ground).
func _body_bottom(enemy: Node2D) -> float:
	# shortcut: only direct RectangleShape2D colliders; extend if the shape changes.
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
