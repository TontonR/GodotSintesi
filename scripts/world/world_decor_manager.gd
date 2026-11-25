class_name WorldDecorManager
extends RefCounted
## Handles decor selection, foliage pixel-tinting and dead tree conversion
## for WorldGenerator. Stateless except for the texture tint cache.

## Parallel arrays set by WorldGenerator.
var decor_names: Array[String] = []
var decor_textures: Array[Texture2D] = []
var decor_tinted: Array[bool] = []
var decor_scales: Array[float] = []
var decor_z_index: Array[int] = []
var decor_sways: Array[bool] = []
var decor_weights: Array[int] = []

## Reference set by WorldGenerator after init.
var biome_manager: WorldBiomeManager

## Texture/TileSet tint cache: keyed by source path + tint html + thresholds.
var _tint_cache: Dictionary = {}
## Name → index lookup built lazily.
var _decor_lookup: Dictionary = {}


## Weighted random decor kind index for the biome; -1 when nothing to spawn.
func pick_decor_kind(biome: Biome, rng: RandomNumberGenerator) -> int:
	if biome and not biome.decor_kinds.is_empty():
		return _pick_decor_from(biome.decor_kinds, biome.decor_weights, rng)
	return _pick_decor_from(decor_names, decor_weights, rng)


## Position of a decor name in the generator arrays; -1 for unknown.
func index_of(kind_name: String) -> int:
	if _decor_lookup.is_empty():
		for i in decor_names.size():
			if i < decor_textures.size():
				_decor_lookup[decor_names[i]] = i
	return int(_decor_lookup.get(kind_name, -1))


## Draw layer of a kind: 0 rocks (back), 1 trees, 2 bushes (front).
func draw_layer(kind: int) -> int:
	if kind < 0 or kind >= decor_names.size():
		return 2
	var kind_name := decor_names[kind]
	if kind_name.begins_with("rock"):
		return 0
	if kind_name.begins_with("tree"):
		return 1
	return 2


func draws_before(a: Dictionary, b: Dictionary) -> bool:
	return draw_layer(int(a["kind"])) > draw_layer(int(b["kind"]))


func scale_of(kind: int) -> float:
	return decor_scales[kind] if kind < decor_scales.size() else 1.0


func z_index_of(kind: int) -> int:
	return decor_z_index[kind] if kind < decor_z_index.size() else 0


func sways_kind(kind: int) -> bool:
	return decor_sways[kind] if kind < decor_sways.size() else false


## Random tint at `tile_x` from the biome's `decor_colors`; white if none.
func tint_at(tile_x: int, rng: RandomNumberGenerator) -> Color:
	var index := biome_manager.biome_index_at_tile(tile_x)
	if index < 0:
		return Color.WHITE
	var biome := biome_manager.biomes[index]
	if biome.decor_colors.is_empty():
		return Color.WHITE
	var total := 0.0
	for i in biome.decor_colors.size():
		total += _color_weight(biome, i)
	if total <= 0.0:
		return Color.WHITE
	var roll := rng.randf() * total
	for i in biome.decor_colors.size():
		roll -= _color_weight(biome, i)
		if roll <= 0.0:
			return biome.decor_colors[i]
	return biome.decor_colors.back()


## Texture for a kind; foliage kinds get a cached tinted copy.
func texture_for(kind: int, tint: Color) -> Texture2D:
	var source: Texture2D = decor_textures[kind]
	if source == null or kind >= decor_tinted.size() or not decor_tinted[kind]:
		return source
	return _tinted_texture(source, tint)


## Cached copy of the structure TileSet with its moss pixels recolored.
func structure_tileset(tile_set: TileSet, tint: Color) -> TileSet:
	if tile_set == null or tint == Color.WHITE or tile_set.resource_path.is_empty():
		return tile_set
	var key := "tileset|%s|%s" % [tile_set.resource_path, tint.to_html(false)]
	var cached: TileSet = _tint_cache.get(key)
	if cached:
		return cached
	var copy := tile_set.duplicate(true) as TileSet
	for i in copy.get_source_count():
		var source := copy.get_source(copy.get_source_id(i)) as TileSetAtlasSource
		if source != null:
			source.texture = _tinted_texture(source.texture, tint, 24, 12)
	_tint_cache[key] = copy
	return copy


## Turns exactly `ratio` of the trees in `decor` into dead trees (in-place).
func apply_dead_tree_ratio(biome: Biome, decor: Array[Dictionary], rng: RandomNumberGenerator) -> void:
	if biome == null or biome.decor_dead_tree_ratio <= 0.0 or decor.is_empty():
		return
	var tree_kind := index_of("tree")
	var dead_kind := index_of("tree_dead")
	if tree_kind < 0 or dead_kind < 0:
		return
	var candidates: Array[int] = []
	for i in decor.size():
		if int(decor[i]["kind"]) == tree_kind:
			candidates.append(i)
	if candidates.is_empty():
		return
	var dead_count := roundi(float(candidates.size()) * clampf(biome.decor_dead_tree_ratio, 0.0, 1.0))
	for i in range(candidates.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = swap
	for i in range(dead_count):
		decor[candidates[i]]["kind"] = dead_kind
		decor[candidates[i]]["tint"] = Color.WHITE


# --- Private ---

func _pick_decor_from(names: Array[String], weights: Array[int], rng: RandomNumberGenerator) -> int:
	var total := 0
	for i in names.size():
		total += _kind_weight(weights, i)
	if total <= 0:
		return -1
	var roll := rng.randi_range(0, total - 1)
	for i in names.size():
		roll -= _kind_weight(weights, i)
		if roll < 0:
			return index_of(names[i])
	return -1


func _kind_weight(weights: Array[int], index: int) -> int:
	return maxi(weights[index], 0) if index < weights.size() else 1


func _color_weight(biome: Biome, index: int) -> float:
	if index < biome.decor_color_weights.size():
		return maxf(biome.decor_color_weights[index], 0.0)
	return 1.0


func _tinted_texture(
		source: Texture2D,
		tint: Color,
		green_over_red: int = 0,
		green_over_blue: int = 0
) -> Texture2D:
	if source == null or tint == Color.WHITE or source.resource_path.is_empty():
		return source
	var key := "%s|%s|%d|%d" % [
		source.resource_path, tint.to_html(false), green_over_red, green_over_blue
	]
	var cached: Texture2D = _tint_cache.get(key)
	if cached:
		return cached
	var image := source.get_image()
	if image == null:
		return source
	var tinted := _tint_foliage(image, tint, green_over_red, green_over_blue)
	if tinted == null:
		return source
	var texture := ImageTexture.create_from_image(tinted)
	_tint_cache[key] = texture
	return texture


func _tint_foliage(
		image: Image,
		tint: Color,
		green_over_red: int = 0,
		green_over_blue: int = 0
) -> Image:
	var out := image.duplicate() as Image
	if out.is_compressed():
		out.decompress()
	out.convert(Image.FORMAT_RGBA8)
	for y in out.get_height():
		for x in out.get_width():
			var pixel := out.get_pixel(x, y)
			if pixel.a <= 0.0:
				continue
			if (pixel.g - pixel.r) * 255.0 <= float(green_over_red):
				continue
			if (pixel.g - pixel.b) * 255.0 <= float(green_over_blue):
				continue
			var shade := maxf(pixel.r, maxf(pixel.g, pixel.b))
			out.set_pixel(x, y, Color(tint.r * shade, tint.g * shade, tint.b * shade, pixel.a))
	return out
