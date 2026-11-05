class_name Biome
extends Resource
## Bioma del mundo: tinte del césped y enemigos propios.
## El tinte se multiplica sobre la textura gris del césped, así cualquier color vale.

## Nombre que se muestra en el inspector.
@export var display_name: String = ""
## Tinte del césped (la textura es gris); blanco = sin teñir.
@export var grass_color: Color = Color.WHITE
## Tinte de los bosques de fondo y de la vegetación de la montaña; independiente del césped.
@export var forest_color: Color = Color.WHITE
## Peso relativo en el reparto de biomas del mundo.
@export var spawn_weight: float = 1.0
## Multiplicador de la amplitud del ruido del terreno (1 = sin cambio); más alto = alturas más marcadas.
@export_range(0.1, 3.0, 0.05) var terrain_amplitude_multiplier: float = 1.0
## Multiplicador de la frecuencia del ruido del terreno (1 = sin cambio); más alto = relieve más quebrado.
@export_range(0.1, 3.0, 0.05) var terrain_frequency_multiplier: float = 1.0
## Escenas de enemigos que aparecen en el bioma.
@export var enemy_scenes: Array[PackedScene] = []
## Cantidad por chunk, en el mismo orden que `enemy_scenes`.
@export var enemy_counts: Array[int] = []
