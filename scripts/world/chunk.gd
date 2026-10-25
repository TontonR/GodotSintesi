class_name WorldChunk
extends Node2D

const ROW_SURFACE := 0
const ROW_FILL := 1
const ROW_BOTTOM := 2

var entities: Node2D
var _solid: TileMapLayer
var _grass: TileMapLayer


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

	# Capa de césped: se pinta encima de la superficie.
	_grass = get_node_or_null("Grass") as TileMapLayer
	if _grass == null:
		_grass = TileMapLayer.new()
		_grass.name = "Grass"
		add_child(_grass)


func paint(
		heights: PackedInt32Array,
		edge_left: int,
		edge_right: int,
		edge_right_next: int,
		tile_set: TileSet,
		source_id: int,
		atlas_origin: Vector2i,
		grass_tile_set: TileSet,
		floor_row: int,
		swap_left_right: bool
) -> void:
	_solid.clear()
	_solid.tile_set = tile_set
	_grass.clear()
	_grass.tile_set = grass_tile_set

	var width := heights.size()

	for x in range(width):
		var surface := heights[x]
		var left_surface := edge_left if x == 0 else heights[x - 1]
		var right_surface := edge_right if x == width - 1 else heights[x + 1]

		for y in range(surface, floor_row):
			var col := _edge_col(y, left_surface, right_surface, swap_left_right)
			var row := ROW_SURFACE if y == surface else ROW_FILL

			_solid.set_cell(
				Vector2i(x, y),
				source_id,
				atlas_origin + Vector2i(col, row)
			)

			if y == surface and grass_tile_set != null:
				_grass.set_cell(Vector2i(x, y), source_id, atlas_origin + Vector2i(col, 0))

	# Columna extra a la derecha: cada chunk es una capa distinta y, con
	# escalado fraccionario, el redondeo a píxel deja una grieta de 1 px en la
	# unión. Se pinta la primera columna del chunk siguiente, idéntica, para taparla.
	var next_surface := edge_right
	var next_left := heights[width - 1]
	for y in range(next_surface, floor_row):
		var col := _edge_col(y, next_left, edge_right_next, swap_left_right)
		var row := ROW_SURFACE if y == next_surface else ROW_FILL
		_solid.set_cell(Vector2i(width, y), source_id, atlas_origin + Vector2i(col, row))
	if grass_tile_set != null:
		var grass_col := _edge_col(next_surface, next_left, edge_right_next, swap_left_right)
		_grass.set_cell(Vector2i(width, next_surface), source_id, atlas_origin + Vector2i(grass_col, 0))


## Columna del atlas segun los bordes libres a izquierda/derecha del tile.
func _edge_col(y: int, left_surface: int, right_surface: int, swap: bool) -> int:
	var col := 1
	var has_left := y >= left_surface
	var has_right := y >= right_surface
	if not has_left and has_right:
		col = 0
	elif has_left and not has_right:
		col = 2
	if swap and col != 1:
		col = 2 - col
	return col
