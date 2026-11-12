# Decor — bushes, trees and rocks

_2026-11-12 · branch `feat/decor`_

## What it does and where it lives

- `assets/map/decor/` holds every prop: `Bush/bush_1.png`, `Bush/bush_2.png`
  (48×32), `Tree/tree.png`, `Tree/tree_dead.png` (80×112), `Rock/rock_1.png`
  and `Rock/rock_2.png` (48×32).
- `WorldGenerator` (group **Decor**) rolls `decor_per_chunk` entries (16) per
  chunk and stores them in the chunk data; `_spawn_chunk_entities()` creates one
  `Sprite2D` per entry.
- Each sprite is added as the chunk's **first child** (`move_child(sprite, 0)`),
  so it is painted behind `Solid` and `GrassPaint`. No `z_index` is needed.
- They are world-space sprites: they move with the chunk (not parallax), are
  freed with it, have no collision, no shadow and are never scaled.

## Placement

- Random tile X with `decor_margin_tiles` (2) on both chunk edges.
- `centered = false`; the bottom edge sits on the surface row
  (`height * TILE_SIZE`), i.e. at the same height as the grass tile. On slopes
  the terrain occludes the base; no extra offset is applied.
- `decor_weights`, same order as `decor_textures`: bush 4/4, living tree 1,
  dead tree 1, rock 2/2 (total 14). With 16 per chunk that is ~4–5 bushes,
  ~2 trees and ~4–5 rocks.
- The chunk RNG is used after enemies and coins, so persisting kills/coins never
  moves the decor and the same seed reproduces the same layout.

## Tints

- Bushes and the living tree use **gray** copies (`bush_1_gray.png`,
  `bush_2_gray.png`, `tree_gray.png`): only green-dominant pixels are turned
  into `max(R,G,B)` gray; trunks and browns keep their color (same recipe as the
  pines).
- `decor_tinted` marks which textures take a tint (bushes and tree `true`, dead
  tree and rocks `false`), so browns are never painted red or blue.
- Each tinted sprite picks a random color from `Biome.decor_colors` at its own
  tile (`_decor_tint_at()`), so one meadow mixes three greens and the red forest
  mixes reds/oranges. Empty array = `Color.WHITE` (untinted).
- The tint is `modulate`, so the gray is multiplied: the darkest leaves stay
  dark and the tint keeps the sprite's shading.

## Adding or changing decor

1. Drop the sprite in `assets/map/decor/<Kind>/`.
2. If it is green and should take the biome color, generate its gray copy and
   add both to `decor_textures` with `decor_tinted = true`.
3. Add a weight in `decor_weights` at the same index.
4. Tune `decor_per_chunk` per chunk (density) and `decor_margin_tiles`.

## Traps

- A sprite added after the chunk is painted must be moved to index 0, or it
  covers the grass and the player.
- Tinting a non-gray texture flattens it: always generate the gray copy first.
- `decor_textures`, `decor_tinted` and `decor_weights` are parallel arrays; a
  missing entry just disables the kind, never fails silently.
