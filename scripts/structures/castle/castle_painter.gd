class_name CastlePainter
extends RefCounted
## Paints a CastleLayout on the four TileMapLayers. Borders use the atlas corner
## pieces so an edge turns into a side instead of ending in a disconnected tile.
## The atlas' own dark background is left intact; the dungeon backdrop uses the
## same purple, so brick edges end against it without a cutout or color fade.

const Tiles := preload("res://scripts/structures/castle/castle_tiles.gd")


static func paint(
	back: TileMapLayer,
	decor: TileMapLayer,
	walls: TileMapLayer,
	platforms: TileMapLayer,
	layout: Dictionary
) -> void:
	_paint_backdrop(back, layout)
	_paint_frame(walls, layout)
	for block in layout["blocks"]:
		_paint_block(walls, block)
	for gap in layout["gaps"]:
		_cut_void(back, gap, layout)
		_paint_recovery(platforms, gap)
	for platform in layout["platforms"]:
		_paint_wood_platform(platforms, platform)
	if decor != null:
		_paint_windows(decor, layout)
		_paint_banners(decor, layout)


## Stone wall behind the whole interior. Outside the frame there are no cells:
## the dark CanvasLayer behind the dungeon shows through as the outside void.
static func _paint_backdrop(back: TileMapLayer, layout: Dictionary) -> void:
	var width: int = layout["width"]
	var top: int = layout["top_row"]
	var bottom: int = layout["bottom_row"]
	for y in range(top + 1, bottom):
		for x in range(1, width - 1):
			back.set_cell(Vector2i(x, y), 0, Tiles.atlas_tile(Tiles.STONE_BODY))


## Outer frame with the light trim facing the interior. Its four corners use the
## inner-corner caps 27–30 so the trim turns without running past the frame.
static func _paint_frame(walls: TileMapLayer, layout: Dictionary) -> void:
	var width: int = layout["width"]
	var top: int = layout["top_row"]
	var bottom: int = layout["bottom_row"]
	for x in range(1, width - 1):
		walls.set_cell(Vector2i(x, top), 0, Tiles.atlas_tile(Tiles.FRAME_TOP))
		walls.set_cell(Vector2i(x, bottom), 0, Tiles.atlas_tile(Tiles.FRAME_BOTTOM))
	for y in range(top + 1, bottom):
		walls.set_cell(Vector2i(0, y), 0, Tiles.atlas_tile(Tiles.FRAME_LEFT))
		walls.set_cell(Vector2i(width - 1, y), 0, Tiles.atlas_tile(Tiles.FRAME_RIGHT))
	walls.set_cell(Vector2i(0, top), 0, Tiles.atlas_tile(Tiles.FRAME_TOP_LEFT))
	walls.set_cell(Vector2i(width - 1, top), 0, Tiles.atlas_tile(Tiles.FRAME_TOP_RIGHT))
	walls.set_cell(Vector2i(0, bottom), 0, Tiles.atlas_tile(Tiles.FRAME_BOTTOM_LEFT))
	walls.set_cell(Vector2i(width - 1, bottom), 0, Tiles.atlas_tile(Tiles.FRAME_BOTTOM_RIGHT))


## Solid floor block with a complete brick border on all four sides. The stone
## fill is painted first, but the original border art keeps its own dark inner
## edge, so the inside of the brick reads like the map border.
static func _paint_block(walls: TileMapLayer, block: Dictionary) -> void:
	var rect: Rect2i = block["rect"]
	var x0 := rect.position.x
	var x1 := rect.end.x - 1
	var top := rect.position.y
	var bottom := rect.end.y - 1
	for y in range(top, bottom + 1):
		for x in range(x0, x1 + 1):
			walls.set_cell(Vector2i(x, y), 0, Tiles.atlas_tile(Tiles.STONE_BODY))
	for x in range(x0 + 1, x1):
		walls.set_cell(Vector2i(x, top), 0, Tiles.atlas_tile(Tiles.FLOOR_TOP))
		walls.set_cell(Vector2i(x, bottom), 0, Tiles.atlas_tile(Tiles.FLOOR_BOTTOM))
	for y in range(top + 1, bottom):
		walls.set_cell(Vector2i(x0, y), 0, Tiles.atlas_tile(Tiles.FLOOR_LEFT))
		walls.set_cell(Vector2i(x1, y), 0, Tiles.atlas_tile(Tiles.FLOOR_RIGHT))
	walls.set_cell(Vector2i(x0, top), 0, Tiles.atlas_tile(Tiles.FLOOR_TOP_LEFT))
	walls.set_cell(Vector2i(x1, top), 0, Tiles.atlas_tile(Tiles.FLOOR_TOP_RIGHT))
	walls.set_cell(Vector2i(x0, bottom), 0, Tiles.atlas_tile(Tiles.FLOOR_BOTTOM_LEFT))
	walls.set_cell(Vector2i(x1, bottom), 0, Tiles.atlas_tile(Tiles.FLOOR_BOTTOM_RIGHT))


## Reopens the stone backdrop as a pit. The dark background layer shows through
## the removed cells instead of a purple tile.
static func _cut_void(back: TileMapLayer, gap: Dictionary, layout: Dictionary) -> void:
	var x: int = gap["x"]
	var width: int = gap["width"]
	var top: int = mini(int(gap["from_row"]), int(gap["to_row"])) + 1
	var bottom: int = layout["floor_bottom"]
	for y in range(top, bottom + 1):
		for column in width:
			back.erase_cell(Vector2i(x + column, y))


## Wooden platform and one step inside each pit, so a missed jump can climb back
## without turning the pit into a staircase.
static func _paint_recovery(platforms: TileMapLayer, gap: Dictionary) -> void:
	_paint_wood_platform(platforms, Rect2i(gap["x"], gap["lower"], gap["width"], 1))
	_paint_wood_platform(platforms, Rect2i(gap["x"], gap["step"], 1, 1))


## Wooden strip from the atlas: left cap, repeated middle and right cap. The
## thin one-way collision is defined by CastleTiles.build_platforms().
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
