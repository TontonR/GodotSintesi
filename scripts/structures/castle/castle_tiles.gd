class_name CastleTiles
extends RefCounted
## Castle atlas catalog and TileSet factory. The atlas groups are:
## - top rows: windows, banners and the long wooden platform;
## - middle rows: brick borders/corners around floors;
## - bottom rows: the stone body/background.
##
## The atlas has its own dark purple background baked into the border tiles.
## It is kept as-is so the brick edges end against the original color instead of
## an invented cutout/transition.

const TEXTURE := preload("res://assets/map/structures/castle_tiles.png")
const ATLAS_COLUMNS := 8
const TILE_SIZE := 32

const STONE_BODY := 41
const SOLID_FILL := 25

## Hall frame border: the light trim faces the interior, unlike the floor blocks.
## The 27–30 pieces are the inner-corner caps that close the four frame turns.
const FRAME_TOP := 24
const FRAME_BOTTOM := 20
const FRAME_LEFT := 22
const FRAME_RIGHT := 19
const FRAME_TOP_LEFT := 28
const FRAME_TOP_RIGHT := 29
const FRAME_BOTTOM_LEFT := 27
const FRAME_BOTTOM_RIGHT := 30

## Floor-block border: the light trim faces the outside of the block.
const FLOOR_TOP := 20
const FLOOR_BOTTOM := 24
const FLOOR_LEFT := 19
const FLOOR_RIGHT := 22
const FLOOR_TOP_LEFT := 18
const FLOOR_TOP_RIGHT := 21
const FLOOR_BOTTOM_LEFT := 26
const FLOOR_BOTTOM_RIGHT := 23

## Long wooden platform row: left cap, two middle pieces and right cap.
const PLATFORM_LEFT := 11
const PLATFORM_MIDDLE := 12
const PLATFORM_MIDDLE_END := 13
const PLATFORM_RIGHT := 14
const PLATFORM_TILES: Array[int] = [PLATFORM_LEFT, PLATFORM_MIDDLE, PLATFORM_MIDDLE_END, PLATFORM_RIGHT]

const WINDOW_VARIANTS := [[0, 1, 2, 3], [4, 5, 6, 7]]
const BANNER_TILES: Array[int] = [8, 9, 10]


static func atlas_tile(index: int) -> Vector2i:
	return Vector2i(index % ATLAS_COLUMNS, floori(float(index) / ATLAS_COLUMNS))


## Full-square TileSet for the hall frame and the solid floor blocks.
static func build_walls() -> TileSet:
	var tile_set := _new_solid_tileset()
	var source := _new_source(tile_set)
	_add_tiles(source, _unique([
		STONE_BODY,
		SOLID_FILL,
		FRAME_TOP, FRAME_BOTTOM, FRAME_LEFT, FRAME_RIGHT,
		FRAME_TOP_LEFT, FRAME_TOP_RIGHT, FRAME_BOTTOM_LEFT, FRAME_BOTTOM_RIGHT,
		FLOOR_TOP, FLOOR_BOTTOM, FLOOR_LEFT, FLOOR_RIGHT,
		FLOOR_TOP_LEFT, FLOOR_TOP_RIGHT, FLOOR_BOTTOM_LEFT, FLOOR_BOTTOM_RIGHT,
	]))
	return tile_set


## One-way collision for the wooden platforms: only the plank at the top of
## each cell is solid, so the player can pass underneath.
static func build_platforms() -> TileSet:
	var tile_set := _new_solid_tileset()
	var source := _new_source(tile_set)
	for index in PLATFORM_TILES:
		var coords := atlas_tile(index)
		source.create_tile(coords)
		var data := source.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, _thin_polygon())
		data.set_collision_polygon_one_way(0, 0, true)
	return tile_set


## Physics-free copy for the stone backdrop and the decorative window/banner
## pieces.
static func build_plain() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := _new_source(tile_set)
	var indices: Array = [STONE_BODY]
	indices.append_array(WINDOW_VARIANTS[0])
	indices.append_array(WINDOW_VARIANTS[1])
	indices.append_array(BANNER_TILES)
	_add_tiles(source, _unique(indices), false)
	return tile_set


static func _new_solid_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	return tile_set


static func _new_source(tile_set: TileSet) -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	source.texture = TEXTURE
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(source, 0)
	return source


static func _add_tiles(source: TileSetAtlasSource, indices: Array, with_collision: bool = true) -> void:
	for index in indices:
		var coords := atlas_tile(int(index))
		source.create_tile(coords)
		if not with_collision:
			continue
		var data := source.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, _full_polygon())


static func _full_polygon() -> PackedVector2Array:
	var half := TILE_SIZE / 2.0
	return PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half),
	])


static func _thin_polygon() -> PackedVector2Array:
	var half := TILE_SIZE / 2.0
	var bottom := -half + 10.0
	return PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, bottom),
		Vector2(-half, bottom),
	])


static func _unique(indices: Array) -> Array:
	var result: Array = []
	for index in indices:
		if not result.has(index):
			result.append(index)
	return result
