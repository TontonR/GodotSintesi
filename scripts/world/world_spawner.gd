class_name WorldSpawner
extends RefCounted
## Instantiates and places all chunk entities: decor props, structures,
## breakable crates, enemies and coins. Keeps track of defeated/collected/broken
## ids so they are not re-spawned after a chunk reload.

const TILE_SIZE := 16

## Set by WorldGenerator after init.
var enemy_scenes: Array[PackedScene] = []
var enemy_counts_per_chunk: Array[int] = []
var coin_scene: PackedScene
var crate_scene: PackedScene
var structures: Array[WorldStructure] = []
var chunk_width_tiles: int = 256

## Spawn tuning.
var enemy_spawn_margin_tiles: int = 2
var enemy_safe_gap_tiles: int = 20
var enemy_ramp_first_chunks: int = 2
var enemy_ramp_first_multiplier: float = 0.5
var enemy_ramp_per_chunk: float = 0.2
var enemy_ramp_max_multiplier: float = 1.8
var coins_per_chunk: int = 2
var coin_spawn_height: float = 40.0
var crates_per_ruin: int = 2
var structure_min_gap_tiles: int = 3

## Decor config forwarded for the spawn loop.
var decor_sway_radius_px: float = 48.0

## References set by WorldGenerator.
var decor_manager: WorldDecorManager

## Persistent kill/collect/break ids.
var _defeated_spawns: Dictionary = {}
var _collected_spawns: Dictionary = {}
var _broken_blocks: Dictionary = {}

## Structure lookup by display_name.
var _structure_lookup: Dictionary = {}


func save_state() -> Dictionary:
	return {
		"defeated": PackedStringArray(_defeated_spawns.keys()),
		"collected": PackedStringArray(_collected_spawns.keys()),
		"broken": PackedStringArray(_broken_blocks.keys()),
	}


func restore_state(data: Dictionary) -> void:
	for id in data.get("defeated", []):
		_defeated_spawns[String(id)] = true
	for id in data.get("collected", []):
		_collected_spawns[String(id)] = true
	for id in data.get("broken", []):
		_broken_blocks[String(id)] = true


## Rolls enemy, coin and structure data for one chunk (pure data, no nodes).
func roll_chunk_data(
		coord: Vector2i,
		biome: Biome,
		heights: PackedInt32Array,
		rng: RandomNumberGenerator
) -> Dictionary:
	var min_x := enemy_spawn_margin_tiles
	var max_x := chunk_width_tiles - enemy_spawn_margin_tiles - 1
	var enemy_min_x := min_x
	if coord.x == 0:
		enemy_min_x = maxi(enemy_min_x, enemy_safe_gap_tiles)

	var scenes: Array[PackedScene] = enemy_scenes
	var counts: Array[int] = enemy_counts_per_chunk
	if biome and not biome.enemy_scenes.is_empty():
		scenes = biome.enemy_scenes
		counts = biome.enemy_counts

	var spawn_scenes: Array[PackedScene] = []
	var count_multiplier := _enemy_count_multiplier(coord.x)
	for idx in range(scenes.size()):
		var count := 0
		if idx < counts.size():
			count = maxi(floori(float(counts[idx]) * count_multiplier), 0)
		for i in range(count):
			spawn_scenes.append(scenes[idx])

	var enemies: Array[Dictionary] = []
	var total := spawn_scenes.size()
	var slot_width := float(maxi(max_x - enemy_min_x + 1, 1)) / float(maxi(total, 1))
	var jitter := maxi(floori(slot_width * 0.25), 0)
	for k in range(total):
		var spawn_id := "e:%d:%d:%d" % [coord.x, coord.y, k]
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
		var local_x := rng.randi_range(min_x, max_x)
		if _collected_spawns.has(spawn_id):
			continue
		coins.append({
			"id": spawn_id,
			"position": Vector2(local_x * TILE_SIZE, heights[local_x] * TILE_SIZE - coin_spawn_height)
		})

	return {"enemies": enemies, "coins": coins}


## Rolls structure data for one chunk (depends on enemy list from roll_chunk_data).
func roll_structures(
		coord: Vector2i,
		biome: Biome,
		heights: PackedInt32Array,
		enemies: Array[Dictionary],
		rng: RandomNumberGenerator
) -> Array[Dictionary]:
	var placed: Array[Dictionary] = []
	if biome == null or biome.structure_kinds.is_empty() or structures.is_empty():
		return placed
	var last_x := chunk_width_tiles - 1
	for i in range(biome.structure_kinds.size()):
		var chance := biome.structure_chances[i] if i < biome.structure_chances.size() else 0.0
		if rng.randf() >= chance:
			continue
		var index := _structure_index_of(biome.structure_kinds[i])
		if index < 0:
			continue
		var structure := structures[index]
		if not _structure_allowed(structure, biome, coord.x * chunk_width_tiles):
			continue
		var width := structure.block_width()
		if not structure.pattern.is_empty() and structure.max_length_tiles > 0:
			width = rng.randi_range(
				maxi(structure.min_length_tiles, 1),
				maxi(structure.max_length_tiles, 1)
			)
		var half := maxi(floori(float(width) * 0.5), 0)
		var margin := maxi(structure.margin_tiles, half)
		if margin > last_x - margin:
			continue
		var local_x := -1
		for _attempt in range(8):
			var candidate := rng.randi_range(margin, last_x - margin)
			var enemy_half := 1 if not structure.pattern.is_empty() else half + 1
			if _structure_x_free(candidate, half, enemy_half, placed, enemies):
				local_x = candidate
				break
		if local_x < 0:
			continue
		var bottom := heights[local_x]
		for dx in range(-half, half + 1):
			bottom = maxi(bottom, heights[clampi(local_x + dx, 0, last_x)])
		var entry := {
			"id": "s:%d:%d:%d" % [coord.x, coord.y, i],
			"structure": structure,
			"x": local_x,
			"y": bottom,
			"half": half,
			"cells": [],
			"front": [],
			"front_tiles": [],
			"flatten": structure.flatten_ground,
			"tint": decor_manager.tint_at(coord.x * chunk_width_tiles + local_x, rng)
		}
		if not structure.textures.is_empty():
			var global_tile := coord.x * chunk_width_tiles + local_x
			entry["texture"] = structure.textures[absi(global_tile * 2654435761) % structure.textures.size()]
		if not structure.pattern.is_empty():
			var built := _blocks_cells(structure, local_x - half, width, heights, rng)
			entry["cells"] = built["cells"]
			entry["front"] = built["front"]
			entry["front_tiles"] = built["front_tiles"]
			entry["crates"] = _crate_tiles(coord, local_x - half, width, built["front"], enemies, rng)
		placed.append(entry)
	return placed


## Instantiates all entities of a chunk into it.
func spawn_chunk_entities(chunk: WorldChunk, data: Dictionary) -> void:
	# Decor
	var decor: Array = data.get("decor", [])
	for i in range(decor.size()):
		var kind: int = decor[i]["kind"]
		if kind < 0 or kind >= decor_manager.decor_textures.size():
			continue
		var tint: Color = decor[i].get("tint", Color.WHITE)
		var texture: Texture2D = decor_manager.texture_for(kind, tint)
		if texture == null:
			continue
		var tile_x: int = decor[i]["x"]
		var sprite := DecorProp.new()
		sprite.name = "Decor_%d" % i
		sprite.texture = texture
		sprite.centered = false
		sprite.offset = Vector2(-texture.get_width() * 0.5, -texture.get_height())
		sprite.scale = Vector2.ONE * decor_manager.scale_of(kind)
		sprite.z_index = decor_manager.z_index_of(kind)
		sprite.modulate = Color.WHITE
		sprite.tint_color = tint
		sprite.sways = decor_manager.sways_kind(kind)
		sprite.sway_radius_px = decor_sway_radius_px
		sprite.position = Vector2(
			tile_x * TILE_SIZE + TILE_SIZE * 0.5,
			data["heights"][tile_x] * TILE_SIZE
		)
		chunk.add_child(sprite)
		chunk.move_child(sprite, 0)

	# Structures
	var structures_here: Array = data.get("structures", [])
	for i in range(structures_here.size()):
		var entry: Dictionary = structures_here[i]
		var structure: WorldStructure = entry["structure"]
		var node: Node2D
		if structure.scene != null:
			node = structure.scene.instantiate() as Node2D
		elif not structure.pattern.is_empty():
			var tint: Color = entry["tint"]
			var tile_set := decor_manager.structure_tileset(structure.tileset, tint)
			var blocks := BlockStructure.new()
			blocks.tile_set = tile_set
			blocks.source_id = 0
			for cell in entry["cells"]:
				blocks.cells.append(cell)
			node = blocks
			var front_cells: Array = entry["front"]
			var front_tiles: Array = entry["front_tiles"]
			if not front_cells.is_empty():
				var light := BlockStructure.new()
				light.name = "Structure_%d_front" % i
				light.tile_set = tile_set
				light.source_id = 1
				light.position = Vector2.ZERO
				light.z_index = 0
				for k in front_cells.size():
					light.cells.append(front_cells[k])
					if k < front_tiles.size():
						light.cell_tiles.append(front_tiles[k])
				chunk.add_child(light)
				chunk.move_child(light, 0)
		else:
			var texture: Texture2D = entry.get("texture", structure.texture)
			if texture == null:
				continue
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.offset = Vector2(
				-texture.get_width() * 0.5,
				-texture.get_height()
			)
			var native := float(structure.pixel_size if structure.pixel_size > 0 else texture.get_width())
			var factor := float(structure.size_tiles * TILE_SIZE) / maxf(native, 1.0)
			sprite.scale = Vector2.ONE * factor
			node = sprite
		if node == null:
			continue
		node.name = "Structure_%d" % i
		node.z_index = structure.z_index
		if node is BlockStructure:
			node.position = Vector2.ZERO
		else:
			node.position = Vector2(
				int(entry["x"]) * TILE_SIZE + TILE_SIZE * 0.5,
				int(entry["y"]) * TILE_SIZE + float(structure.y_offset_px)
			)
		node.set_meta("spawn_id", entry["id"])
		chunk.add_child(node)
		chunk.move_child(node, 0)

	# Breakable crates
	if crate_scene != null:
		for entry in structures_here:
			for crate_entry in entry.get("crates", []):
				var crate_id: String = crate_entry["id"]
				if _broken_blocks.has(crate_id):
					continue
				var crate := crate_scene.instantiate() as BreakableBlock
				if crate == null:
					continue
				var tile_x := int(crate_entry["x"])
				crate.name = "Crate_%s" % crate_id.replace(":", "_")
				crate.spawn_id = crate_id
				crate.position = Vector2(
					tile_x * TILE_SIZE,
					int(data["heights"][tile_x]) * TILE_SIZE
				)
				chunk.entities.add_child(crate)
				crate.broken.connect(_on_crate_broken)

	# Enemies
	for entry in data["enemies"]:
		var spawn_id: String = entry["id"]
		if _defeated_spawns.has(spawn_id):
			continue
		var scene: PackedScene = entry["scene"]
		var enemy := scene.instantiate() as Node2D
		if enemy == null:
			continue
		var spawn_pos: Vector2 = entry["position"]
		var offset: float = enemy.get("spawn_y_offset")
		enemy.position = spawn_pos - Vector2(0.0, _body_bottom(enemy) + offset)
		chunk.entities.add_child(enemy)
		if enemy.has_signal("died"):
			enemy.connect("died", _on_enemy_died.bind(spawn_id))

	# Coins
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


## Keeps enemies and coins on the new surface after a structure flattens the ground.
func level_entities(
		enemies: Array[Dictionary],
		coins: Array[Dictionary],
		center: int,
		half: int,
		ground_row: int
) -> void:
	var ground_y := float(ground_row * TILE_SIZE)
	for enemy in enemies:
		var tile := floori(float(enemy["position"].x) / float(TILE_SIZE))
		if absi(tile - center) > half:
			continue
		var pos: Vector2 = enemy["position"]
		pos.y = ground_y
		enemy["position"] = pos
	for coin in coins:
		var tile := floori(float(coin["position"].x) / float(TILE_SIZE))
		if absi(tile - center) > half:
			continue
		var pos: Vector2 = coin["position"]
		pos.y = ground_y - float(coin_spawn_height)
		coin["position"] = pos


## Drops decor whose column falls inside a structure's footprint.
func decor_outside_structures(
		decor: Array[Dictionary],
		structures_here: Array[Dictionary]
) -> Array[Dictionary]:
	var kept: Array[Dictionary] = []
	for entry in decor:
		var inside := false
		for structure in structures_here:
			if absi(int(structure["x"]) - int(entry["x"])) <= int(structure["half"]):
				inside = true
				break
		if not inside:
			kept.append(entry)
	return kept


# --- Callbacks ---

func _on_enemy_died(spawn_id: String) -> void:
	_defeated_spawns[spawn_id] = true


func _on_coin_collected(spawn_id: String) -> void:
	_collected_spawns[spawn_id] = true


func _on_crate_broken(spawn_id: String) -> void:
	_broken_blocks[spawn_id] = true


# --- Private helpers ---

func _enemy_count_multiplier(chunk_x: int) -> float:
	if chunk_x < enemy_ramp_first_chunks:
		return enemy_ramp_first_multiplier
	var steps := float(chunk_x - enemy_ramp_first_chunks) + 1.0
	return minf(1.0 + enemy_ramp_per_chunk * steps, enemy_ramp_max_multiplier)


func _structure_allowed(structure: WorldStructure, biome: Biome, tile_x: int) -> bool:
	if structure.texture == null and structure.scene == null and structure.pattern.is_empty():
		return false
	if not structure.pattern.is_empty() and structure.tileset == null:
		return false
	if tile_x < structure.min_distance_tiles:
		return false
	return structure.biomes.is_empty() or structure.biomes.has(biome.display_name)


func _structure_x_free(
		local_x: int,
		half: int,
		enemy_half: int,
		placed: Array[Dictionary],
		enemies: Array[Dictionary]
) -> bool:
	for entry in placed:
		var gap := half + int(entry["half"]) + structure_min_gap_tiles
		if absi(int(entry["x"]) - local_x) < gap:
			return false
	for enemy in enemies:
		var enemy_x := roundi(float(enemy["position"].x) / float(TILE_SIZE))
		if absi(enemy_x - local_x) <= enemy_half:
			return false
	return true


func _structure_index_of(structure_name: String) -> int:
	if _structure_lookup.is_empty():
		for i in structures.size():
			_structure_lookup[structures[i].display_name] = i
	return int(_structure_lookup.get(structure_name, -1))


func _blocks_cells(
		structure: WorldStructure,
		left: int,
		length: int,
		heights: PackedInt32Array,
		rng: RandomNumberGenerator
) -> Dictionary:
	var cells: Array[Vector2] = []
	var front: Array[Vector2] = []
	var front_tiles: Array[int] = []
	var rows := structure.pattern.size()
	var unit := maxi(structure.block_width(), 1)
	var bottom := rows - 1
	for col in length:
		var tile_x := left + col
		if tile_x < 0 or tile_x >= chunk_width_tiles:
			continue
		var unit_col := col % unit
		var ground_row := int(heights[tile_x])
		for row in rows:
			if not _pattern_at(structure, row, unit_col, "#"):
				continue
			var pos := Vector2(
				tile_x * TILE_SIZE,
				(ground_row - (rows - row)) * TILE_SIZE
			)
			cells.append(pos)
			if row == bottom and rng.randf() < structure.front_chance:
				front.append(pos)
				front_tiles.append(_pick_tile(BlockStructure.STONE_TILES, rng))
		if bottom >= 1 and not _pattern_at(structure, bottom, unit_col, "#"):
			if _pattern_at(structure, bottom - 1, unit_col, "#"):
				if rng.randf() < structure.support_chance:
					front.append(Vector2(tile_x * TILE_SIZE, (ground_row - 1) * TILE_SIZE))
					front_tiles.append(_pick_tile(BlockStructure.SUPPORT_TILES, rng))
	return {"cells": cells, "front": front, "front_tiles": front_tiles}


func _crate_tiles(
		coord: Vector2i,
		left: int,
		length: int,
		front: Array,
		enemies: Array[Dictionary],
		rng: RandomNumberGenerator
) -> Array:
	var tiles: Array = []
	if crates_per_ruin <= 0 or coord.x == 0 or length <= 0:
		return tiles
	var blocked := {}
	for cell in front:
		blocked[floori(cell.x / float(TILE_SIZE))] = true
	for enemy in enemies:
		blocked[roundi(float(enemy["position"].x) / float(TILE_SIZE))] = true
	var used := {}
	for _i in range(crates_per_ruin):
		for _attempt in range(6):
			var tile_x := left + rng.randi_range(0, length - 1)
			if tile_x < 0 or tile_x >= chunk_width_tiles:
				continue
			if used.has(tile_x) or blocked.has(tile_x):
				continue
			if blocked.has(tile_x - 1) or blocked.has(tile_x + 1):
				continue
			used[tile_x] = true
			tiles.append({"id": "b:%d:%d:%d" % [coord.x, coord.y, tile_x], "x": tile_x})
			break
	return tiles


func _pattern_at(structure: WorldStructure, row: int, col: int, mark: String) -> bool:
	if row < 0 or row >= structure.pattern.size():
		return false
	if col >= structure.pattern[row].length():
		return false
	return structure.pattern[row][col] == mark


func _pick_tile(pool: Array, rng: RandomNumberGenerator) -> int:
	return pool[rng.randi_range(0, pool.size() - 1)]


func _body_bottom(enemy: Node2D) -> float:
	var bottom := 0.0
	for child in enemy.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node and shape_node.shape is RectangleShape2D:
			var rect := shape_node.shape as RectangleShape2D
			var local_bottom: float = shape_node.position.y + rect.size.y * 0.5 * shape_node.scale.y
			bottom = maxf(bottom, local_bottom * enemy.scale.y)
	return bottom
