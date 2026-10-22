class_name WorldChunk
extends Node2D

@onready var solid: TileMapLayer = $Solid
@onready var grass: TileMapLayer = $Grass
@onready var entities: Node2D = $Entities


func paint(
	heights: PackedInt32Array,
	world_height: int,
	solid_tiles: TileSet,
	grass_tiles: TileSet,
	source_id: int,
	surface: Vector2i,
	fill: Vector2i,
	grass_coord: Vector2i
) -> void:
	solid.tile_set = solid_tiles
	grass.tile_set = grass_tiles
	for x in range(heights.size()):
		var h := heights[x]
		solid.set_cell(Vector2i(x, h), source_id, surface)
		for y in range(h + 1, world_height):
			solid.set_cell(Vector2i(x, y), source_id, fill)
		grass.set_cell(Vector2i(x, h), source_id, grass_coord)
