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
