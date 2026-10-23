class_name WorldChunk
extends Node2D

const ROW_SURFACE := 0
const ROW_FILL := 1
const ROW_BOTTOM := 2

var entities: Node2D
var _solid: TileMapLayer


func _ready() -> void:
	# Buscar el nodo Entities existente.
	for child in get_children():
		if child is Node2D and child.name.to_lower() == "entities":
			entities = child
			break

	if entities == null:
		entities = Node2D.new()
		entities.name = "Entities"
		add_child(entities)

	# Buscar una capa Solid existente.
	_solid = get_node_or_null("Solid") as TileMapLayer

	# Si no existe, crearla.
	if _solid == null:
		_solid = TileMapLayer.new()
		_solid.name = "Solid"
		add_child(_solid)

	move_child(_solid, 0)


func paint(
		heights: PackedInt32Array,
		edge_left: int,
		edge_right: int,
		tile_set: TileSet,
		source_id: int,
		atlas_origin: Vector2i,
		floor_row: int,
		swap_left_right: bool
) -> void:
	_solid.clear()
	_solid.tile_set = tile_set

	var width := heights.size()

	for x in range(width):
		var surface := heights[x]
		var left_surface := edge_left if x == 0 else heights[x - 1]
		var right_surface := edge_right if x == width - 1 else heights[x + 1]

		for y in range(surface, floor_row):
			var has_left := y >= left_surface
			var has_right := y >= right_surface

			var col := 1

			if not has_left and has_right:
				col = 0
			elif has_left and not has_right:
				col = 2

			if swap_left_right and col != 1:
				col = 2 - col

			var row := ROW_SURFACE if y == surface else ROW_FILL

			_solid.set_cell(
				Vector2i(x, y),
				source_id,
				atlas_origin + Vector2i(col, row)
			)