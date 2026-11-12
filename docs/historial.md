# History — bugs that already bit us

_2026-10-20 · branch `feat/skills-and-complex-passives`_

Do not load unless something smells like this. What's current lives in its system doc.

## Drops and inventory

- **2026-10-15 · infinite flicker**: the ground ray was cast every frame; with `v < 35 px/s` it didn't reach the ground, the minimum bounce was unreachable and it entered a micro-loop at ~7 Hz. Fix: look up the ground once (`_ground_y`) and compare against a fixed height.
- **2026-10-14 · drops "that don't spawn"**: they were at y=0 and the ground is at y=400. Gravity corrects it; the legacy `coin` in `game.tscn` is still wrong.
- **2026-10-14 · healing passive**: removed (`heal_potion_passive.tres`, `HealPassive.gd`); git keeps it.
- **2026-10-14 · `Skills.gd`**: `EquipSlot { NONE = 0 }` was needed for the export to compile.

## Enemies

- **2026-10-14 · ghost without loot**: `ghost.tscn` had a `loot_table` override with an empty entry; removed.

## HUD and world

- **2026-11-12 · coins over the stats**: `UILayer/coins` used full-screen anchors with centered text. At 768×432 it looked right, but the adaptive fullscreen viewport moved it down over `StatsPanel`. Fix: fixed rect (26, 26)–(120, 42) plus a 16×16 `coin_icon` (T-0055).
- **2026-11-12 · 30–40 tile mountains and 123-step ramps**: the red forest ran terrain noise ×1.35 amplitude / ×1.1 frequency while the ±1 column cap tried to follow it, so the ground lagged behind the noise. Fix: no biome above ×1.0 (T-0051).
- **2026-11-09 · drops at twice the distance**: a pickup positioned before being parented inherited the chunk transform twice. Fix: parent first, then `global_position` (`EnemyBase._spawn_pickup`).
