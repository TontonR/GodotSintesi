# Dungeon — explorable structure MVP (type 3)

_2026-11-25 · branch `test/fusion-structure` · T-0079, T-0087, T-0088, T-0093, T-0080_

## What it does and where it lives

- `scenes/structures/dungeon.tscn` + `scripts/structures/castle/dungeon_generator.gd` (`DungeonGenerator`): one side-view castle hall per floor, built from a seed, independent from the chunked world. It never instantiates nor keeps the player.
- Split: `CastleLayout` (pure data), `CastleTiles` (atlas + collision), `CastlePainter` (layers), `DungeonGenerator` (lifecycle, seed/floor, spawn, exit). `WorldGenerator`, `WorldStructure` and `BlockStructure` stay untouched.
- `DungeonLayer`/`DungeonEntrance` are the world side: door detection, fade, unload/rebuild of the chunks.
- Two floors (`floors` = 2): `start(seed, floor)` rebuilds the hall (`seed ^ (floor * 7919)`, never the global RNG); `save_state()` is `{seed, floor}`.

## Hall composition

- 64 × 22 tiles of 32 px (`TOP_ROW = 6`, `FLOOR_BOTTOM = 20`), with ceiling visible on screen, windows (`y = 8`) and banners (`x = 11, 26, 41...`, `y = 8`).
- Continuous stepped stone floor (`MIN_BLOCK_TOP = 11` .. `MAX_BLOCK_TOP = 17`, no pits): alternates 1-tile stone steps, gentle descents (1–2 tiles) and 2–3 tile climbs with minimal one-way wooden `Platforms` (`11–14`) placed strictly for ascending.
- Reachability is verified via BFS (`_ensure_reachable()`) from `spawn_cell` to `exit_cell` within the player's jump limits (1 tile / 32 px up, ≤ 2 tiles across).
- `CastlePainter._paint_solid_grid()` builds a boolean `solid[x, y]` grid (frame + floor blocks) and autotiles every cell from its 8 neighbors using `SOLID_FILL` (`25`, `#423a51`), borders `20/24/19/22`, outer corners `18/21/26/23` and inner corners `28/29/27/30`.
- `Back` paints stone `41` inside the frame; outside shows `DungeonVoid` (`Polygon2D`, z = -5, `#423a51`), above world parallax (z = -100) and below `Back` (z = -4).
- `Walls` is solid (full-square collision on layer 1). `Platforms` is one-way (top 10 px only). `Back`/`Decor` are physics-free.
- `DungeonGenerator._on_exit_body_entered()` emits `exit_requested.emit.call_deferred()` so world chunk/physics rebuilds run outside the `Area2D` physics query flush.

## Save and load (T-0080)

- Saving inside writes `[dungeon] state` = `{seed, floor, position, world_position}` and keeps `run/position` and `run/meters` in **world** space, so Continue restores the floor and the spot and the exit pad returns to the door.
- `game.gd` calls `DungeonLayer.restore_from_save()` after `refresh_chunks()`. Saves without the section load in the world as before.
- A door always starts on floor 0; only a loaded save restores another floor.

## F6 (manual, pending for Ruben)

- Open `scenes/structures/dungeon_test.tscn` and press F6: the player lands on `spawn_point`, keys 1/2 regenerate floor 0/1 and the amber pad prints `Dungeon: exit requested on floor N.` The scene needs its own `UILayer`, or the player fails to create one mid-setup.
- In game: walk to the tower, press F within 64 px, and the exit pad returns to the same world spot. KP3 lands on the next structure or door.

## Decisions and traps

- No partitions or interior doors: one open hall. The world door is external and handled by `DungeonLayer`.
- Atlas groups are not interchangeable: top = windows/banners/wood, middle = borders/corners, bottom = stone. Do not paint void tile `25`, do not cut out or replace the purple, and do not give `Platforms` full collision.
- `start()` is the floor switch: it clears `Platforms`, `Walls`, `Back` and `Decor`.
- The chunks must be gone before the dungeon appears: `unload_chunks()` frees them; `process_mode = DISABLED` only pauses the generator.
- The `Exit` pad is 32×64 px; a 16×32 pad keeps the old proportions.
