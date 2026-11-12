class_name Biome
extends Resource
## World biome: grass tint and its own enemies.
## The tint is multiplied over the gray grass texture, so any color works.

## Name shown in the inspector.
@export var display_name: String = ""
## Grass tint (the texture is gray); white = untinted.
@export var grass_color: Color = Color.WHITE
## Tint of the background forests and the mountain vegetation; independent from the grass.
@export var forest_color: Color = Color.WHITE
## Tint of the mountain stone; white = untinted (snow is separate and not tinted).
@export var rock_color: Color = Color.WHITE
## Decoration tints for the bushes and the living tree (their textures are gray).
## Every decor sprite picks one of these at random; rocks and dead trees are never tinted.
@export var decor_colors: Array[Color] = []
## Ambient particles: "none", "leaves" (red leaves) or "snow" (snowflakes).
@export_enum("none", "leaves", "snow") var ambient: String = "none"
## Relative weight in the world's biome distribution.
@export var spawn_weight: float = 1.0
## Distance from the start (tiles) before this biome can appear at all.
@export var min_distance_tiles: int = 0
## Terrain noise amplitude multiplier (1 = unchanged); higher = more pronounced heights.
@export_range(0.1, 3.0, 0.05) var terrain_amplitude_multiplier: float = 1.0
## Terrain noise frequency multiplier (1 = unchanged); higher = more broken relief.
@export_range(0.1, 3.0, 0.05) var terrain_frequency_multiplier: float = 1.0
## Enemy scenes that spawn in the biome.
@export var enemy_scenes: Array[PackedScene] = []
## Amount per chunk, in the same order as `enemy_scenes`.
@export var enemy_counts: Array[int] = []
