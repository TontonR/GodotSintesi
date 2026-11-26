# World — procedural chunk generation

_2026-10-23 · 2026-10-25 · 2026-11-05 · 2026-11-10 · 2026-11-12 · 2026-11-13 · 2026-11-18 · 2026-11-19 · 2026-11-24 · branch `test/fusion-structure`_

## What it does and where it lives

- `scripts/world_generator.gd` creates `scenes/world/chunk.tscn` on demand; each chunk paints its `Solid` layer and its `Grass` layer with `scripts/world/chunk.gd`.
- `scenes/game.tscn` keeps `solid_map_layer`/`grass_map_layer` with the example patch: they serve as the tile template and the `TileSet` source; new chunks don't reuse their `tile_map_data`.
- Terrain with `FastNoiseLite` 1D Perlin over the global X. `base_height` 60 (scene: 50), amplitude 20, frequency 0.007: soft hills. Measured with the scene values on seeds 12345, 775344231 and 777 (40k tiles): rows 35–65, i.e. 30 tiles of relief at most, and never more than 1 row of step between neighbors.
- Flat start in tiles 0–49 and a 24-tile transition (scene `safe_start_tiles=50`); the player appears at `x=808`, 6 tiles above the ground.

## Terrain tiles

- 3-column atlas: row 0 = surface, row 1 = fill. Row 2 is unused.
- The surface picks left tile `(0,0)`, center `(1,0)` or right `(2,0)` depending on whether the neighbor goes down. It checks the chunk heights and the neighboring chunks' heights (`edge_left`/`edge_right`).
- The `Grass` layer repeats that same column on the surface row, above `Solid`; its `TileSet` comes from `grass_map_layer`.
- The fill goes down to `chunk_height_tiles` (140): there is no floating-map effect.
- Each chunk paints one extra column on the right, identical to the first one of the next: it covers the 1 px crack when joining two `TileMapLayer`s.
- No slopes; steps are 1 tile and are climbed automatically. `max_step_tiles` stays at 1: with 2 there were 2-tile ledges everywhere and Ruben rejected them (T-0050, reverted).
- **Slope limit** (2026-11-12, T-0049): `max_step_tiles` (default 1) caps each column at ±N rows from the previous one while `_build_clamped_heights()` builds the chunk. The chain starts at `base_height` on the left and is cached per chunk: `_clamped_heights` (index 0 = previous column, 1..width = own, width+1 = next chunk's first) is pruned like `_chunk_data`, while `_clamped_last` (one int per chunk) keeps the seed so a chunk can be rebuilt. Chunk 0 and the extra right column reuse the neighbor's height instead of recomputing it, or a different biome modifier would break the seam by 1 px.
- **No biome exaggeration** (2026-11-12, T-0051): the cap alone did not fix the weird spots. The red forest ran ×1.35 amplitude and ×1.1 frequency, steeper than the ±1 cap can follow, so the ground lagged behind the noise and grew 30–40 tile mountains with runs of up to **123 consecutive single steps** (measured). With the red forest at 0.95/1.0 the same seeds give 26 tiles in the worst 300-tile window and runs of 11–14. That is why no biome may push `terrain_amplitude_multiplier` or `terrain_frequency_multiplier` above 1.0: a biome only flattens.

## Screen scale (2026-10-29)

- Viewport 768×432 and window 1536×864 = exactly 2×. With 1280×720 the factor was 1.667 and the pixel-art shimmered when scrolling (nearest-filtered textures change texel size every frame). If you change the window, use integer multiples: 768×432, 1536×864.
- `window/stretch/scale_mode="integer"`: in fullscreen (1920×1080) the content is drawn at exactly 2× (1536×864) centered, with black bands; without this the factor was 2.5 and the shimmering came back. Measured: `screen_scale=(2.0, 2.0)` in windowed and fullscreen.
- `snap_2d_transforms_to_pixel` is still active; with integer scale it doesn't produce shimmering.
- **2026-11-10 (T-0045 → T-0046)**: the Settings panel briefly forced `fractional` to fill the screen; that is what brought the shimmering back (a slight judder in the slowest layer, the mountains), because at 2.5× the nearest texels change size every frame. The fix is not to stretch fractionally at all: the panel keeps `integer` and resizes the **viewport** to `window / factor` (`_apply_layout()`), so the screen fills with more world and each art pixel is a whole `factor` screen pixel. Framing: 1080p → 960×540 at 2×, 1440p → 853×480 at 3×, 4K → 768×432 at 5×; the base 768×432 is the floor, because the UI is built for it.

## Chunks and loading

- Chunks of 256×140 tiles. Loading based on camera + `load_margin_px` 96 and `KEEP_CHUNKS_SIDE` = 2 extra chunks on each side are kept: enemies and coins only disappear when their chunk is 2 chunks behind (they are freed with the node, not before).
- **The camera cannot drag the range** (2026-11-24, T-0089): when the (smoothed) camera center is more than a half view + `load_margin_px` away from the player, `_update_chunks()` uses the player's X. After the dungeon exit or a debug teleport the camera is still at the old spot; without the guard `first` clamped to 0 and one frame generated every chunk in between (measured at 200 000 px: 49 chunks vs 5, 140 ms).
- Before instantiating, the data for the chunk and the next one to the right are generated. When moving away, data and nodes are deleted.
- **Right only** (2026-11-10): `_update_chunks()` clamps `first`/`last` to 0, so no chunk is ever generated left of the start (that was half the world wasted). `_height_at_with()` returns `base_height` for negative tiles, so chunk 0's left edge stays flat, and `_keep_player_inside_world()` cancels the leftward velocity at the last painted column instead of dropping the player into the void.
- **Left wall as a mountain** (2026-11-12, T-0052): the left edge is no longer a flat cut into the void. Chunk 0 paints `left_wall_tiles` (56) extra columns left of tile 0; `WorldChunk.paint()` takes them in `left_heights` and draws them at negative local X (the `TileMapLayer` has no limits). The profile starts at `base_height`, climbs 1 tile per column for `left_wall_climb_tiles` (2, walked up by the auto step-up), then rises `left_wall_step_rows` (4 = 64 px) per column up to `min_height` and stays there: more than the jump (~41 px), so it cannot be scaled and it reads as a mountain. It is not part of the clamped chain, because it is a barrier. Its grass uses the chunk's first column tone. `_keep_player_inside_world()` stops the player at `-(left_wall_tiles - 1) * TILE_SIZE` (the wall's last column); with `left_wall_tiles` 0 it keeps the old `TILE_SIZE` stop.
- Seed: `world_seed` 0 = random; any other value fixes it. Each chunk's RNG uses the seed + coordinate.
- **Seed from the menu (2026-11-10, T-0048)**: New Game asks for it (`Menu/SeedDialog`, empty = random) and the menu stores it in `SaveGame.pending_seed`, which `_ready()` consumes before the noise is built. The debug overlay prints `current_seed()`, so a world can be reproduced by typing that number.

## Biomes (2026-11-01 · block transition 2026-11-05 · runs 2026-11-10)

- `scripts/world/biome.gd` (`class_name Biome`, `Resource`): `display_name`, `grass_color`, `forest_color`, `rock_color`, `ambient`, `spawn_weight`, `min_distance_tiles`, `terrain_amplitude_multiplier`, `terrain_frequency_multiplier`, `enemy_scenes`, `enemy_counts` (same order as the scenes).
- Resources (3): `pradera.tres` (green, 3 orcs + 3 slimes + 1 toad, weight 0.55), `bosque_rojo.tres` (red, 1 wolf + 1 toad, weight 0.3) and `nieve.tres` (blue-white, 2 skeletons + 2 archers + 1 wolf, weight 0.2, unlocked at 4096 tiles). Full reference: [`docs/biomes.md`](biomes.md).
- **Biomes are decided per run, not per block** (2026-11-10, `_biome_index_at_tile()` / `_ensure_biome_runs()`): `_biome_runs` is a cached list of `{start, index, length}` built left to right, and any block resolves to the run containing it. The first run (tile 0) is the safe zone with the first biome; the whole window still blends, so the tint is smooth inside a run.
- **Run length** (shortened 2026-11-13): rolled between `min_biome_tiles` (512 = 2 chunks) and `max_biome_tiles` (2048 = 8 chunks), rounded to `biome_sector_tiles` (0 = one chunk). Before it was 1024–4096 (4–16 chunks): biomes dragged too long. The 256-tile blend is still narrower than the 512-tile shortest run, so two transitions never overlap.
- **Order** (2026-11-10): `_roll_biome_at()` picks among the biomes unlocked at that distance (`Biome.min_distance_tiles`, 0 by default; snow is set to 4096 tiles) and never repeats the previous one. `spawn_weight` only biases the pick, and the noise (`biome_frequency` 0.12 per chunk, sampled at the run start, `biome_contrast` 2) only decides the order: the weights no longer let the meadow swallow the map.
- **Enemies**: they are still per chunk; `_biome_for_chunk()` takes the biome of the central block, so a chunk whose seam falls inside a transition keeps a single enemy set.
- **Block transition**: `biome_transition_tiles` (0 = `chunk_width_tiles`, i.e. 256). Each block uses the moving average of its window's biome colors (±128 blocks), so the change is a gradient over ~256 blocks, not a step at the chunk seam. The seam can fall in the middle of a chunk: logic and color no longer depend on the edges.
- **Terrain per biome**: each `Biome` has `terrain_amplitude_multiplier` and `terrain_frequency_multiplier`, but as of T-0051 they only flatten: meadow 0.95, red forest 0.95 and snow 1.0. The red forest used to be 1.35/1.1 ("more marked relief", T-0024) and that is what made the 30–40 tile mountains with endless single-step ramps, so it now matches the meadow and the biome only changes colors, ambient and enemies. `_chunk_biome_data()` blends both with the same 256-block window as the color. `_height_at_with()` uses the already-blended modifiers and the edges of two chunks match because the blend is done in a fixed order and in float64.

## Grass and tintable forests

- The grass uses `assets/map/tile/grass_tile_gray.png` (gray = max(R,G,B) of the original, alpha intact). The color is set by the draw's `modulate` with the biome's `grass_color`, so any color works (snow: `Color(0.93, 0.96, 1)`).
- `WorldChunk.paint()` receives `grass_tints` (one color per block, 257 per chunk) and `GrassPaint` draws each grass tile with its color; `Solid` (brown ground) is not tinted. `_chunk_biome_data()` computes colors and terrain modifiers with a sliding window, and the `Grass` node disappeared from `chunk.tscn` because a `TileMapLayer` can only be tinted as a whole.
- The background forests use `assets/map/background/pine1_gray.png` / `pine2_gray.png`, with the same gray rule. `WorldGenerator.forest_tint_paths` points to the `Sprite2D`s of `far_forest` and `near_forest`; their `modulate` is updated when changing block with the biome's `forest_color`.
- To add a biome, just create another `.tres` and add it to the generator's `biomes`.

## Tintable backgrounds (2026-11-05)

- The pine layers use `assets/map/background/pine1_gray.png` and `pine2_gray.png`, generated with a Python script: only green/teal pixels (hue 100–210°, saturation ≥ 0.12) become gray; the rest is untouched. **Each layer has its own gray**: far pine 116, near pine 92 (darker) and mountain 172/211 (the lightest). That way the tint doesn't equalize the three backgrounds and the previous depth step is preserved.
- **`Biome.forest_color`** tints only the backgrounds, separate from `grass_color`: the meadow uses `(0.233, 0.388, 0.388)`, which over those grays returns the original tones (far `(27, 45, 45)`, near `(21, 36, 36)`, mountain `(40, 67, 67)` and `(49, 82, 82)`); the red forest uses `(1, 0.32, 0.28)` and keeps the same difference between layers. The grass keeps using `grass_color`.
- The mountain is three layers under `mountains`: `Sprite2D` (stone, `mountain2.png`), `Sprite2DGreen` (`mountain2_gray.png`, only the two forest tones in gray 172/211 and transparency elsewhere) and `Sprite2DSnow` (`mountain2_snow.png`, only the original snow pixels, drawn on top). `forest_tint_paths` tints the forest and `rock_tint_paths` the stone with `rock_color`; snow is never tinted, so it's the same in meadow and red forest and stays white in snow, where the stone turns gray.
- The band under the mountains (`MountainBase`, `ColorRect`) is tinted as well: `WorldGenerator.base_tint_paths` points to it and `_update_biome_tint()` writes its `color` with the biome's `forest_color` darkened `MOUNTAIN_BASE_DARKENING` (0.35), so the meadow reproduces `#283D43` and the red forest/snow move with the rest of the background. It is set through `color`, not `modulate`, so the night multiplier of the `mountains` node keeps working.
- The grass already used the idea (`grass_tile_gray.png`, gray = max(R,G,B)); the backgrounds reuse the recipe with a gray calibrated per layer so the tint recovers each one's original tone and the forest red keeps showing.

## Decor (2026-11-12, T-0057)

- `assets/map/decor/` (2 bushes, 2 trees, 2 rocks) is spawned per chunk by `WorldGenerator`,
  deterministic with the chunk RNG and 2 tiles away from the chunk edges.
- The **biome** decides the amount and the kinds: `decor_per_chunk`, `decor_kinds` and
  `decor_weights` (meadow 32 with ~13 trees, red forest 52 with ~35 trees, snow 24). The
  generator's own arrays are only the fallback.
- Each sprite (`DecorProp`) is the chunk's **first child**, so it is painted behind
  `Solid`/`GrassPaint`; its base rests on the surface row, it has no collision and it is
  not parallaxed. Fixed scale (bushes 1.9, trees 1.8, rocks 1.7), no depth scaling.
- Rocks use `z_index` −1 and draw behind trees and bushes, so they read as background.
- Bushes and the living tree use gray copies and take a weighted `Biome.decor_colors` tint
  (the red forest is mostly red, with some orange and yellow); rocks and the dead tree are
  not tinted. Bushes bend and drop a few leaves when the player walks through them.
  Full reference: [`docs/decor.md`](decor.md).

## Structures (2026-11-18 · 2026-11-24, T-0074/T-0088)

- `scripts/world/structure.gd` (`class_name WorldStructure`, `Resource`): `display_name`,
  optional `scene` (used instead of the texture), `texture`, `pixel_size` (native width,
  0 = texture width), `size_tiles`, `margin_tiles`, `z_index`, `min_distance_tiles`
  and `biomes` (by `Biome.display_name`; empty = all).
- Three kinds of structure, decided by the resource's fields: `scene` (a full scene), `texture` (one sprite) or **`pattern`** (type 2, blocks). The pattern is one string per row from top to bottom, `#` = block; any other character is empty. It repeats horizontally to a random length between `min_length_tiles` and `max_length_tiles` (20–50 for the ruin), and each column rests on **its own** ground row, so the wall follows the terrain.
- **TileSet, not code** (2026-11-19): the pattern is painted by `scripts/world/block_structure.gd`, a `TileMapLayer` using `WorldStructure.tileset` (`resources/world/structures/ruin_tileset.tres`), so the atlas, the tiles and their collision are edited in the TileSet editor like the ground. Two sources: `0` dark atlas = background wall
  (tiles 6/7, no physics; its 0-2 polygons are reserved for reuse), `1` light atlas =
  the solid ground stones. The background is **bricks only**: stone tiles (8-13) are
  reserved for the front layer (kept in the atlas for reuse).
- **Collision only on the ground** (2026-11-24): source `1` paints just the bottom pattern row; the big stone 8 gets a full-square polygon, not just the two lower-half slabs. Two rules, both at ground level so nothing floats: a bottom wall block becomes a stone with `front_chance` (0.25), and an empty bottom column with wall above gets a support beam with `support_chance` (0.6). No collidable block is ever above the first row, so all of them can be jumped over/onto. They are one node in front of the wall (moved to child index 0 so decor draws over it), `z_index` 0; the collision is the TileSet's physics layer (8 and 11 full squares, 9 and 12 lower halves), not a `StaticBody2D` built by code.
- Atlases: `assets/map/structures/ruin_tiles.png` (light) and `ruin_tiles_dark.png` (same layout, darker), 8×2 tiles of 16 px, matte: near-black bricks with teal grout (6 bright, 7 dim) and chunky slate blocks in big/long/small × light/dark, plus the mossy set. 14-15 are the mossy brick tops. `scripts/world/block_structure.gd`: `WALL_TILES` (bricks) with a hash of the cell so a reload picks the same, `TOP_TILES` when the tile above is empty, `STONE_TILES`/`SUPPORT_TILES` for the solid ground layer (the only user of `cell_tiles`; `-1` means "pick from the wall pool"). To retune the look or the hitboxes, edit `ruin_tileset.tres` in Godot: the dark wall tiles 6/7 have no physics, the light source has polygons on 8 (full), 9 (lower half), 11 (full) and 12 (lower half).
- The test resources live in `resources/world/structures/`: `tower_test.tres` (`Test Tower`) is a **scene** structure: it instantiates `scenes/structures/dungeon_entrance.tscn`, the dungeon door, with a 64×64 castle gate (4 tiles) in `tower_test.png`, `ruin_test.tres` is an 8×5 block pattern (`Test Ruin`) and `tent_test.tres` (`Test Tent`) is a 32 px tent sprite that lists `textures` (three tent colors) so each placement picks one at random. The generator preloads all three in `WorldGenerator.structures`. Pattern resources require a `tileset`; `_structure_allowed()` drops a kind that has a pattern but no TileSet instead of instancing a tilemap without physics.
- **The biome decides**: `structure_kinds` (the structures' `display_name`) and
  `structure_chances` (same order). **Each structure rolls on its own per chunk**, so a
  chunk can get none, some or all of them, but never two of the same; a chance of 0 or an
  absent kind means it never appears. Meadow: tower 0.15 / ruin 0.25, red forest: ruin 0.30,
  snow: none.
- Rolled **after** enemies, coins and decor with the same chunk RNG, so their positions
  never shift; a chance is consumed for every kind even when it fails. A chunk's X is tried
  up to 8 times to keep `block_width()` clear of the chunk edges (`margin_tiles`), of the
  other structures (`structure_min_gap_tiles`) and of the enemies' X. Sprites sit on the
  **lowest** column of their span (on a hill they are partly hidden behind `Solid`, but
  never float); patterns use each column's ground.
- **Decor and tint** (2026-11-19): a decor entry whose tile falls inside a structure span (`x ± half`) is dropped, so nothing grows out of a ruin. Each structure gets a `tint` from `_decor_tint_at()` (the biome's `decor_colors`, same as the foliage) and its atlases are recolored with `_tinted_texture(source, tint, 24, 12)`: only pixels clearly greener than red/blue change, so the teal brick grout stays teal and only the moss takes the biome hue. Cached in `_decor_tint_cache`.
- Each one is a chunk child, no parallax. Sprites keep the texture scale from
  `size_tiles`/`pixel_size` and sit on the **lowest** column of their span (on a hill they
  are partly hidden behind `Solid`, but never float); patterns use each column's ground.
  Stable id `s:x:y:index` (node metadata) but **not persisted**:
  nothing destroys structures, so a reload rebuilds the same ones from the seed.
- **Variant textures** (2026-11-24): a sprite structure may list `textures`; `_roll_structures()` stores the pick in the entry and the sprite uses it. The pick is a hash of the global tile, not the chunk RNG, so it stays the same on a rebuild and does not shift enemies, decor or crates. Tents: meadow and red forest, 0.2 each, 4 tiles wide (the 32 px art drawn at ×2, base on the ground row).
- **Footprint** (2026-11-24): `flatten_ground` levels the span (±`half`) to its **highest** column before the chunk is painted, so a slope never buries the sprite; `_level_entities()` moves the enemies and coins inside up with the new surface. `y_offset_px` sinks the sprite (positive = into the ground, applied to its anchor) so the base overlaps the grass line; the tent uses 3 px.
- To add one: create the `.tres`, add it to `WorldGenerator.structures`, name it in a
  biome's `structure_kinds`.

## Breakable blocks (2026-11-24, T-0076)

- `scripts/world/breakable_block.gd` (`BreakableBlock`, `StaticBody2D`) +
  `scenes/world/breakable_block.tscn`: the wooden crate. Origin at its bottom-left, 16×16
  sprite and box, `collision_layer = 5` (world + enemies) so the player's sword hitbox
  (mask 12) reaches it, `collision_mask = 0` so it never pushes anything.
- `WorldGenerator.crate_scene` and `crates_per_ruin` (2): `_crate_tiles()` rolls free
  columns inside each type 2 ruin, on the ground row, skipping the solid front stones,
  the tiles next to them (a crate must not seal a gap), the enemies' X and chunk 0 (the
  spawn). Same chunk RNG as the layout, so a seed rebuilds the same crates.
- `take_damage()` is the entry point the player already uses for non-enemy targets:
  40 HP, so two 20-damage hits; each hit flashes it and puffs dust. Breaking it drops
  1–3 coins (the enemies' `coin.tscn`) and emits `broken(id)`.
- Persistence: stable id `b:chunk_x:chunk_y:tile_x` in `_broken_blocks`, saved as
  `broken` next to `defeated`/`collected`; a broken crate is skipped when the chunk is
  rebuilt. Coins dropped at runtime are not persisted, like the enemies' drops.
- Texture: `assets/map/structures/crate.png`, a 16×16 placeholder. The final art comes
  from PixelForge (T-0086) and only swaps that PNG.

## Ambient per biome (2026-11-05 · 2026-11-25, T-0093)

- `Biome.ambient`: `"none"`, `"leaves"` or `"snow"` (flakes). Meadow has sparse green leaves (density 0.2), red forest has its full autumn rain and snow has flakes.
- `scripts/world/biome_particles.gd` (`biome_particles` node, `CanvasLayer` layer 5 in `game.tscn`) owns two `SpriteFusionAmbient` effects (see `fx.md`); both stay on and decide the weather tile by tile.
- **`ambient_amount_at_world_x(world_x, ambient)`** (2026-11-26, T-0097): raw share 0..1 of the ±`biome_transition_tiles` window that belongs to that ambient. It is the particle quantity; `ambient_density_at_world_x()` blends the biomes' `ambient_density` over the same window, so leaves and snowflakes fade in and out instead of switching at one tile.
- **`ambient_share_at_world_x(world_x, ambient)`**: hard 0/1 at `AMBIENT_SHARE_CUTOFF` (0.8) used by the snow blanket. The cap's edge is extended over flat ground until the surface height changes, so it never ends in the middle of a flat run.
- **`ground_y_at(world_x)`**: already existed for debug travel; the VFX sample it once per 16 px tile every 0.1 s and rest particles on that row, so they land on block steps instead of the screen bottom.
- **World space** (T-0093 round 3): `biome_particles.gd` copies the camera transform into the `CanvasLayer` every frame, and the effects spawn/recycle around the visible world rect. Particles are anchored to the world and scroll with it; the leaf litter is hashed per 18 px world slot and the snow drift is drawn per pixel on the stepped ground line (no diagonal seams); with Enhanced VFX physics the player footprint compresses it and leaves a temporary low trail.
- **Leaves, rounds 5–13; snow round 9** (2026-11-26): 108 leaves at 0.75 px per art pixel (they read too big at 1 px), each one with its own drift direction and speed, spawned and culled ±260 px outside the view. The ground and the biome share are sampled across that margin too, so when running the weather is already falling in the frame that is about to enter instead of popping in. Living trees (`tree`, not `tree_dead`) join the `decor_tree` group: every visible crown takes part, but only about 35 % of normal recycling leaves are born under a crown; the rest fills the open sky. The meadow enables leaves at density 0.2 (green, matching its tree crowns and `ambient_leaf_color`), while the red forest keeps the full autumn rain under its own trees. Round 6: every leaf rolls its tile share once (0..1 is its own probability; a failed roll hides it 5–9 s, one cycle, so the count stays proportional instead of refilling on retries), a teleport re-scatters the new view at random heights with canopy spawning off, instead of dropping all leaves from the top or piling them on the trees. Round 9 (T-0096): initial fill and post-TP scatter skip crowns; normal recycling sends about 35 % under a crown; leaves react to the player/enemies and to sword/enemy hitboxes, the ground litter gains life when touched and every removal dissolves pixel by pixel. Snow keeps 260/150/30 at 1 px and 80 px of cull margin; its drift is per-pixel with a broad-noise 3–7 px cap on the stepped ground line, its hard cover extends over flat ground until a height change, and it compresses under the player with Enhanced VFX physics, leaving a low trail that lasts a few seconds.

## Spawns and persistence

- Per chunk, according to the biome: meadow 3 orcs + 3 slimes + 1 toad, red forest 1 wolf + 1 toad, snow 2 skeletons + 2 archers + 1 wolf (see [`docs/biomes.md`](biomes.md)). `enemy_counts_per_chunk` (`[4 orcs, 2 frogs, 1 wolf, 2 slimes, 2 skeletons, 2 archers]`) remains as a fallback for biomes without `enemy_scenes`. 2 coins per chunk.
- Coins are born `coin_spawn_height` (40 px) above the ground and fall with their own gravity (`scripts/collectables/coin.gd`): they look up the ground once by raycast, bounce with `bounce` 0.4 while the impact exceeds `min_bounce_speed` (40 px/s) and when settling they sway 1 px. Since 2026-11-13 the ray starts 64 px **above** the coin (`GROUND_PROBE_ABOVE`), so a drop born inside the floor finds the surface and pops out instead of staying buried. Before, they appeared already resting (`coin_ground_offset`).
- Density by distance (`_enemy_count_multiplier(chunk_x)`): chunks 0–1 at 50 % (`enemy_ramp_first_multiplier`), and from there +20 % per chunk (`enemy_ramp_per_chunk`) up to ×1.8 (`enemy_ramp_max_multiplier`).
- **Even distribution** (2026-11-03): the list of chunk types is assembled and `enemy_min_x..max_x` is split into one slot per enemy; each one falls in the center of its slot with ±25 % slot noise. Before, each enemy picked its X at random and they clumped.
- **Flyers**: the merge with `feat/biomas` returns them to the biomes (meadow has ghost and red forest demon). `DISABLED_ENEMY_SCENES` remains as an unused reference list.
- 2-tile margins; in chunk 0 enemies start at `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles, ~320 px from the player spawn).
- The enemy collider's bottom rests on the ground (`_body_bottom`), not the origin: enemies are scaled ×2.
- Each spawn has a stable id (`e:x:y:index`, `c:x:y:index`). `EnemyBase` emits `died` and `coin.gd` emits `collected`; the generator stores those ids and doesn't instantiate them again.
- Live enemies that are unloaded respawn; kills and collected coins do not. `current_seed()` and `save_persistent_state()` (defeated/collected ids) feed `SaveGame`, and `_ready()` reads them back before instancing chunks on Continue.

## Auto step-up

- Player and ground enemies climb 1 tile (16 px) at once when reaching a step, using `test_move` on the body's real shape. The player probes the distance it will cover this frame (`max(|vx| * delta, 2) + 1`) and requires 2 px of support below the raised feet; enemies keep their own lookahead (`|vx| * delta`, min 2 px) + 1, because the wolf reaches 300 px/s. They rise before colliding (without losing X) and don't chain two step-ups.
- 2+ tiles are not climbed: you have to jump. It doesn't apply to flying enemies.
- With the enemy increase, a mature chunk puts in 16: if performance drops, lower `enemy_ramp_max_multiplier` or `enemy_counts_per_chunk`.

## Day/night cycle (2026-11-03, expanded)

- `scripts/world/day_night.gd` (`DayNightCycle`), `day_night` node in `scenes/game.tscn`. Day 300 s (5 min) and night 180 s (3 min); total cycle 480 s. It starts at day.
- The sky is the viewport's `RenderingServer.set_default_clear_color`; no `CanvasModulate`, so tiles, sprites and HUD keep their color.
- Default colors: day `Color(0.5098, 0.7882, 0.9922)` (the `default_clear_color` in `project.godot`) and night `Color(0.0431, 0.0627, 0.1647)`. Editable in the inspector.
- `fade_seconds` (12 s) fades the color on each phase change, clamped to half of the shortest phase; set 0 for a hard cut. The same 0→1 factor (`_night_factor_at`) drives the other three effects, so they enter and leave with the sky.
- Stars: `StarField` (inner class) in a `CanvasLayer` with `layer = -1`, below the world; fixed `star_size` px points, fixed seed 20261103, upper limit 90% of the screen. `star_count` 110; its alpha is the night factor.
- Mountains: the `../mountains` node receives `modulate` = white → `mountain_night_tint` (`Color(0.33, 0.36, 0.52)`), noticeably darker at night. The rest of the parallax doesn't change.
- Veil: black `ColorRect` in a `CanvasLayer` with `layer = 11` (above the HUD, which is at 10), alpha `night_veil_alpha` = 0.1 (10%) scaled by the night. `mouse_filter` set to `IGNORE` so it doesn't block clicks.
- All values are `@export`: they are changed from the scene without touching code. The clock is `fmod` over `_process`, so it isn't saved between runs.

## Initial fall and loading screen (2026-11-03, rewritten)

- `scripts/world/fall_intro.gd` (`FallIntro`), `fall_intro` node at the end of `scenes/game.tscn`: it places the player `fall_height_px` (260) above its spawn and lets it fall at `fall_speed` (620 px/s, ~0.4 s) with `player.fall_speed_cap`; control stays disabled until landing (on top of the 6 tiles the generator leaves above the ground).
- The camera **follows the player from the first frame** (`camera_follow_enabled`). The previous parking (`_park_camera`, `follow_after_px`) couldn't work: the `Camera2D` is a child of the player, so parking traveled with it and when hooking the view it jumped ~270 px. No parking and no jolt.
- With 2200 px the intro was 7 s of empty sky: now it's 260 px (~0.4 s) and the ground enters the frame right away. `max_seconds` (3 s) returns control even if the landing gets stuck.
- The intro acts as a **loading screen**: if `WorldGenerator.is_ready_at(x)` (new, checks `_loaded_chunks` of the chunk containing X) said there's no world, the fall stays suspended at 240 px above the ground instead of landing in the void. In practice generation is synchronous in `_ready`, so it's never seen.
- No transition black (removed on 2026-11-03): it goes straight to the sky. On landing control is returned and the `UILayer` is shown (hidden during the fall).
- All values are `@export` in the `fall_intro` node.

## Layers and camera

- 2D layers: 1 world, 2 player, 3 enemies, 4 player attack. Viewport 768×432 (window 1536×864, integer scale).

## Traps

- Anything placed at y=0 ends up outside the camera: the ground is near y=800 (base 50 in the scene).
- If you touch `chunk_width_tiles`, also check `safe_start_tiles`, `load_margin_px` and the spawn arrays.
