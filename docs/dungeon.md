# Dungeon — explorable structure MVP (type 3)

_2026-11-26 · 2026-11-27 · branch `feat/estructuras-detras-castillo-grande` · T-0079, T-0087, T-0088, T-0093, T-0095, T-0080, T-0100_

## What it does and where it lives

- `scenes/structures/dungeon.tscn` + `scripts/structures/castle/dungeon_generator.gd` (`DungeonGenerator`): one side-view castle hall per floor, built from a seed, independent from the chunked world. It never instantiates nor keeps the player.
- Split: `CastleLayout` (pure data), `CastleTiles` (atlas + collision), `CastlePainter` (layers), `DungeonGenerator` (lifecycle, seed/floor, spawn, exit). `WorldGenerator`, `WorldStructure` and `BlockStructure` stay untouched.
- `DungeonLayer`/`DungeonEntrance` are the world side: door detection, fade, unload/rebuild of the chunks.
- `start(seed, floor)` rebuilds the hall (`seed ^ (floor * 7919)`, never the global RNG); `save_state()` is `{seed, floor}`.
- **Floor count is seed-derived** (3..10): always at least 3 (`min_floors`), then each extra floor up to 10 (`max_floors`) requires an independent 50 % roll in a cascade (floor 4 needs roll1, floor 5 needs roll1 AND roll2, etc.). Same seed → same floor count always. `_compute_floor_count(seed)` uses salt `0xDEAD_F100R` so it doesn't collide with per-floor layout seeds.

## Hall composition

- 64 × 22 tiles of 32 px (`TOP_ROW = 6`, `FLOOR_BOTTOM = 20`), with ceiling visible on screen, windows (`y = 8`) and banners (`x = 11, 26, 41...`, `y = 8`).
- Continuous stepped stone floor (`MIN_BLOCK_TOP = 11` .. `MAX_BLOCK_TOP = 17`, no pits): alternates 1-tile stone steps, gentle descents (1–2 tiles) and 2–3 tile climbs with minimal one-way wooden `Platforms` (`11–14`) placed strictly for ascending.
- Reachability is verified via BFS (`_ensure_reachable()`) from `spawn_cell` to `exit_cell` within the player's jump limits (1 tile / 32 px up, ≤ 2 tiles across).
- `CastlePainter._paint_solid_grid()` builds a boolean `solid[x, y]` grid (frame + floor blocks) and autotiles every cell from its 8 neighbors using `SOLID_FILL` (`25`, `#423a51`), borders `20/24/19/22`, outer corners `18/21/26/23` and inner corners `28/29/27/30`.
- `Back` paints stone `41` inside the frame; outside shows `DungeonVoid` (`Polygon2D`, z = -5, `#423a51`), above world parallax (z = -100) and below `Back` (z = -4).
- `Walls` is solid (full-square collision on layer 1). `Platforms` is one-way (top 10 px only). `Back`/`Decor` are physics-free.
- **Two black doors, F to use them** (2026-11-27, T-0100): the pad at the end of the hall (`Exit` in `dungeon.tscn`) climbs one floor and on the **top floor** emits `exit_requested` and returns to the world; the new `Leave` pad sits `LEAVE_GAP_TILES` (4) tiles behind the spawn, clamped to tile 2 so it is always on floor. Both are black `Polygon2D` rectangles of 32×64 px at `z = -1` (behind the player) and **nothing is automatic any more**: they only carry a position, and `DungeonGenerator._unhandled_input` reads the `interact` action when the player is within `INTERACT_RADIUS_PX` (56 px) of the closest one. Climbing emits `floor_changed(floor)` — the hall is already rebuilt, so `DungeonLayer` fades, teleports to the new `spawn_point` and fades back in.
- **Prompt**: `F: enter` over the stairs, `F: exit` over the door behind the spawn (and over the stairs on the top floor, where they are the way out). Own `CanvasLayer` (`PadPrompt`, layer 8, same style as the world door prompt); `DungeonLayer` hides its own while inside. `INTERACT_LOCK_SECONDS` (0.35 s) ignores F right after a rebuild, so the press that entered cannot leave and one climb cannot chain two floors.
- **Contents per floor** (2026-11-27, T-0100): `crates_per_floor` (3), `coins_per_floor` (6) and `archers_per_floor` (3) are rolled with `seed ^ (floor * 7919) ^ 0x00C0FFEE` over the free columns — never within 3 tiles of the spawn nor 2 of the stairs — under a `Contents` node emptied on every `start()`. Crates are the ruins' `BreakableBlock` at ×2 (32 px, the atlas scale) and drop coins/consumables; coins are the world's `coin.tscn`, born 40 px above the floor so their own raycast settles them (dungeon tiles are on physics layer 1); archers are `archer.tscn`, rested on the floor with the same body-bottom helper `WorldGenerator` uses. Everything is rebuilt per floor, so nothing carries between floors or survives leaving.

## Save and load (T-0080)

- Saving inside writes `[dungeon] state` = `{seed, floor, position, world_position}` and keeps `run/position` and `run/meters` in **world** space, so Continue restores the floor and the spot and the exit pad returns to the door.
- `game.gd` calls `DungeonLayer.restore_from_save()` after `refresh_chunks()`. Saves without the section load in the world as before.
- A door always starts on floor 0; only a loaded save restores another floor.

## F6 (manual, pending for Ruben)

- Open `scenes/structures/dungeon_test.tscn` and press F6: the player lands on `spawn_point`, keys 1/2 regenerate floor 0/1, F on the black pad at the end of the hall climbs (`Dungeon: climbed to floor N.`) and on the top floor prints `Dungeon: exit requested on floor N.` The scene needs its own `UILayer`, or the player fails to create one mid-setup.
- In game: walk to the tower, press F within 64 px, and the exit pad returns to the same world spot. The world door is now a 64×64 castle gate (`tower_test.png`) drawn at ×2 (128 px, 8 tiles), with its base on the ground and behind the player. KP3 lands on the next structure or door.

## Decisions and traps

- No partitions or interior doors: one open hall. The world door is external and handled by `DungeonLayer`.
- Atlas groups are not interchangeable: top = windows/banners/wood, middle = borders/corners, bottom = stone. Do not paint void tile `25`, do not cut out or replace the purple, and do not give `Platforms` full collision.
- `start()` is the floor switch: it clears `Platforms`, `Walls`, `Back` and `Decor`.
- The chunks must be gone before the dungeon appears: `unload_chunks()` frees them; `process_mode = DISABLED` only pauses the generator.
- The `Exit`/`Leave` pads are 32×64 px; a 16×32 pad keeps the old proportions. Their `Area2D`s are only anchors now: no `body_entered`, the distance check is in the generator.

## Fixed door columns and stone dust (2026-11-27, T-0102)

- `CastleLayout` now pins both doors to fixed columns: entry on tile `ENTRY_COLUMN` (4) and
  exit at `hall_width - EXIT_MARGIN` (5 from the right frame), with the Y read from the block
  that covers each column (`_top_at()`). Every floor has its doors on the same X, so the
  castle stacks vertically instead of drifting with the random block widths.
- The walk dust inside is stone grey: `DungeonLayer` sets `fx.dust_color` on the way in and
  clears it on the way out, so `Fx.dust()` stops sampling the biome grass under the castle
  (there is no biome there).
