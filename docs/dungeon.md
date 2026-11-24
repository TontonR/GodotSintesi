# Dungeon — explorable structure MVP (type 3)

_2026-11-24 · branch `feat/estructura-explorable` · T-0079_

## What it does and where it lives

- `scenes/structures/dungeon.tscn` + `scripts/world/dungeon_generator.gd` (`DungeonGenerator`): a side-view room-and-door dungeon generated from a seed, independent from the chunked world. It never instantiates nor keeps the player.
- Two floors (`rooms_per_floor` = [7, 9]): `start(seed, floor)` regenerates; the same pair paints the same layout (`RandomNumberGenerator` seeded with `seed ^ (floor * 7919)`, never the global `randi()`).
- `_build_rooms()` splits the width (150 tiles) into seeded room widths (8–22; narrow ones read as corridors). Every room after the first starts with a partition wall that has a 6-tile doorway, so the floor is one connected hall.
- Layout in rows: a 3-row floor band, a 2-row ceiling band, side walls and a dark `Back` fill out to `MARGIN_TILES` 40, so the camera never shows the sky and there is no pit to fall into.
- Placeholders from `assets/map/tile/ground_tile.png` (fill row): `Floor` and `Walls` share a code-built solid `TileSet` (full-square physics on layer 1); only `Back` is physics-free, tinted darker.
- `spawn_point` sits 30 px above the first room (the player's origin is ~27 px above its feet); the `Exit` (`Area2D` + amber `Polygon2D`) sits in the last room and emits `exit_requested` once per `start()`.
- `save_state()` / `load_state(state)` are pure (`{seed, floor}`); `scripts/save_game.gd` is untouched.

## F6 (manual, pending for Ruben)

- Open `scenes/structures/dungeon_test.tscn` and press F6: the player lands on `spawn_point`, keys 1/2 regenerate floor 0/1, and stepping on the amber pad prints `Dungeon: exit requested on floor N.`
- Reloading the same seed + floor must repaint the same layout.

## Decisions and traps

- The dungeon owns no player, camera or HUD: `dungeon_test.tscn` only places `player.tscn` and resets camera smoothing. The world door is still pending (child + hidden world, or `change_scene` + autoload).
- `start()` is also the floor switch: it clears and repaints the three layers, so calling it again is safe.
- Walls must stay above the jump (~41 px): doorway clearance is 6 tiles and the ceiling is 12 rows up; a 1-tile wall would be jumped over. Changing the player collider breaks `SPAWN_ABOVE_PX` (~27 px).
- The floor is a single row (no elevation changes yet), so floors differ in room widths and door placement, not height.
