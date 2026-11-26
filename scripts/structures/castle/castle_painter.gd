class_name CastlePainter
extends RefCounted
## Paints a CastleLayout on the four TileMapLayers.
## Solid terrain (outer frame + all floor blocks) is built as a pure boolean
## grid first, then autotiled by inspecting 4 cardinal + 4 diagonal neighbors
## so every border, outer corner and inner corner merges cleanly without seams.

const Tiles := preload("res://scripts/structures/castle/castle_tiles.gd")


static func paint(
	back: TileMapLayer,
	decor: TileMapLayer,
	walls: TileMapLayer,
	platforms: TileMapLayer,
	layout: Dictionary
) -> void:
	_paint_backdrop(back, layout)
	_paint_solid_grid(walls, layout)
	for platform in layout["platforms"]:
		_paint_wood_platform(platforms, platform)
	if decor != null:
		_paint_windows(decor, layout)
		_paint_banners(decor, layout)


## Stone wall behind the interior (from ceiling + 1 down to floor_bottom).
static func _paint_backdrop(back: TileMapLayer, layout: Dictionary) -> void:
	var width: int = layout["width"]
	var top: int = layout["top_row"]
	var bottom: int = layout["bottom_row"]
	for y in range(top + 1, bottom):
		for x in range(1, width - 1):
			back.set_cell(Vector2i(x, y), 0, Tiles.atlas_tile(Tiles.STONE_BODY))


## Builds a boolean solid grid (frame + floor blocks) and resolves every tile
## from its 8 neighbors so walls, steps and corners fuse seamlessly.
static func _paint_solid_grid(walls: TileMapLayer, layout: Dictionary) -> void:
	var width: int = layout["width"]
	var top_row: int = layout["top_row"]
	var bottom_row: int = layout["bottom_row"]

	var solid := {}
	# Outer frame (ceiling, floor base, left & right walls)
	for x in width:
		solid[Vector2i(x, top_row)] = true
		solid[Vector2i(x, bottom_row)] = true
	for y in range(top_row, bottom_row + 1):
		solid[Vector2i(0, y)] = true
		solid[Vector2i(width - 1, y)] = true

	# Floor blocks
	for block in layout["blocks"]:
		var rect: Rect2i = block["rect"]
		for y in range(rect.position.y, bottom_row + 1):
			for x in range(rect.position.x, rect.end.x):
				solid[Vector2i(x, y)] = true

	# Autotile every solid cell based on air neighbors.
	for cell in solid.keys():
		var x: int = cell.x
		var y: int = cell.y
		var n := _is_solid(solid, x, y - 1, width, top_row, bottom_row)
		var s := _is_solid(solid, x, y + 1, width, top_row, bottom_row)
		var w := _is_solid(solid, x - 1, y, width, top_row, bottom_row)
		var e := _is_solid(solid, x + 1, y, width, top_row, bottom_row)

		var tile := Tiles.SOLID_FILL
		if not n and not w:
			tile = Tiles.FLOOR_TOP_LEFT
		elif not n and not e:
			tile = Tiles.FLOOR_TOP_RIGHT
		elif not s and not w:
			tile = Tiles.FLOOR_BOTTOM_LEFT
		elif not s and not e:
			tile = Tiles.FLOOR_BOTTOM_RIGHT
		elif not n:
			tile = Tiles.FLOOR_TOP
		elif not s:
			tile = Tiles.FLOOR_BOTTOM
		elif not w:
			tile = Tiles.FLOOR_LEFT
		elif not e:
			tile = Tiles.FLOOR_RIGHT
		else:
			var nw := _is_solid(solid, x - 1, y - 1, width, top_row, bottom_row)
			var ne := _is_solid(solid, x + 1, y - 1, width, top_row, bottom_row)
			var sw := _is_solid(solid, x - 1, y + 1, width, top_row, bottom_row)
			var se := _is_solid(solid, x + 1, y + 1, width, top_row, bottom_row)
			if not se:
				tile = Tiles.FRAME_TOP_LEFT
			elif not sw:
				tile = Tiles.FRAME_TOP_RIGHT
			elif not ne:
				tile = Tiles.FRAME_BOTTOM_LEFT
			elif not nw:
				tile = Tiles.FRAME_BOTTOM_RIGHT

		walls.set_cell(cell, 0, Tiles.atlas_tile(tile))


## Out-of-bounds is treated as solid so the outer edge of the hall stays dark.
static func _is_solid(
	solid: Dictionary,
	x: int,
	y: int,
	width: int,
	top_row: int,
	bottom_row: int
) -> bool:
	if x < 0 or x >= width or y < top_row or y > bottom_row:
		return true
	return solid.has(Vector2i(x, y))


## Wooden strip from the atlas: left cap, repeated middle and right cap.
static func _paint_wood_platform(platforms: TileMapLayer, rect: Rect2i) -> void:
	var width := rect.size.x
	for i in width:
		var index := Tiles.PLATFORM_MIDDLE
		if i == 0:
			index = Tiles.PLATFORM_LEFT
		elif i == width - 1:
			index = Tiles.PLATFORM_RIGHT
		elif i == width - 2:
			index = Tiles.PLATFORM_MIDDLE_END
		platforms.set_cell(Vector2i(rect.position.x + i, rect.position.y), 0, Tiles.atlas_tile(index))


static func _paint_windows(decor: TileMapLayer, layout: Dictionary) -> void:
	var windows: Array = layout["windows"]
	for i in windows.size():
		var cell: Vector2i = windows[i]
		var window: Array = Tiles.WINDOW_VARIANTS[i % Tiles.WINDOW_VARIANTS.size()]
		for row in 2:
			decor.set_cell(
				Vector2i(cell.x, cell.y + row), 0, Tiles.atlas_tile(int(window[row * 2]))
			)
			decor.set_cell(
				Vector2i(cell.x + 1, cell.y + row), 0, Tiles.atlas_tile(int(window[row * 2 + 1]))
			)


static func _paint_banners(decor: TileMapLayer, layout: Dictionary) -> void:
	var banners: Array = layout["banners"]
	for cell in banners:
		for row in Tiles.BANNER_TILES.size():
			decor.set_cell(
				Vector2i(cell.x, cell.y + row), 0, Tiles.atlas_tile(Tiles.BANNER_TILES[row])
			)
