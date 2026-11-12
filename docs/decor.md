# Decor — bushes, trees and rocks

_2026-11-12 · branch `feat/decor`_

## What it does and where it lives

- `assets/map/decor/` holds every prop: `Bush/bush_1.png`, `Bush/bush_2.png`
  (48×32), `Tree/tree.png`, `Tree/tree_dead.png` (80×112), `Rock/rock_1.png`
  and `Rock/rock_2.png` (48×32).
- `WorldGenerator` (group **Decor**) rolls each chunk's decor while generating
  the chunk data; `_spawn_chunk_entities()` creates one `DecorProp` per entry
  (`scripts/world/decor_prop.gd`, a `Sprite2D`).
- Every sprite is added as the chunk's **first child** (`move_child(sprite, 0)`),
  so it is painted behind `Solid` and `GrassPaint`, and freed with the chunk.
  No collision, no shadow, no parallax.
- The chunk RNG is used after enemies and coins: the same seed reproduces the
  same layout and persisting kills/coins never moves the decor.

## Density and kinds are decided by the biome

`Biome` owns the decor: `decor_per_chunk`, `decor_kinds` (names from
`WorldGenerator.decor_names`: `bush_1`, `bush_2`, `tree`, `tree_dead`, `rock_1`,
`rock_2`) and `decor_weights` (same order; empty = all 1). The generator values
are only the fallback for biomes that do not configure it.

| Biome | Per chunk | Kinds (weights) | Result |
|---|---|---|---|
| Meadow | 20 | bush 3/3, tree 9, dead 1, rocks 1/1 | ~10 living trees, open |
| Red Forest | 26 | bush 3/3, tree 12, dead 3, rocks 1/1 | ~14 trees, dense canopy |
| Snow | 10 | bush 2/2, tree 5, rocks 2/2 | ~4 trees, 40% dead, sparse |

`Biome.decor_dead_tree_ratio` turns exactly that share of the chunk's living
trees into dead ones (Snow 0.4). The count is exact per chunk instead of a
random weight, so a sparse biome cannot come out too alive or too dead.

## Scale, depth and draw order

- `decor_scales` (bushes 1.9, trees 1.8, rocks 1.7): decoration is now large
  scenery; it is a fixed scale, never depth scaling.
- `decor_z_index` puts rocks at **−1**: they read as background, behind the
  grass row and the other props, so they never look like an obstacle.
- Draw order inside the chunk is rocks → trees → bushes. The generation list is
  sorted front to back and each sprite is pushed to index 0; since index 0 is
  painted first, the final order is rocks (back), trees, bushes (front). Rocks
  also draw behind because of their `z_index`.

## Placement

- Stratified slots: the usable span is split into `decor_per_chunk` equal
  slots and each prop rolls its X inside its own slot (±30% of the slot), so
  the chunk stays evenly covered instead of clumping in a few spots.
- `decor_min_gap_tiles` (3) is enforced between neighbors: if the jitter brings
  two props closer, the second snaps to its slot center or is skipped.
- `decor_margin_tiles` (2) keeps props away from the chunk edges, so props of
  two chunks never land on top of each other at a seam.
- `centered = false` with `offset = (−w/2, −h)` and the node at the bottom
  center of the column: scaling keeps the base on the surface row and the sway
  rotates around the ground. On slopes the terrain occludes the base.
- Because the sprite origin is the base, `DecorProp` can use `global_position`
  as the contact point with the player.

## Tints (weighted per biome)

- Bushes and the living tree are tinted **per pixel at runtime**
  (`WorldGenerator._decor_texture`): a copy of the original texture is cached
  per texture + tint, and only the green-dominant pixels (the leaves) become
  `tint * max(R,G,B)`. The trunk, outlines and browns keep their own colors, so
  `modulate` stays white and the trunk is never tinted.
- `decor_tinted` marks which textures take a tint (bushes and tree `true`, dead
  tree and rocks `false`). The old `*_gray.png` copies are no longer used.
- `Biome.decor_colors` plus `decor_color_weights`: the red forest mixes red (6),
  orange (3) and yellow (1), so trees and bushes are mostly red with a few
  orange/yellow ones. Meadow greens 4/4/3, snow cold greens 3/3/2. Empty weights
  = flat pick; empty colors = `Color.WHITE`.
- The tint is `modulate` over the gray copy, so shading survives.

## Bushes: bend and leaves

- `DecorProp.sways` (the two bushes) enables `_process`; trees and rocks keep it
  off, so a dense chunk costs nothing.
- Within `decor_sway_radius_px` (48) of the player the bush bends up to
  `sway_angle` (0.1 rad) with a per-bush phase and returns upright on its own.
- On entering that radius it calls `fx.leaves()` (`scripts/fx.gd`): a 7-leaf
  burst in the bush's own tint. Particles go through the shared `fx` node, so
  they do not inherit the sprite's scale and are not tied to the chunk.

## Adding or changing decor

1. Drop the sprite in `assets/map/decor/<Kind>/`.
2. If its leaves are green and should take the biome color, add the **original**
   texture and `decor_tinted = true` at the same index; the runtime tint only
   hits the green-dominant pixels, so the trunk can stay brown.
3. Tune `decor_scales`, `decor_z_index` and `decor_sways` for that index.
4. Reference the name from each biome's `decor_kinds`/`decor_weights`.

## Traps

- `decor_names`, `decor_textures`, `decor_tinted`, `decor_scales`,
  `decor_z_index` and `decor_sways` are parallel arrays. A missing entry falls
  back to a sane default; an unknown biome kind is skipped, never fatal.
- Do not sort the decor after spawning: the index-0 push is what keeps it behind
  the tiles. Sorting is done on the chunk data before spawning.
- `decor_tinted` needs textures with green-dominant leaves: the runtime tint
  only recolors green pixels, so a fully gray texture would come out flat.
- The sway must not move `position`: `offset` is what centers the texture, so
  rotating does not make the bush slide or sink.
