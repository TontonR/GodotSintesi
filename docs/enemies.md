# Enemies — `EnemyBase` and the active catalog

_2026-10-20 · 2026-11-01 · 2026-11-10 · 2026-11-12 · 2026-11-13_

## What it does and where it lives

- `scripts/enemies/enemy_base.gd` (`CharacterBody2D`) holds all the shared AI: detection,
  chase/flee, attack, damage, loot and death. Each enemy scene in `scenes/enemies/` has its
  own script with `_init()` stats and only overrides behavior when it differs.
- Scenes are scaled ×2 at the root (`scale = (2, 2)`), so sprite, collider and areas are
  doubled; the slime is the exception at ×1.2. The generator rests the **bottom of the
  collider** on the ground (`_body_bottom()` already multiplies by the scale), not the origin,
  plus `spawn_y_offset` (the ghost rises 6 px because its tail draws below the collider).
- They find the player through the `player` group and only collide with the world
  (`collision_mask` 1): ground enemies walk through each other and cannot be climbed.
  The player walks through them too (2026-11-13: slime, skeleton and archer still had
  mask 3 and got shoved by the player), and crossing a body costs the player a contact
  hit (see `docs/player.md`). Damage travels through `Area2D`, never through bodies.
- AI priority: **flee > attack > chase**. Children override `_update_behavior`,
  `_start_attack`, `_perform_attack` or `_on_death` when needed.

## Base exports (`EnemyBase`)

- Basic: `max_health` 10, `base_attack` 5, `base_defense` 0, `knockback_defense` 0,
  `speed_movement` 50, `attack_cooldown` 2, `step_height` 16, `spawn_y_offset` 0.
- Config: `flying_enemy` (floating motion, no gravity); `ranged_enemy` + `projectile`
  (**not `projectile_scene`**) + `projectile_speed` 200 / `projectile_damage` (−1 = use
  `base_attack`) / `projectile_spawn`; `flee_enemy` + `flee_area`.
- Attack: `attack_impact_delay` 0.5 and `attack_duration` 1.0 (the enemy stands still while
  attacking; the hit lands on impact and the animation finishes before releasing it).
- FX: `blood_color` (default `0.82, 0.11, 0.1`) feeds `fx.enemy_death()`.
- Loot: `coin_drop_chance` 0.45, `coin_drop_amount` 1, `item_drops`
  (`Array[LootEntry]`), `loot_drop_spread` 15, `loot_drop_y` 15. Full rules in
  [`docs/loot.md`](loot.md).
- Difficulty: `health_multiplier` 1.35 and `attack_multiplier` 1.25 are applied in
  `_ready()`, after the children's `_init()` and the scene overrides.
- `take_damage(amount, critical = false)` announces criticals to `fx.enemy_hit()`. Any
  override (skeleton) must repeat that signature and pass `critical` to `super`, or the
  scene won't parse.
- API used by passives: `apply_slow(multiplier, seconds)` and the
  `PlayerPassives.trigger_kill_passives()` notice on death.

## Catalog (stats before the difficulty multipliers)

| Enemy | Scene / script | HP | Damage | Speed | Cooldown | Notes |
|---|---|---|---|---|---|---|
| Orc (ogre) | `orc.tscn` / `orc.gd` | 50 (67.5) | 15 (18.75) | 75 | 2.0 | Melee, hit window 0.66 s, 2.5 s animation |
| Slime | `slime.tscn` / `slime.gd` | 20 (27) | 6 (7.5) | 35 | 1.8 | Smallest: ×1.2 scale |
| Skeleton | `skeleton.tscn` / `skeleton.gd` | 40 (54) | 10 (12.5) | 50 | 2.0 | The first hit it takes deals 0 (flash only) |
| Archer | `archer.tscn` / `archer.gd` | 30 (40.5) | 8 (10) | 55 | 2.2 | Ranged, arrow at 240 px/s |
| Werewolf | `werewolf.tscn` / `werewolf.gd` | 60 (81) | 10 (12.5) | 75 | — | Roams, charges at 140; after 2 charges, a jump ×2; a perfect parry stuns it 0.8 s |
| Mutant toad | `mutant_toad.tscn` / `mutant_toad.gd` | 50 (67.5) | 8 (10) | hop 150 | — | High jumps; every 3 landings fires 3 projectiles |
| Ghost* | `ghost.tscn` / `ghost.gd` | 40 (54) | 5 (6.25) | 85 | 2.0 | Flying, flee, ranged, teleport; **not spawned** |
| Demon* | `demon.tscn` / `demon.gd` | 180 (243) | 5 (6.25) | fly 70 | — | Fire jet, guard stuns it; **not spawned** |

\* Ghost and demon still exist as scenes and scripts but **no biome lists them**, and
`enemy_scenes` no longer includes them: they are unreachable in a normal run (see
`vault/ideas.md`). To bring one back, add its scene to a biome's `enemy_scenes` **and** a
count to that biome's `enemy_counts` (same order).

## Behavior details

- **Orc**: plain melee; its `attack_range` offset is 35 px when the scene doesn't set one.
- **Slime**: plain melee, slow, short cooldown.
- **Skeleton**: melee; `_first_hit_blocked` eats the first `take_damage()` and only flashes.
- **Archer**: `ranged_enemy`; stops inside its (large) attack range and shoots a projectile
  from `Pivot/muzzle`, aiming at the player while detected. No `item_drops`.
- **Werewolf**: wanders around its chunk (radius 400, speed 70), charges when the player is
  in range at 140 px/s (faster than walking, 130; slower than sprinting, 221) with a 0.25 s
  wind-up and 1.5 s recovery; the first hit of each charge knocks the player up
  (`knockup_force` 280, lock 0.12). Every 2 charges the next lap is a jump (`jump_force`
  −350, ×2 damage, 40 px impact radius). The 1.5 s `RECOVER` pause after each pass is
  driven by its own state machine (2026-11-13: the `RECOVER` branch was missing from the
  `match` and the wolf froze on the spot forever after its first charge).
- **Werewolf vs parry** (2026-11-13): a perfect parry of its own hit emits
  `Player.parried(attacker)` and cuts the pass into a `STUN` state of `parry_stun_time`
  (0.8 s) with a bluish flash: it stands still, deals no contact damage and, when the
  stun ends, either charges again or answers with the jump, 50/50 (`stun_jump_chance`,
  forced once through `_stun_next_attack`). Mid-air parries wait for the landing first. It is the only enemy with
  `uses_custom_contact_damage() = true`, so the player's generic body contact no longer
  stacks a second hit on top of its hitbox.
- **Mutant toad**: its own IDLE/JUMP/ATTACK loop; hops with `jump_force` −420 and
  `hop_speed` 150, waits 0.8–1.4 s between jumps and every 3rd landing fires a 3-projectile
  fan (`toad_projectile`, one hit destroys each).
- **Ghost** (disabled): teleports to an elliptical ring between its flee and attack ranges,
  never above the player (`offset.y = minf(offset.y, 0)`), `tp_cooldown` 8 s,
  `tp_min_travel` 80, 12 attempts, invulnerable while teleporting; `charge_time` 0.4.
- **Demon** (disabled): flies `fly_height` 80 above its spawn in 3 s cycles, then a 0.75 s
  warning and a 3 s jet of `demon_fire` that stretches to the ground; blocking the jet with
  the guard stuns it for 5 s or until 3 hits.

## Spawning and density

- The generator picks the biome of the chunk's central block and uses its
  `enemy_scenes`/`enemy_counts`; `enemy_scenes`/`enemy_counts_per_chunk` in
  `world_generator.gd` are only a fallback (4 orc, 2 toad, 1 wolf, 2 slime, 2 skeleton,
  2 archer = 13). Current biome sets are in [`docs/biomes.md`](biomes.md).
- Chunks 0–1 spawn at ×0.5 (`enemy_ramp_first_chunks`), then +20 % per chunk up to ×1.8;
  the count is `floori(base × multiplier)`, so the first two chunks can have none of the
  scarce types.
- Enemies are distributed in equal slots across the chunk width with ±25 % slot noise, and
  chunk 0 starts after `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles from the
  spawn).
- 2-tile margins; each spawn has a stable id (`e:x:y:index`); killed enemies are stored in
  the save and never respawn.

## Traps

- An empty `loot_table` override once left the ghost without drops; `item_drops` is the
  field now, and an empty array simply means "no items".
- A new ranged enemy must assign `projectile` (not `projectile_scene`) and its scene root
  must be a `Node2D` with `setup(direction, speed, damage, shooter)`.
- Clearing `enemy_scenes` while biomes still define theirs changes nothing: the biome wins.
