class_name WorldBiomeManager
extends RefCounted
## Manages biome runs, blended colors and terrain modifiers for WorldGenerator.
##
## Responsibilities: deciding which biome is active at a given tile, blending
## colors across transition windows, and providing per-chunk amplitude/frequency
## arrays for terrain generation. It is stateless except for the cached run list
## and is rebuilt whenever the world seed changes.

## Blocks the transition between two biomes lasts (0 = one full chunk).
var transition_tiles: int = 0
## Shortest a biome can last before it may change.
var min_biome_tiles: int = 512
## Longest a biome can last before it must change.
var max_biome_tiles: int = 2048
## Lengths of the biome runs are rounded to this many tiles (0 = one chunk).
var biome_sector_tiles: int = 0
## Noise contrast for biome rolls; higher = extremes more frequent.
var biome_contrast: float = 2.0

## Set by WorldGenerator after init.
var biomes: Array[Biome] = []
var chunk_width_tiles: int = 256

## Internal state.
var _seed: int = 0
var _biome_noise := FastNoiseLite.new()
var _biome_runs: Array[Dictionary] = []

## Background tint nodes filled by WorldGenerator at _ready.
var forest_tint_nodes: Array[CanvasItem] = []
var rock_tint_nodes: Array[CanvasItem] = []
var snow_tint_nodes: Array[CanvasItem] = []
var base_tint_nodes: Array[ColorRect] = []

const MOUNTAIN_BASE_DARKENING := 0.35
## Tiles on each side over which the ambient VFX crossfade between biomes.
const AMBIENT_BLEND_TILES := 32


func setup(world_seed: int, biome_frequency: float) -> void:
	_seed = world_seed
	_biome_runs.clear()
	_biome_noise.seed = _seed + 1000
	_biome_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_biome_noise.frequency = biome_frequency / float(maxi(chunk_width_tiles, 1))


## Biome index of the tile. The first run is always the safe zone (index 0).
func biome_index_at_tile(tile_x: int) -> int:
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


## Biome at a world X pixel position.
func biome_at_world_x(world_x: float, tile_size: int) -> Biome:
	var index := biome_index_at_tile(floori(world_x / float(tile_size)))
	if index < 0:
		return null
	return biomes[index]


## Biome for the center tile of a chunk (used for enemies and counts).
func biome_for_chunk(chunk_x: int) -> Biome:
	var index := biome_index_at_tile(chunk_x * chunk_width_tiles + chunk_width_tiles / 2)
	if index < 0:
		return null
	return biomes[index]


## Start X in pixels of the next biome run to the right of `world_x`.
func next_biome_start_x(world_x: float, tile_size: int) -> float:
	if biomes.is_empty():
		return -1.0
	var tile := maxi(floori(world_x / float(tile_size)), 0)
	_ensure_biome_runs(tile)
	var last: Dictionary = _biome_runs.back()
	_ensure_biome_runs(int(last["start"]) + int(last["length"]))
	for run in _biome_runs:
		var start := int(run["start"]) * tile_size
		if start > world_x + 1.0:
			return float(start)
	return -1.0


## Share (0..1) of the ±`AMBIENT_BLEND_TILES` window around `world_x` whose
## biome uses `ambient`. The ambient VFX chase this so leaves and snow fade
## into each other over ~64 tiles, like the biome tint does.
func ambient_weight_at_world_x(world_x: float, tile_size: int, ambient: String) -> float:
	if biomes.is_empty():
		return 0.0
	var tile_x := floori(world_x / float(tile_size))
	var counts: Dictionary = {}
	for i in range(-AMBIENT_BLEND_TILES, AMBIENT_BLEND_TILES + 1):
		_add_biome_count(counts, tile_x + i)
	var samples := 0
	var matching := 0
	for index in counts:
		var count := int(counts[index])
		samples += count
		if index >= 0 and index < biomes.size() and biomes[index].ambient == ambient:
			matching += count
	if samples <= 0:
		return 0.0
	return float(matching) / float(samples)


## Per-column biome data for a chunk: grass tints, amplitude and frequency arrays.
func chunk_biome_data(chunk_x: int) -> Dictionary:
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


## Applies the biome tint of `tile_x` to the background nodes.
func update_biome_tint(tile_x: int, force: bool, last_tile: int) -> int:
	if forest_tint_nodes.is_empty() and rock_tint_nodes.is_empty() and snow_tint_nodes.is_empty() and base_tint_nodes.is_empty():
		return last_tile
	if not force and tile_x == last_tile:
		return last_tile
	var forest := _biome_color_at_tile(tile_x, "forest")
	var rock := _biome_color_at_tile(tile_x, "rock")
	var snow := _biome_color_at_tile(tile_x, "snow")
	for node in forest_tint_nodes:
		node.modulate = forest
	for node in rock_tint_nodes:
		node.modulate = rock
	for node in snow_tint_nodes:
		node.modulate = snow
	var base := forest.darkened(MOUNTAIN_BASE_DARKENING)
	for node in base_tint_nodes:
		node.color = base
	return tile_x


# --- Private ---

func _ensure_biome_runs(tile_x: int) -> void:
	if _biome_runs.is_empty():
		_biome_runs.append(_make_biome_run(0, -1))
	while tile_x >= int(_biome_runs.back()["start"]) + int(_biome_runs.back()["length"]):
		var previous: Dictionary = _biome_runs.back()
		var start := int(previous["start"]) + int(previous["length"])
		_biome_runs.append(_make_biome_run(start, int(previous["index"])))


func _make_biome_run(start_tile: int, previous_index: int) -> Dictionary:
	var index := 0 if previous_index < 0 else _roll_biome_at(start_tile, previous_index)
	var sector := biome_sector_tiles if biome_sector_tiles > 0 else chunk_width_tiles
	var shortest := maxi(min_biome_tiles, sector)
	var longest := maxi(max_biome_tiles, shortest)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:biome:%d" % [_seed, start_tile])
	var length := shortest + rng.randi_range(0, (longest - shortest) / sector) * sector
	return {"start": start_tile, "index": index, "length": length}


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


func _transition_tiles() -> int:
	return transition_tiles if transition_tiles > 0 else chunk_width_tiles


func _transition_half_tiles() -> int:
	return maxi(_transition_tiles() / 2, 0)


func _biome_counts_at_tile(tile_x: int) -> Dictionary:
	var half := _transition_half_tiles()
	var counts: Dictionary = {}
	for i in range(-half, half + 1):
		_add_biome_count(counts, tile_x + i)
	return counts


func _add_biome_count(counts: Dictionary, tile_x: int) -> void:
	var index := biome_index_at_tile(tile_x)
	if index >= 0:
		counts[index] = int(counts.get(index, 0)) + 1


func _remove_biome_count(counts: Dictionary, tile_x: int) -> void:
	var index := biome_index_at_tile(tile_x)
	if index < 0:
		return
	var remaining := int(counts.get(index, 0)) - 1
	if remaining <= 0:
		counts.erase(index)
	else:
		counts[index] = remaining


func _biome_color_at_tile(tile_x: int, channel: String) -> Color:
	if biomes.is_empty():
		return Color.WHITE
	return _mixed_biome_color(_biome_counts_at_tile(tile_x), channel)


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
			"snow":
				color = biome.snow_color
		total += color * float(counts.get(index, 0))
	return total / float(samples)


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
