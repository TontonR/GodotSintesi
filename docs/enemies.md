# Enemies — `EnemyBase`, ghost, orc, wolf, toad and demon

_2026-10-20 · 2026-10-25 · 2026-11-10 · branch `feat/skills-and-complex-passives`_

## What it does and where it lives

- `scripts/enemies/enemy_base.gd` (`CharacterBody2D`) + children `ghost.gd` (flyer, ranged, TP) and `orc.gd` (melee). Scenes in `scenes/enemies/`.
- `orc.tscn` and `ghost.tscn` have `scale = (2, 2)` at the root: sprite, collider and areas doubled. The generator rests the bottom of the collider on the ground (`_body_bottom`), not the origin, plus `spawn_y_offset` (the ghost goes up 6 px because its tail draws below the collider).
- They detect the player through the `player` group.
- Priority-based AI: flee > attack > chase. Children override `_update_behavior`, `_start_attack`, `_perform_attack`, `_on_death`.

## Base exports

- Basic: `max_health` 10, `base_attack` 5, `base_defense`, `knockback_defense`, `speed_movement` 50, `attack_cooldown` 2.
- Config: `flying_enemy`; `step_height` 16 (auto step-up of 1 tile, same criterion as the player: looks ahead and goes up 17 px); `spawn_y_offset` (px it rises when appearing); `ranged_enemy` + `projectile` (**not `projectile_scene`!**) + `projectile_speed` / `projectile_damage` / `projectile_spawn`; `flee_enemy` + `flee_area`.
- Attack: `attack_impact_delay` 0.5, `attack_duration` 1.0.
- FX: `blood_color` (2026-11-10) is the color of its death burst, passed to `fx.enemy_death()`; every layer derives from it. Default is the usual red, so an enemy only changes it if the scene sets it.
- Loot: `_drop_loot()` makes **two rolls**: coins (`coin_drop_chance` 45 %, `coin_drop_amount` 1 or more) and items. For items, `item_drops` adds its `drop_chance` values into a single roll (30 % + 10 % = 40 %) and, if it succeeds, picks one weighted by its probability. Assign the item before `add_child`, parent it and then set `global_position` to respect the chunk transform.
- `take_damage(amount, critical = false)` forwards the critical notice to `fx.enemy_hit()` (T-0031). **Any override** (ghost, skeleton, demon) must repeat that signature and pass `critical` to `super`, or Godot won't parse the scene.
- Luck: `_luck_drop_bonus()` reads `player.luck` and adds `luck × 0.01` to all `drop_chance` values (0 by default, doesn't alter base balance).

## Ghost

- `charge_time` 0.4, `tp_cooldown` 8.0, `tp_zone_margin` 10, `tp_min_travel` 80, `tp_attempts` 12, invulnerable during the TP.
- TP to the elliptical ring between `flee_range` and `attack_range`, never above the player (`offset.y = minf(offset.y, 0.0)`); no `post_attack_tp_delay`.

## Wolf, toad and demon (2026-11-01, branch `feat/biomas`)

- Brought from `origin/feat/enemigos-demon-toad-werewolf` without its generator or its `player.gd`.
- **Wolf** (`werewolf`): 60 health, roams its chunk (`chunk_width_tiles`), charges 40 % of the detection diameter at 150 px/s; every 2 charges the next lap is a jump with double damage. The first hit of each charge launches the player (`knockup`).
- **Toad** (`mutant_toad`): jumps in high arcs; every 3 landings fires a burst of 3 destructible projectiles (`toad_projectile`, one hit is enough).
- **Demon** (`demon`): flies 80 px above the spawn and every 3 s stops above the player to spit fire (`demon_fire`, an area that stretches down to the ground). If the player blocks it, it is stunned for 5 s or until 3 hits.
- These three ask the player for `take_damage_from(..., knockback, knockup)` and `is_guarding()`; see `docs/player.md`.

## Collisions (pass-through)

- The player (`collision_mask` 1) and ground enemies orc/wolf/toad (`collision_mask` 1) only collide with the world: they pass through each other, can't be climbed on or pushed. Damage goes through `Area2D`, not through bodies.
- The ghost and the demon already had mask 0.

## Traps

- An empty `loot_table` override in the scene left the ghost without drops (already removed).

## Difficulty and density (2026-11-03, T-0020)

- `EnemyBase.health_multiplier` 1.35 and `attack_multiplier` 1.25 are applied in `_ready()`
  to `max_health` / `base_attack` (children set their stats in `_init()` and scenes
  can override them, so the adjustment happens last). A single lever for everyone.
- Slime at `scale = Vector2(1.2, 1.2)`; the rest of the imported ones stay at ×2.
- Density: the base is 13 enemies per chunk and `_enemy_count_multiplier()` spreads them
  (6 in chunks 0–1, 16 from the 8th onward).
- Enemies are placed in equal slots across the chunk width with ±25 % slot noise
  (`_generate_chunk`), not with a random X per enemy: that way they don't clump.

## Partner's enemies (2026-11-03, T-0019)

Brought from `origin/feat/enemigos-demon-toad-werewolf` with `git checkout`, without a merge
(the chunked world and camera from `main` are newer than the branch).

- **Demon** (`demon.gd`, `demon_fire.gd`): flies ~80 px above the spawn, FLY cycle 3 s →
  warning → 3 s jet with a `RayCast2D` to the ground; 5 damage every 0.5 s. If the jet is stopped
  with the guard (`player.is_guarding()`) it is stunned.
- **Mutant toad / frog** (`mutant_toad.gd`): its own `IDLE/JUMP/ATTACK` state machine; it jumps and
  every 3 landings fires a burst of 3 destructible projectiles.
- **Wolf** (`werewolf.gd`): roams the area given by the generator (`world_generator` group),
  2 charges + 1 jump; uses
  `player.take_damage_from(..., knockup, knockup_lock, ...)`. Adjusted (T-0035):
  `charge_speed` 150 (less than the player's sprint), `charge_distance_scale` 0.4
  and `attack_recovery` 1.5 s standing at the destination before repeating.
- **Slime** (`slime.gd`), **skeleton** (`skeleton.gd`, first hit free) and
  **archer** (`archer.gd`, `archer_projectile.gd`) are `EnemyBase` with stats in `_init()`.
- Registry: `WorldGenerator.enemy_scenes` / `enemy_counts_per_chunk` in the same order,
  today base `[4 orcs, 2 frogs, 1 wolf, 2 slimes, 2 skeletons, 2 archers]` and scaling
  per chunk (fewer in the first two, more the farther you go).
- **Ghost and demon disabled** (2026-11-03): removed from `enemy_scenes`; they remain
  noted in `WorldGenerator.DISABLED_ENEMY_SCENES` with their scene and script intact.
- `scale = Vector2(2, 2)` at the root of all six (2026-11-03): they appear doubled and
  `_body_bottom()` already multiplies by the scale, so they stay on the ground.
- Spawn: chunk 0 **does** generate enemies, starting at
  `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles, ~300 px from the spawn); before,
  chunk 0 was empty and the nearest enemy was more than half a screen away.
- New API in `EnemyBase`: `apply_slow(multiplier, seconds)`, `on_enemy_killed` notice to
  the player's passives and `item_drops` (`Array[LootEntry]`).
- **Per-enemy loot (2026-11-09)**: each scene defines its own `item_drops`, with one
  `LootEntry` per item (`item`, `drop_chance`, `min_amount`, `max_amount`). Probabilities
  added in a single roll and weighted choice. No shared presets; a new
  variant rebuilds its table. Reference: `vault/pasivas/`.
- The archer has no passives yet (the table was empty): it has no `item_drops`.
