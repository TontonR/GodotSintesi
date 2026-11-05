class_name WorldChunk
extends Node2D

const ROW_SURFACE := 0
const ROW_FILL := 1
const ROW_BOTTOM := 2


## Pinta el césped bloque a bloque: un `TileMapLayer` solo se puede teñir entero
## con `modulate`, y el bioma cambia de color dentro del propio chunk.
class GrassPaint extends Node2D:
	var textures: Array[Texture2D] = []
	var rects: Array[Rect2] = []
	var regions: Array[Rect2] = []
	var colors: PackedColorArray = PackedColorArray()

	func set_tiles(
			textures_new: Array[Texture2D],
			rects_new: Array[Rect2],
			regions_new: Array[Rect2],
			colors_new: PackedColorArray
	) -> void:
		textures = textures_new
		rects = rects_new
		regions = regions_new
		colors = colors_new
		queue_redraw()

	func _draw() -> void:
		for i in rects.size():
			draw_texture_rect_region(textures[i], rects[i], regions[i], colors[i])


var entities: Node2D
var _solid: TileMapLayer
var _grass_paint: GrassPaint


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

	# El césped va encima del suelo y por debajo de las entidades.
	_grass_paint = GrassPaint.new()
	_grass_paint.name = "GrassPaint"
	add_child(_grass_paint)
	move_child(_grass_paint, _solid.get_index() + 1)


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
		swap_left_right: bool,
		grass_tints: PackedColorArray = PackedColorArray()
) -> void:
	_solid.clear()
	_solid.tile_set = tile_set

	# Atlas del césped: un color de `grass_tints` por columna.
	var grass_source: TileSetAtlasSource = null
	var grass_texture: Texture2D = null
	var grass_size := Vector2.ZERO
	if grass_tile_set != null:
		grass_source = grass_tile_set.get_source(source_id) as TileSetAtlasSource
		if grass_source:
			grass_texture = grass_source.texture
			grass_size = Vector2(grass_source.texture_region_size)

	var textures: Array[Texture2D] = []
	var rects: Array[Rect2] = []
	var regions: Array[Rect2] = []
	var colors := PackedColorArray()

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

			if y == surface and grass_texture != null:
				var coords := atlas_origin + Vector2i(col, 0)
				if grass_source.has_tile(coords):
					textures.append(grass_texture)
					rects.append(Rect2(Vector2(x * grass_size.x, y * grass_size.y), grass_size))
					regions.append(Rect2(grass_source.get_tile_texture_region(coords)))
					colors.append(_grass_tint(grass_tints, x))

	# Columna extra a la derecha: cada chunk es una capa distinta y, con
	# escalado fraccionario, el redondeo a píxel deja una grieta de 1 px en la
	# unión. Se pinta la primera columna del chunk siguiente, idéntica, para taparla.
	var next_surface := edge_right
	var next_left := heights[width - 1]
	for y in range(next_surface, floor_row):
		var col := _edge_col(y, next_left, edge_right_next, swap_left_right)
		var row := ROW_SURFACE if y == next_surface else ROW_FILL
		_solid.set_cell(Vector2i(width, y), source_id, atlas_origin + Vector2i(col, row))
	if grass_texture != null:
		var grass_col := _edge_col(next_surface, next_left, edge_right_next, swap_left_right)
		var coords := atlas_origin + Vector2i(grass_col, 0)
		if grass_source.has_tile(coords):
			textures.append(grass_texture)
			rects.append(Rect2(Vector2(width * grass_size.x, next_surface * grass_size.y), grass_size))
			regions.append(Rect2(grass_source.get_tile_texture_region(coords)))
			colors.append(_grass_tint(grass_tints, width))

	_grass_paint.set_tiles(textures, rects, regions, colors)


## Color del césped de una columna; blanco cuando no llega la lista (sin biomas).
func _grass_tint(grass_tints: PackedColorArray, index: int) -> Color:
	if index < 0 or index >= grass_tints.size():
		return Color.WHITE
	return grass_tints[index]


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
