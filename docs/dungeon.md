# Dungeon — explorable structure MVP (type 3)

_2026-11-24 · branch `test/fusion-structure` · T-0079, T-0087, T-0088_

## What it does and where it lives

- `scenes/structures/dungeon.tscn` + `scripts/world/dungeon_generator.gd` (`DungeonGenerator`): a side-view room-and-door dungeon generated from a seed, independent from the chunked world. It never instantiates nor keeps the player.
- Two floors (`rooms_per_floor` = [7, 9]): `start(seed, floor)` regenerates; the same pair paints the same layout (`RandomNumberGenerator` seeded with `seed ^ (floor * 7919)`, never the global `randi()`).
- `_build_rooms()` splits the width (75 tiles of 32 px = 2400 px, the old 150 × 16 span) into seeded room widths (4–11; narrow ones read as corridors). Every room after the first starts with a partition wall that has a 6-tile doorway, so the floor is one connected hall.
- **Castle pack art** (2026-11-24, T-0090): `assets/map/structures/castle_tiles.png`, an 8×6 atlas of 32 px tiles taken from the `map.zip` the user delivered. `TILE_SIZE` is 32, so the old proportions hold (the player is ~54 px). Rows of the atlas: 0 windows, 1 banners, 2-3 orange brick wall, 4-5 stone slabs. `Back` paints stone (31, 32-35, 40-43) darkened by the node; `Walls` and the ceiling use brick (20 capped top, 25/26/30 body); `Floor` uses stone (32-37) with fill (40-43). `Back` and `Decor` are physics-free; `Walls`/`Floor` share a code-built TileSet with full-square physics on layer 1.
- `Decor` (`TileMapLayer`, z −3, no collision) scatters 2×2 windows (`WINDOW_VARIANTS`, atlas row 0) and 1×3 banners (8-10, row 1) on the backdrop wall: one seeded roll per room (`window_chance` 0.6, `banner_chance` 0.35) and `_decor_free()` stops them from overlapping. The same RNG as the rooms, rolled after them, so widths never change.
- `spawn_point` sits 30 px above the first room (the player's origin is ~27 px above its feet); the amber `Exit` (`Area2D`) sits in the last room and emits `exit_requested` once per `start()`.
- **The door is a structure like any other** (2026-11-24): `tower_test.tres` (`Test Tower`) sets `scene = scenes/structures/dungeon_entrance.tscn`, so the normal structure roll places it with the chunk, its margins, `structure_min_gap_tiles`, enemy/structure avoidance, `z_index` and `y_offset_px`. It counts in `structures` for KP3 (`next_structure_x`) without any special case. The only extra is that the scene is a `DungeonEntrance`, so `DungeonLayer` can find it in the `dungeon_entrance` group and enter it with F. Both biomes list it at 100 % (one tower per chunk), so there is always a door ahead; tune `structure_chances` to change that.
- `DungeonLayer` (`scenes/game.tscn`) loads `dungeon.tscn` as its own scene at the origin while the chunked world is unloaded: `WorldGenerator.unload_chunks()` removes and frees every chunk (the run data stays), the generator is disabled and the biome particles/meters are hidden. On `exit_requested` the dungeon is freed, the world is rebuilt with `refresh_chunks()` and the player returns to the stored spot. The player, HUD and run are never freed, so health, coins, inventory, passives and the seed survive. A black `ColorRect` (CanvasLayer 200) snaps to opaque on the swap frame and fades back over `fade_seconds` (0.25); the swap itself is synchronous, so a cancelled tween can never lock the door. The dungeon is created again on every entry, so it always starts on floor 0.
- `save_state()` / `load_state(state)` are pure (`{seed, floor}`); `scripts/save_game.gd` is untouched.

## F6 (manual, pending for Ruben)

- Open `scenes/structures/dungeon_test.tscn` and press F6: the player lands on `spawn_point`, keys 1/2 regenerate floor 0/1, and the amber pad prints `Dungeon: exit requested on floor N.`
- In game: walk right to the door at tile 23 (the prompt appears within 64 px), press F, and the exit pad returns to the same world spot. KP3 lands on the next structure or door.

## Decisions and traps

- **The door is a passive marker**: `DungeonEntrance` only joins the `dungeon_entrance` group and stores its seed (0 derives one from its world position, deterministic for the seed); it has no `Area2D`, no hint and no per-frame code. `DungeonLayer` searches that group every frame, picks the closest door within `door_radius_px` (96, to the player origin), draws the "F: enter" prompt in its own CanvasLayer at the door's screen position and reads F itself. That survives chunk rebuilds, scene loads, `refresh_chunks`, KP6/KP4 teleports and camera jumps, because nothing depends on the door's node processing. `enter()` also self-heals a leftover dungeon when the world chunks are loaded.
- The dungeon owns no player, camera or HUD: `DungeonLayer` unloads the world and teleports the existing player (`debug_teleport` also cuts the camera lag). The entrance scene is the only world-side piece. A full `change_scene_to_file()` would free the player, HUD, inventory and passives, so the swap is done inside `game.tscn`.
- The chunks have to be gone before the dungeon is placed: `unload_chunks()` does `remove_child()` + `queue_free()`, so the world collision ends this same frame. `process_mode = DISABLED` only pauses the generator, not its tilemaps.
- `start()` is also the floor switch: it clears and repaints the three layers, so calling it again is safe.
- Walls must stay above the jump (~41 px): doorway clearance is 4 tiles (128 px) and the ceiling is 6 rows up (192 px); a 1-tile wall would be jumped over. `_door_height()` clamps to 2..interior−2 tiles. Changing the player collider breaks `SPAWN_ABOVE_PX` (~27 px).
- The floor is a single row (no elevation changes yet), so floors differ in room widths and door placement, not height.
- Saving inside the dungeon still stores dungeon coordinates; per-floor persistence is T-0080.
- Leaving and coming back starts at floor 0: the dungeon scene is unloaded and recreated (no dungeon progress is kept yet).
- **Exit cost** (2026-11-24, T-0089): `refresh_chunks()` no longer trusts the smoothed camera. After the teleport back the camera is still at the dungeon while the player is far away; without the guard in `WorldGenerator._update_chunks()` `first` clamped to 0 and one frame built every chunk from the start (measured at 200 000 px: 49 chunks vs 5, 140 ms).
- The dungeon's `Exit` pad is 32×64 px (shape and `Visual` polygon in `dungeon.tscn`); a 16×32 pad leaves the old proportions behind.
