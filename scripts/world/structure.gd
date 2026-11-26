class_name WorldStructure
extends Resource
## Placeable chunk structure (ruin, tower, house...). The world generator rolls
## it per chunk with the world seed; the biome decides how many appear.
## Playable as a plain sprite now and as a full scene when there is art.

## Name shown in the inspector and used by `Biome.structure_kinds`.
@export var display_name: String = ""
## Optional scene, used instead of `texture` when set (collision stays its own job).
@export var scene: PackedScene
## Texture when there is no scene; the node origin is its bottom center.
@export var texture: Texture2D
## Extra textures for that sprite: one is picked per placement (stable for the
## seed), so several colors of the same structure need a single resource.
@export var textures: Array[Texture2D] = []
## Native width of `texture` in px (0 = the texture's own width). Only used to scale.
@export var pixel_size: int = 0
## Width the structure occupies, in tiles: spacing, margins and enemy avoidance.
@export var size_tiles: int = 4
## Minimum distance from the chunk edges, in tiles.
@export var margin_tiles: int = 2
## Draw order inside the chunk; negative goes behind the grass row.
@export var z_index: int = 0
## Distance from tile 0 before it can appear.
@export var min_distance_tiles: int = 0
## Vertical offset of the sprite in px; positive sinks it into the ground.
@export var y_offset_px: int = 0
## Levels the ground under the structure's span, so a hill never buries it nor
## leaves it floating (tents, houses). Sprite structures only.
@export var flatten_ground: bool = false
## Biome `display_name`s where it can appear; empty = all.
@export var biomes: Array[String] = []

## Type 2: block pattern, one string per row from top to bottom; `#` is a block
## and any other character is empty. Overrides the texture while it is set.
@export var pattern: Array[String] = []
## Tileset for the pattern: source 0 = dark wall (no physics), source 1 = light
## stones, whose collision comes from the TileSet itself.
@export var tileset: TileSet
## Chance (0-1) that a bottom-row wall block becomes a stone in front (solid).
@export var front_chance: float = 0.25
## Chance (0-1) that a niche under the wall is filled with a support beam.
@export var support_chance: float = 0.6
## Pattern columns the structure repeats (0 = exactly one pattern width).
@export var min_length_tiles: int = 0
## Max columns after repeating the pattern (0 = exactly one pattern width).
@export var max_length_tiles: int = 0


## Width the structure occupies in tiles: the pattern's when it has one.
func block_width() -> int:
	var width := size_tiles
	for row in pattern:
		width = maxi(width, row.length())
	return width
