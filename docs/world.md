# World — procedural chunk generation

_2026-10-23 · 2026-10-25 · 2026-11-05 · 2026-11-10 · 2026-11-12 · branch `main`_

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
- Before instantiating, the data for the chunk and the next one to the right are generated. When moving away, data and nodes are deleted.
- **Right only** (2026-11-10): `_update_chunks()` clamps `first`/`last` to 0, so no chunk is ever generated left of the start (that was half the world wasted). `_height_at_with()` returns `base_height` for negative tiles, so chunk 0's left edge stays flat, and `_keep_player_inside_world()` cancels the leftward velocity at the last painted column instead of dropping the player into the void.
- **Left wall as a mountain** (2026-11-12, T-0052): the left edge is no longer a flat cut into the void. Chunk 0 paints `left_wall_tiles` (56) extra columns left of tile 0; `WorldChunk.paint()` takes them in `left_heights` and draws them at negative local X (the `TileMapLayer` has no limits). The profile starts at `base_height`, climbs 1 tile per column for `left_wall_climb_tiles` (2, walked up by the auto step-up), then rises `left_wall_step_rows` (4 = 64 px) per column up to `min_height` and stays there: more than the jump (~41 px), so it cannot be scaled and it reads as a mountain. It is not part of the clamped chain, because it is a barrier. Its grass uses the chunk's first column tone. `_keep_player_inside_world()` stops the player at `-(left_wall_tiles - 1) * TILE_SIZE` (the wall's last column); with `left_wall_tiles` 0 it keeps the old `TILE_SIZE` stop.
- Seed: `world_seed` 0 = random; any other value fixes it. Each chunk's RNG uses the seed + coordinate.
- **Seed from the menu (2026-11-10, T-0048)**: New Game asks for it (`Menu/SeedDialog`, empty = random) and the menu stores it in `SaveGame.pending_seed`, which `_ready()` consumes before the noise is built. The debug overlay prints `current_seed()`, so a world can be reproduced by typing that number.

## Biomes (2026-11-01 · block transition 2026-11-05 · runs 2026-11-10)

- `scripts/world/biome.gd` (`class_name Biome`, `Resource`): `display_name`, `grass_color`, `forest_color`, `rock_color`, `ambient`, `spawn_weight`, `min_distance_tiles`, `terrain_amplitude_multiplier`, `terrain_frequency_multiplier`, `enemy_scenes`, `enemy_counts` (same order as the scenes).
- Resources (3): `pradera.tres` (green, 3 orcs + 3 slimes + 1 toad, weight 0.55), `bosque_rojo.tres` (red, 1 wolf + 1 toad, weight 0.3) and `nieve.tres` (blue-white, 2 skeletons + 2 archers + 1 wolf, weight 0.2, unlocked at 4096 tiles). Full reference: [`docs/biomes.md`](biomes.md).
- **Biomes are decided per run, not per block** (2026-11-10, `_biome_index_at_tile()` / `_ensure_biome_runs()`): `_biome_runs` is a cached list of `{start, index, length}` built left to right, and any block resolves to the run containing it. The first run (tile 0) is the safe zone with the first biome; the whole window still blends, so the tint is smooth inside a run.
- **Run length**: rolled between `min_biome_tiles` (1024 = 4 chunks) and `max_biome_tiles` (4096 = 16 chunks), rounded to `biome_sector_tiles` (0 = one chunk). This is what kills the micro-biomes (a red forest squeezed inside one transition) and the giga-biomes: no biome lasts under 4 or over 16 chunks. The 256-tile color/terrain blend is narrower than the shortest run, so two transitions can never overlap.
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

## Ambient per biome (2026-11-05)

- `Biome.ambient`: `"none"`, `"leaves"` (red leaves) or `"snow"` (flakes). Red forest has leaves, snow has flakes and meadow nothing.
- `scripts/world/biome_particles.gd` (`biome_particles` node, `CanvasLayer` layer 5 in `game.tscn`) creates two full-screen `CPUParticles2D` with pixel textures generated in code. Every 0.25 s it asks `WorldGenerator.biome_at_world_x()` at the player's X and turns on the emitter for the biome's `ambient`; when turning it off, live particles finish their lifetime.
- Horizontal coverage (2026-11-05): the emission rectangle measures `view.x × 1.2` on each side of the center (before `0.6`), i.e. twice as wide, and there are twice as many particles (56 leaves, 440 flakes). That way the sideways wind doesn't reveal empty areas at the edges.
- Leaves: 56 particles, slow fall with rotation. Snow: 440 flakes, even slower fall. When the emitter activates the screen is already full (`preprocess`), and it enters/leaves with a 0.4 s fade and sideways wind.

## Spawns and persistence

- Per chunk, according to the biome: meadow 3 orcs + 3 slimes + 1 toad, red forest 1 wolf + 1 toad, snow 2 skeletons + 2 archers + 1 wolf (see [`docs/biomes.md`](biomes.md)). `enemy_counts_per_chunk` (`[4 orcs, 2 frogs, 1 wolf, 2 slimes, 2 skeletons, 2 archers]`) remains as a fallback for biomes without `enemy_scenes`. 2 coins per chunk.
- Coins are born `coin_spawn_height` (40 px) above the ground and fall with their own gravity (`scripts/collectables/coin.gd`): they look up the ground once by raycast, bounce with `bounce` 0.4 while the impact exceeds `min_bounce_speed` (40 px/s) and when settling they sway 1 px. Before, they appeared already resting (`coin_ground_offset`).
- Density by distance (`_enemy_count_multiplier(chunk_x)`): chunks 0–1 at 50 % (`enemy_ramp_first_multiplier`), and from there +20 % per chunk (`enemy_ramp_per_chunk`) up to ×1.8 (`enemy_ramp_max_multiplier`).
- **Even distribution** (2026-11-03): the list of chunk types is assembled and `enemy_min_x..max_x` is split into one slot per enemy; each one falls in the center of its slot with ±25 % slot noise. Before, each enemy picked its X at random and they clumped.
- **Flyers**: the merge with `feat/biomas` returns them to the biomes (meadow has ghost and red forest demon). `DISABLED_ENEMY_SCENES` remains as an unused reference list.
- 2-tile margins; in chunk 0 enemies start at `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles, ~320 px from the player spawn).
- The enemy collider's bottom rests on the ground (`_body_bottom`), not the origin: enemies are scaled ×2.
- Each spawn has a stable id (`e:x:y:index`, `c:x:y:index`). `EnemyBase` emits `died` and `coin.gd` emits `collected`; the generator stores those ids and doesn't instantiate them again.
- Live enemies that are unloaded respawn; kills and collected coins do not. `current_seed()` and `save_persistent_state()` (defeated/collected ids) feed `SaveGame`, and `_ready()` reads them back before instancing chunks on Continue.

## Auto step-up

- Player and ground enemies climb 1 tile (16 px) at once when reaching a step, using `test_move` on the body's real shape. The player tests 1 px ahead; enemies test how far they advance in the frame (`|vx| * delta`, min 2 px) + 1, because the wolf reaches 300 px/s. They go up 17 px: they rise before colliding (without losing X) and don't chain two step-ups.
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
