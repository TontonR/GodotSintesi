class_name BlockStructure
extends TileMapLayer
## Type 2 structure (ruins) painted with a TileSet, like the ground layer, so the
## atlas, the tiles and their collision are edited in the TileSet editor instead
## of being drawn by code.
##
## Two layers per ruin, both sharing `WorldStructure.tileset`:
##   source 0 = dark atlas, the brick wall in the background (no physics)
##   source 1 = light atlas, the few ground stones (physics from the TileSet)

## Cell size in px, also the atlas grid step.
var block_size: int = 16
## Top-left corner of every block, in chunk-local px.
var cells: Array[Vector2] = []
## Optional atlas index per cell; -1 or missing = pick from the pools below.
var cell_tiles: Array[int] = []
## Atlas source to paint from (0 dark wall, 1 light collidable stones).
var source_id: int = 0

## The wall is bricks only; the stone blocks (8-13) are the front layer.
const WALL_TILES := [6, 6, 6, 7, 7]
const TOP_TILES := [14, 15]
## Ground stones (front): big, dark big and the two long ones.
const STONE_TILES := [8, 8, 11, 9, 12]
## Beams that fill the niches under the wall.
const SUPPORT_TILES := [8, 9]
const ATLAS_COLUMNS := 8

var _filled := {}


func _ready() -> void:
	_ensure_filled()
	for i in cells.size():
		var index := _tile_index(i)
		set_cell(
			Vector2i(floori(cells[i].x / block_size), floori(cells[i].y / block_size)),
			source_id,
			Vector2i(index % ATLAS_COLUMNS, floori(index / float(ATLAS_COLUMNS)))
		)


func _ensure_filled() -> void:
	if not _filled.is_empty():
		return
	for cell in cells:
		_filled[Vector2i(floori(cell.x / block_size), floori(cell.y / block_size))] = true


func _tile_index(i: int) -> int:
	if i < cell_tiles.size() and cell_tiles[i] >= 0:
		return cell_tiles[i]
	var tx := floori(cells[i].x / block_size)
	var ty := floori(cells[i].y / block_size)
	var exposed := not _filled.has(Vector2i(tx, ty - 1))
	var pool: Array = TOP_TILES if exposed else WALL_TILES
	# Hash of the cell instead of an RNG: a reload picks the same tiles.
	return pool[absi(tx * 31 + ty * 17) % pool.size()]
