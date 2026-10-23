class_name WorldChunk
extends Node2D

@onready var solid: TileMapLayer = $Solid
@onready var grass: TileMapLayer = $Grass
@onready var entities: Node2D = $Entities


func paint(
	heights: PackedInt32Array,
	edge_left: int,
	edge_right: int,
	solid_tiles: TileSet,
	grass_tiles: TileSet,
	source_id: int,
	surface: Vector2i,
	fill: Vector2i,
	grass_coord: Vector2i,
	fill_depth: int = 4
) -> void:
	solid.tile_set = solid_tiles
	grass.tile_set = grass_tiles
	var last := heights.size() - 1
	for x in range(heights.size()):
		var h := heights[x]
		var left_h := heights[x - 1] if x > 0 else edge_left
		var right_h := heights[x + 1] if x < last else edge_right

		# Borde izquierdo (0), centro (1) o borde derecho (2) si el vecino baja.
		var tile_x := 1
		var left_lower := left_h < h
		var right_lower := right_h < h
		if left_lower and not right_lower:
			tile_x = 0
		elif right_lower and not left_lower:
			tile_x = 2

		solid.set_cell(Vector2i(x, h), source_id, Vector2i(tile_x, surface.y))
		for y in range(h + 1, h + 1 + fill_depth):
			solid.set_cell(Vector2i(x, y), source_id, fill)
		grass.set_cell(Vector2i(x, h), source_id, Vector2i(tile_x, grass_coord.y))
