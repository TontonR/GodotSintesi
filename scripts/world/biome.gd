class_name Biome
extends Resource
## Bioma del mundo: tinte del césped y enemigos propios.
## El tinte se multiplica sobre la textura gris del césped, así cualquier color vale.

## Nombre que se muestra en el inspector.
@export var display_name: String = ""
## Tinte del césped (la textura es gris); blanco = sin teñir.
@export var grass_color: Color = Color.WHITE
## Peso relativo en el reparto de biomas del mundo.
@export var spawn_weight: float = 1.0
## Escenas de enemigos que aparecen en el bioma.
@export var enemy_scenes: Array[PackedScene] = []
## Cantidad por chunk, en el mismo orden que `enemy_scenes`.
@export var enemy_counts: Array[int] = []
