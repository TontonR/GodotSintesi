class_name CastleLayout
extends RefCounted
## Pure layout data for one castle hall. No nodes, no TileSet and no painting:
## the same seed and floor always return the same continuous stepped stone
## floor, minimal climbable wooden platforms and decoration anchors, verified
## reachable from spawn to exit within the player's jump limits.

const TILE_SIZE := 32
const HALL_WIDTH := 64
const HALL_HEIGHT := 22
const TOP_ROW := 6
const BOTTOM_ROW := 21
const FLOOR_BOTTOM := 20
const MIN_BLOCK_TOP := 11
const MAX_BLOCK_TOP := 17
const WINDOW_STEP := 5
## Fixed column of the entry door, in every floor and every seed (T-0102).
const ENTRY_COLUMN := 4
## Tiles from the right frame to the exit door; also fixed, same reason.
const EXIT_MARGIN := 5


func build(seed: int, floor: int, width: int = HALL_WIDTH) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed ^ (floor * 7919)
	var hall_width := maxi(width, 40)
	var interior_end := hall_width - 2

	var blocks: Array = []
	var platforms: Array[Rect2i] = []

	var cursor_x := 1
	var prev_top := rng.randi_range(15, 17)
	var start_width := rng.randi_range(6, 8)
	blocks.append(_block(cursor_x, prev_top, start_width))
	var spawn_cell := Vector2i(cursor_x + start_width / 2, prev_top)
	cursor_x += start_width

	# Continuous stepped terrain: alternates 1-tile stone steps, gentle descents
	# and taller rises (2..3 tiles up) that require minimal wooden platforms.
	var last_used_wood := false
	while cursor_x < interior_end - 8:
		var next_top := prev_top
		var roll := rng.randf()
		if not last_used_wood and prev_top > MIN_BLOCK_TOP + 1 and roll < 0.45:
			# Elevated wall climb (2..3 tiles up) using wooden platforms.
			var rise := rng.randi_range(2, mini(3, prev_top - MIN_BLOCK_TOP))
			next_top = prev_top - rise
			for step_i in range(1, rise):
				var step_y := prev_top - step_i
				var step_w := 2
				var step_x := maxi(1, cursor_x - step_w - (rise - 1 - step_i))
				platforms.append(Rect2i(step_x, step_y, step_w, 1))
			last_used_wood = true
		else:
			# Stone step up (+1) or gentle descent (-1 or -2).
			var delta := rng.randi_range(-1, 2)
			if delta == 0:
				delta = -1 if prev_top > MIN_BLOCK_TOP + 2 else 1
			next_top = clampi(prev_top + delta, MIN_BLOCK_TOP, MAX_BLOCK_TOP)
			if next_top == prev_top:
				next_top = clampi(prev_top + (-1 if prev_top > MIN_BLOCK_TOP else 1), MIN_BLOCK_TOP, MAX_BLOCK_TOP)
			last_used_wood = false

		var remaining := interior_end - cursor_x + 1
		var block_width := mini(rng.randi_range(5, 9), remaining)
		if remaining - block_width < 6:
			block_width = remaining
		blocks.append(_block(cursor_x, next_top, block_width))

		prev_top = next_top
		cursor_x += block_width

	var exit_block: Dictionary = blocks[blocks.size() - 1]
	var exit_rect: Rect2i = exit_block["rect"]
	var exit_cell := Vector2i(exit_rect.position.x + exit_rect.size.x / 2, exit_rect.position.y)

	# Doors on the same columns on every floor (T-0102): the entry and the stairs
	# always share their X, so the castle stacks vertically instead of drifting.
	spawn_cell.x = ENTRY_COLUMN
	spawn_cell.y = _top_at(blocks, spawn_cell.x)
	exit_cell.x = hall_width - EXIT_MARGIN
	exit_cell.y = _top_at(blocks, exit_cell.x)

	var windows: Array[Vector2i] = []
	var wx := 3
	while wx <= hall_width - 5:
		windows.append(Vector2i(wx, TOP_ROW + 2))
		wx += WINDOW_STEP

	var banners: Array[Vector2i] = []
	var bx := 11
	while bx <= hall_width - 8:
		banners.append(Vector2i(bx, TOP_ROW + 2))
		bx += 15

	var layout := {
		"seed": seed,
		"floor": floor,
		"width": hall_width,
		"height": HALL_HEIGHT,
		"top_row": TOP_ROW,
		"bottom_row": BOTTOM_ROW,
		"floor_bottom": FLOOR_BOTTOM,
		"blocks": blocks,
		"gaps": [],
		"platforms": platforms,
		"windows": windows,
		"banners": banners,
		"spawn_cell": spawn_cell,
		"exit_cell": exit_cell,
	}

	_ensure_reachable(layout)
	return layout


## Ground row of the block covering `tile_x` (the floor is continuous, so there
## is always one).
func _top_at(blocks: Array, tile_x: int) -> int:
	for block in blocks:
		var rect: Rect2i = block["rect"]
		if tile_x >= rect.position.x and tile_x < rect.end.x:
			return rect.position.y
	return MAX_BLOCK_TOP


func _block(x: int, top: int, width: int) -> Dictionary:
	return {
		"rect": Rect2i(x, top, width, FLOOR_BOTTOM - top + 1),
		"bottom": FLOOR_BOTTOM,
	}


## Verifies via BFS that `exit_cell` is reachable from `spawn_cell` within
## the player's jump limits (1 tile up, <= 2 tiles across).
func _ensure_reachable(layout: Dictionary) -> void:
	var platforms: Array[Rect2i] = layout["platforms"]
	var blocks: Array = layout["blocks"]
	var spawn: Vector2i = layout["spawn_cell"]
	var exit_cell: Vector2i = layout["exit_cell"]

	for _attempt in 8:
		var standable := _collect_standable(layout)
		var reachable := _bfs_reachable(standable, spawn, layout)
		if reachable.has(exit_cell):
			return
		# Fallback: add missing 1-tile step before any block that steps up > 1.
		var added := false
		for i in range(1, blocks.size()):
			var prev_r: Rect2i = blocks[i - 1]["rect"]
			var cur_r: Rect2i = blocks[i]["rect"]
			var rise := prev_r.position.y - cur_r.position.y
			if rise > 1:
				for step_i in range(1, rise):
					var step := Rect2i(maxi(1, cur_r.position.x - 2 - (rise - 1 - step_i)), prev_r.position.y - step_i, 2, 1)
					if not platforms.has(step):
						platforms.append(step)
						added = true
		if not added:
			return


func _collect_standable(layout: Dictionary) -> Dictionary:
	var standable := {}
	for block in layout["blocks"]:
		var rect: Rect2i = block["rect"]
		for x in range(rect.position.x, rect.end.x):
			standable[Vector2i(x, rect.position.y)] = true
	for plat in layout["platforms"]:
		for x in range(plat.position.x, plat.end.x):
			standable[Vector2i(x, plat.position.y)] = true
	return standable


func _bfs_reachable(standable: Dictionary, start: Vector2i, layout: Dictionary) -> Dictionary:
	var visited := {}
	if not standable.has(start):
		return visited
	var solid := {}
	for block in layout["blocks"]:
		var rect: Rect2i = block["rect"]
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				solid[Vector2i(x, y)] = true

	var queue: Array[Vector2i] = [start]
	visited[start] = true
	var head := 0
	while head < queue.size():
		var cur := queue[head]
		head += 1
		for dx in range(-2, 3):
			var nx := cur.x + dx
			if nx < 1 or nx >= int(layout["width"]) - 1:
				continue
			for ny in range(cur.y - 1, FLOOR_BOTTOM + 1):
				var nxt := Vector2i(nx, ny)
				if visited.has(nxt) or not standable.has(nxt):
					continue
				if solid.has(Vector2i(nx, ny - 1)):
					continue
				visited[nxt] = true
				queue.append(nxt)
	return visited
