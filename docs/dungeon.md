# Dungeon — explorable structure MVP (type 3)

_2026-11-24 · branch `test/fusion-structure` · T-0079, T-0087, T-0088_

## What it does and where it lives

- `scenes/structures/dungeon.tscn` + `scripts/world/dungeon_generator.gd` (`DungeonGenerator`): a side-view room-and-door dungeon generated from a seed, independent from the chunked world. It never instantiates nor keeps the player.
- Two floors (`rooms_per_floor` = [7, 9]): `start(seed, floor)` regenerates; the same pair paints the same layout (`RandomNumberGenerator` seeded with `seed ^ (floor * 7919)`, never the global `randi()`).
- `_build_rooms()` splits the width (150 tiles) into seeded room widths (8–22; narrow ones read as corridors). Every room after the first starts with a partition wall that has a 6-tile doorway, so the floor is one connected hall.
- Art is the same ruin atlas as the chunk structures (`assets/map/structures/ruin_tiles_dark.png` + `ruin_tiles.png`, 8x2 tiles): dark brick variants (6/7) for the `Back` wall, ceiling, side walls and partitions; light stone variants (8/11/3) for the walkable floor, with darker stone fill below. `Back` is physics-free and darkened; `Walls`/`Floor` share a code-built TileSet with full-square physics on layer 1.
- `spawn_point` sits 30 px above the first room (the player's origin is ~27 px above its feet); the amber `Exit` (`Area2D`) sits in the last room and emits `exit_requested` once per `start()`.
- `WorldGenerator` adds `scenes/structures/dungeon_entrance.tscn` (48x96 black placeholder, `Area2D` and "F: enter" hint): one always at `safe_start_tiles + first_dungeon_entrance_offset_tiles` in chunk 0, and one per later chunk with `dungeon_entrance_chance` (0.2).
- `DungeonLayer` (`scenes/game.tscn`) hides and pauses `map`, adds `dungeon.tscn` and teleports the player to `spawn_point`; `exit_requested` restores the world position. Health, coins, inventory and seed survive because there is no scene change.
- `save_state()` / `load_state(state)` are pure (`{seed, floor}`); `scripts/save_game.gd` is untouched.

## F6 (manual, pending for Ruben)

- Open `scenes/structures/dungeon_test.tscn` and press F6: the player lands on `spawn_point`, keys 1/2 regenerate floor 0/1, and the amber pad prints `Dungeon: exit requested on floor N.`
- In game: walk to the black door right of the spawn (tile 58) and press F; the exit pad returns to the same world spot.

## Decisions and traps

- The dungeon owns no player, camera or HUD: `DungeonLayer` only hides/pauses the world and teleports; the entrance scene is the only world-side piece.
- `start()` is also the floor switch: it clears and repaints the three layers, so calling it again is safe.
- Walls must stay above the jump (~41 px): doorway clearance is 6 tiles and the ceiling is 12 rows up; a 1-tile wall would be jumped over. Changing the player collider breaks `SPAWN_ABOVE_PX` (~27 px).
- The floor is a single row (no elevation changes yet), so floors differ in room widths and door placement, not height.
- Saving inside the dungeon still stores dungeon coordinates; per-floor persistence is T-0080.
