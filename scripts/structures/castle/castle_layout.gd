class_name CastleLayout
extends RefCounted
## Pure layout data for one castle hall. No nodes, no TileSet and no painting:
## the same seed and floor always return the same floor blocks, pits, wooden
## platforms and decoration anchors.

const TILE_SIZE := 32
const HALL_WIDTH := 34
const HALL_HEIGHT := 22
const TOP_ROW := 1
const BOTTOM_ROW := 21
const FLOOR_BOTTOM := 20
const WINDOW_COUNT := 8
const WINDOW_STEP := 4


func build(seed: int, floor: int, width: int = HALL_WIDTH) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed ^ (floor * 7919)
	var hall_width := maxi(width, 30)
	var interior := hall_width - 2
	var gap_width := 3
	var left_width := clampi(9 + rng.randi_range(-1, 1), 8, 10)
	var center_width := 6
	var right_width := interior - left_width - center_width - gap_width * 2
	if right_width < 8:
		left_width -= 8 - right_width
		right_width = 8
	var left_x := 1
	var gap_a_x := left_x + left_width
	var center_x := gap_a_x + gap_width
	var gap_b_x := center_x + center_width
	var right_x := gap_b_x + gap_width
	right_width = hall_width - 1 - right_x
	var left_top := 14 + rng.randi_range(-1, 1)
	var center_top := 16 + rng.randi_range(-1, 1)
	var right_top := 13 + rng.randi_range(-1, 1)
	var blocks: Array = [
		_block(left_x, left_top, left_width),
		_block(center_x, center_top, center_width),
		_block(right_x, right_top, right_width),
	]
	var gaps: Array = [
		_gap(gap_a_x, gap_width, left_top, center_top),
		_gap(gap_b_x, gap_width, center_top, right_top),
	]
	var platforms: Array[Rect2i] = [
		Rect2i(left_x + 2, left_top - 4, 6, 1),
		Rect2i(center_x + 1, center_top - 6, 4, 1),
		Rect2i(right_x + 2, right_top - 4, 7, 1),
	]
	var windows: Array[Vector2i] = []
	for i in WINDOW_COUNT:
		windows.append(Vector2i(3 + i * WINDOW_STEP, 3))
	var banners: Array[Vector2i] = [
		Vector2i(hall_width / 2 - 2, 6),
		Vector2i(hall_width / 2 + 1, 6),
	]
	return {
		"seed": seed,
		"floor": floor,
		"width": hall_width,
		"height": HALL_HEIGHT,
		"top_row": TOP_ROW,
		"bottom_row": BOTTOM_ROW,
		"floor_bottom": FLOOR_BOTTOM,
		"blocks": blocks,
		"gaps": gaps,
		"platforms": platforms,
		"windows": windows,
		"banners": banners,
		"spawn_cell": Vector2i(left_x + left_width / 2, left_top),
		"exit_cell": Vector2i(right_x + right_width / 2, right_top),
	}


func _block(x: int, top: int, width: int) -> Dictionary:
	return {
		"rect": Rect2i(x, top, width, FLOOR_BOTTOM - top + 1),
		"bottom": FLOOR_BOTTOM,
	}


func _gap(x: int, width: int, from_row: int, to_row: int) -> Dictionary:
	var lower := mini(maxi(from_row, to_row) + 2, FLOOR_BOTTOM - 1)
	return {
		"x": x,
		"width": width,
		"from_row": from_row,
		"to_row": to_row,
		"lower": lower,
		"step": lower - 1,
	}
