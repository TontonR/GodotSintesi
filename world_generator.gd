extends TileMapLayer

# Ancho del mundo en tiles - mucho más grande y plano
@export var world_width: int = 3000
# Altura base del suelo (tile Y) - todo plano a esta altura (más bajo para ver más cielo)
@export var ground_level: int = 20
# Profundidad del suelo (capas debajo de la superficie)
@export var ground_depth: int = 15

# ==============================================================================
# CONFIGURACIÓN DEL GENERADOR DE ORCOS Y VARIANTES DE ENEMIGOS
# ==============================================================================
# Precarga directa de la escena del orco guardada
@export var orc_scene: PackedScene = preload("res://orc.tscn")
# Cantidad fija de Orcos iniciales a generar a lo largo del mapa
@export var initial_orc_count: int = 5
# Margen en tiles desde el origen para empezar a instanciar enemigos
@export var min_spawn_x_tile: int = 50

func _ready() -> void:
	_generate_world()
	_spawn_initial_orcs()

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

# ==============================================================================
# SISTEMA DE APARICIÓN E INSTANCIACIÓN DE ORCOS Y ENTORNO AUTÓNOMO
# ==============================================================================
# Esta función distribuye instancias del Orco a lo largo de la superficie del mapa.
# En el futuro, puedes duplicar esta lógica o extenderla usando un array de PackedScenes
# para instanciar distintas variantes de enemigos (ej. Orco Chamán, Orco Élite, etc.)
# ajustando sus atributos o escalas al ser instanciados.
func _spawn_initial_orcs() -> void:
	if not orc_scene:
		print("Advertencia: No se ha encontrado la escena orc.tscn")
		return

	# Calcula la posición Y del suelo en píxeles (16px por tile - altura del personaje)
	var spawn_y_pixels: float = (ground_level * 16) - 16

	for i in range(initial_orc_count):
		# Genera una posición X aleatoria repartida por el mapa plano
		var random_tile_x: float = randf_range(min_spawn_x_tile, world_width - 50)
		var spawn_x_pixels: float = random_tile_x * 16

		# Instancia la escena del Orco de forma independiente
		var new_orc = orc_scene.instantiate() as CharacterBody2D
		new_orc.position = Vector2(spawn_x_pixels, spawn_y_pixels)
		
		# Agrega la instancia al nodo raíz del juego para que tenga autonomía física
		get_parent().add_child.call_deferred(new_orc)
