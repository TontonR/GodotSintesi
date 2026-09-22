extends TileMapLayer

# Ancho del mundo en tiles - mucho más grande y plano
@export var world_width: int = 3000
# Altura base del suelo (tile Y) - todo plano a esta altura
@export var ground_level: int = 12
# Profundidad del suelo (capas debajo de la superficie)
@export var ground_depth: int = 15

func _ready() -> void:
	_generate_world()

func _generate_world() -> void:
	clear()
	# Mundo completamente plano sin ruido ni montañas
	for x in world_width:
		# Superficie: hierba (todo a la misma altura)
		set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0))
		# Suelo debajo
		for y in range(ground_level + 1, ground_level + ground_depth):
			if (y == ground_level +1 ):
				set_cell(Vector2i(x,y), 0, Vector2(2,1))
			else:
				set_cell(Vector2i(x, y), 0, Vector2i(2, 2))
	# Posicionar al jugador sobre el suelo plano
	var player_x: int = world_width / 4
	var player: CharacterBody2D = get_node("/root/game/player")
	player.position = Vector2(player_x * 16 + 8, ground_level * 16 - 32)
