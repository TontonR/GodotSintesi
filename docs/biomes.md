# Biomes — resources, runs and tinting

_2026-11-01 · 2026-11-05 · 2026-11-10 · 2026-11-12_

## What it does and where it lives

- `scripts/world/biome.gd` (`class_name Biome`, `Resource`) describes one biome.
- Three resources in `resources/world/biomes/`, loaded by
  `WorldGenerator.biomes` (the first one is the safe zone):
  `pradera.tres`, `bosque_rojo.tres` and `nieve.tres`.
- The biome decides the grass/forest/rock tints, the ambient particles, the terrain
  modifiers and **which enemies spawn in its chunks**.

## Fields

| Field | Meaning |
|---|---|
| `display_name` | Inspector name only |
| `grass_color` | Tint over the gray grass texture (white = untinted) |
| `forest_color` | Tint of the background pines, the mountain's green layer and the band under the mountains |
| `rock_color` | Tint of the mountain stone (snow is never tinted) |
| `decor_colors` | Tints for bushes and the living tree (gray textures); each sprite picks one at random |
| `decor_color_weights` | Weight of each `decor_colors` tint (same order; empty = equal) |
| `decor_per_chunk` | Decor sprites per chunk (0 = generator fallback, 16) |
| `decor_kinds` | Decor names from `WorldGenerator.decor_names` |
| `decor_weights` | Weight per kind (same order; empty = all 1) |
| `ambient` | `"none"`, `"leaves"` or `"snow"` |
| `spawn_weight` | Relative weight for the order roll |
| `min_distance_tiles` | Distance from tile 0 before the biome can appear |
| `terrain_amplitude_multiplier` | Noise amplitude multiplier; **never above 1.0** (see Traps) |
| `terrain_frequency_multiplier` | Noise frequency multiplier; **never above 1.0** |
| `enemy_scenes` | Scenes spawned in its chunks |
| `enemy_counts` | Base count per chunk, same order as `enemy_scenes` |

## Current biomes

| Biome | Grass | Forest | Rock | Decor | Ambient | Weight | Unlock | Enemies per chunk |
|---|---|---|---|---|---|---|---|---|
| Meadow (`pradera`) | `(0.72, 1, 0.28)` | `(0.233, 0.388, 0.388)` | white | 3 greens (4/4/3) | none | 0.55 | tile 0 | 3 orc, 3 slime, 1 toad |
| Red Forest (`bosque_rojo`) | `(0.674, 0.196, 0.159)` | `(0.625, 0, 0.036)` | white | red/orange/yellow (6/3/1) | leaves | 0.30 | tile 0 | 1 wolf, 1 toad |
| Snow (`nieve`) | `(0.93, 0.96, 1)` | `(0.82, 0.88, 0.96)` | `(0.75, 0.78, 0.82)` | 3 cold greens (3/3/2) | snow | 0.20 | tile 4096 | 2 skeleton, 2 archer, 1 wolf |

All three keep `terrain_amplitude_multiplier` at 0.95/0.95/1.0 and
`terrain_frequency_multiplier` at 1.0: a biome only flattens, it never exaggerates relief.

## Decor per biome

Each biome decides how much decoration its chunks get and of which kinds
(`decor_per_chunk`, `decor_kinds`, `decor_weights`) and how the tints are
weighted (`decor_color_weights`). Kinds are the generator's names (`bush_1`,
`bush_2`, `tree`, `tree_dead`, `rock_1`, `rock_2`); an unknown name is skipped.

| Biome | Per chunk | Weights (bush 1/2, tree, dead, rock 1/2) | Living trees |
|---|---|---|---|
| Meadow | 32 | 4 / 4 / 12 / 1 / 2 / 2 | ~13 |
| Red Forest | 52 | 4 / 4 / 26 / 4 / 1 / 1 | ~35 |
| Snow | 24 | 3 / 3 / 8 / 4 / 3 / 3 | ~8 |

The meadow keeps open air with plenty of trees; the red forest is a dense
canopy almost twice as thick per chunk. Full reference: [`decor.md`](decor.md).

`bosque_rojo.tres` still has `enemy_counts = [1, 1, 1, 2]` with only two scenes; the loop
stops at `scenes.size()`, so the last two counts are ignored. If the demon/slimes are meant
to come back, their scenes must be added first.

## How runs are decided

- Biomes are decided **per run of blocks, not per chunk**:
  `_ensure_biome_runs()` builds a cached list of `{start, index, length}` left to right and
  any tile resolves to the run that contains it.
- The first run starts at tile 0 and is always `biomes[0]` (meadow): the safe zone.
- Length is rolled between `min_biome_tiles` 1024 (4 chunks) and `max_biome_tiles` 4096
  (16 chunks), rounded to `biome_sector_tiles` (0 = one chunk, 256 tiles). No micro-biomes
  and no endless stretches; the 256-tile blend is narrower than the shortest run, so two
  transitions never overlap.
- The next biome is picked by `_roll_biome_at()` among those unlocked at that distance and
  **never repeats the previous one**. `spawn_weight` only biases the pick; the noise
  (`biome_frequency` 0.12 per chunk, `biome_contrast` 2) decides the order.
- Enemies stay per chunk: `_biome_for_chunk()` reads the biome of the chunk's central
  block, so a chunk whose seam falls inside a transition keeps one enemy set.

## Transitions and tint

- `biome_transition_tiles` 0 means one full chunk (256): each block uses the moving average
  of its window's biome colors (±128 blocks), so both color and terrain change as a
  gradient instead of stepping at the seam.
- `WorldChunk.paint()` receives one grass tint per block and paints each grass tile with
  its own color (`Grass` as a separate node disappeared: a `TileMapLayer` can only be
  tinted as a whole).
- Backgrounds: `forest_tint_paths` (far pine, near pine, mountain green layer) use
  `forest_color`; `rock_tint_paths` (mountain stone) uses `rock_color`; the band under the
  mountains (`base_tint_paths`) uses `forest_color` darkened `MOUNTAIN_BASE_DARKENING`
  (0.35), which reproduces the meadow `#283D43`. Snow layers are never tinted.
- The pine textures are gray versions of the originals, each with its own calibrated gray
  (far 116, near 92, mountain 172/211), so the tint doesn't flatten the depth difference.
- Ambient particles: `scripts/world/biome_particles.gd` samples
  `WorldGenerator.biome_at_world_x()` at the player's X every 0.25 s and turns on leaves
  (28 particles) or snow (220 flakes); they enter/leave with a 0.4 s fade and sideways wind.

## Adding a biome

1. Create `resources/<name>.tres` with the `Biome` script.
2. Add it to `WorldGenerator.biomes` (order matters only for the safe zone, which is index
   0; weights handle the rest).
3. Keep `terrain_amplitude_multiplier` and `terrain_frequency_multiplier` at or below 1.0.
4. Set `ambient` to one of the existing values; a new ambient needs a new emitter in
   `biome_particles.gd`.
5. If it has enemies, add both `enemy_scenes` and `enemy_counts` in the same order.

## Traps

- A biome with multipliers above 1.0 makes the ±1 step cap lag behind the noise and grows
  30–40 tile mountains with runs of 100+ single steps (T-0051). The cap is not a slope
  generator: it can only follow the noise.
- The blend order is fixed by biome index and computed in float64 so two chunks agree
  exactly at the seam; don't reorder `biomes` mid-run or the tint will step.
- `min_distance_tiles` is checked in tiles, not chunks (snow: 4096 = 16 chunks).
