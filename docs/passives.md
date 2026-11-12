# Passives — `PlayerPassives` and catalog

_2026-10-20 · 2026-11-03 · 2026-11-09 · 2026-11-12_

## What it does and where it lives

- `scripts/collectables/passive_items.gd` (`class_name PassiveItems`, extends `Collectable`)
  is the base of every passive; `scripts/collectables/player_passive.gd`
  (`class_name PlayerPassives`, `Node` child of the player) stores the equipped ones.
- A passive is a `Resource` in `resources/*.tres` with `passive_id`, `item_name`,
  `description`, `icon`, `quality` (`Normal` / `Rare`) and its own effect fields.
- Collectables **do not take inventory slots**: touching the pickup calls
  `on_pickup()` → `PlayerPassives.add_passive()`. Duplicates are refused by instance,
  `resource_path` or `passive_id`, so an enemy never drops one the player already has
  (`EnemyBase._available_drops()` also filters them out of the roll).
- No skills and no skill slots exist anymore.

## Hooks

`PlayerPassives` iterates `active_passives` in order and calls:

| Hook | When |
|---|---|
| `on_equip(player)` / `on_unequip(player)` | Added / removed |
| `on_player_attack(target, damage) -> float` | Damage pipeline; each passive returns the modified value |
| `on_player_take_damage(amount, attacker) -> float` | Incoming damage pipeline |
| `on_player_attack_started(player, step, direction)` | Start of each attack (`step` 1–3 of the combo) |
| `on_player_blocked(player)` | A frontal hit is blocked by the guard |
| `on_enemy_killed(player, enemy)` | Any enemy death |
| `on_update(player, delta)` | Every frame, for timers/regeneration |

`trigger_*` wrappers exist for each event; `signals passives_changed` refreshes
`UILayer/PassiveBar` and the inventory screen. Maxima changes (`bonus_max_health`,
`bonus_max_stamina`) happen at equip, so health is not healed unless the passive says so.

## Catalog (35 passives + 1 shared consumable)

Each enemy's table lives in its scene (`item_drops`); chances and the roll rules are in
[`docs/loot.md`](loot.md). All icons are provisional files from `assets/` (the "missing
texture" note is obsolete).

### Orc / ogre (5)

| Passive | Effect | Quality |
|---|---|---|
| Root Grabbers | +10 max stamina | Normal |
| Mace | +2 attack | Normal |
| Ogre Nail | +5 speed | Normal |
| Iron Pendant | +25 max health, does not heal | Normal |
| Gold Stone | +10 % coin drop chance | Rare |

### Werewolf (4)

| Passive | Effect | Quality |
|---|---|---|
| Wolf Pelt | +15 max health, +5 max stamina, does not heal | Normal |
| Wolf Fang | +3 attack | Normal |
| Wolf Claws | +20 % attack while below 30 % health | Normal |
| Werewolf DNA | +15 % attack and +15 % speed at night (`is_night()`) | Rare |

### Mutant toad (4)

| Passive | Effect | Quality |
|---|---|---|
| Frog Saliva | Every 3rd attack fires one piercing projectile, 25 % of damage, 320 px/s | Normal |
| Frog Tongue | Hits slow the enemy to ×0.5 for 3 s | Normal |
| Frog Bubble | Every 3rd attack fires 3 piercing projectiles in a 40° fan, 15 % each | Normal |
| Skin Tubercles | Taking damage drops a 44 px poison cloud: 2 dmg every 0.5 s, 4 s, 4 s cooldown | Rare |

### Slime (3 + 1 consumable)

| Item | Effect | Quality |
|---|---|---|
| Mucus | +1 mucus level permanently (5 particles and +0.5 defense per level) | Normal |
| Compact Mucus | +3 mucus levels | Normal |
| Mucus Heart | Doubles the current mucus level | Rare |
| Mucus Potion | **Consumable** (slots 1–3): jump ×1.3 for 60 s and +1 permanent mucus level | Normal |

The emitter is `MocoEmitter` (`scripts/collectables/moco_emitter.gd`), a `CPUParticles2D`
box over the player's hitbox with a code-generated drop texture; defense per level is
subtracted in `player._apply_damage()`.

### Neutral (19, no drop assigned yet)

They are in the debug list (`KP2`) and can be added to any `item_drops`.

| Passive | Effect |
|---|---|
| Attack Amulet | +6 damage |
| Fury Amulet | +12 damage |
| Critical Amulet | 20 % chance of ×1.8 damage |
| Vampiric Pulse | +2 health per hit |
| Light Armor | −25 % damage taken |
| Heavy Armor | −40 % damage taken |
| Regeneration Talisman | +1 health/s |
| Vigor Ring | +2 stamina/s |
| Iron Heart | +25 max health and heals 25 |
| Second Wind | +2 health/s below 30 % health |
| Thorns | Returns 20 % of damage taken, max 15, 2 s cooldown |
| Gauntlet | Every 5th attack deals ×2 |
| Guardian's Wrath | Blocking grants +30 % damage for 10 s |
| Hunter | +20 % damage to enemies below 30 % health |
| Greed | +1 coin per kill |
| Light Feet | +10 % move speed |
| Vampirism | +2 health per kill |
| Third-Hit Projectile | Every 3rd attack fires 1 projectile, 25 % of damage |
| Burst | Every 3rd attack fires 3 projectiles in a 24° fan, 15 % each |

## Adding a passive

1. New script if the effect is new (extend `PassiveItems`, override the hook).
2. New `.tres` with `passive_id`, text, icon and quality.
3. Add it to an enemy's `item_drops` (`LootEntry` with its `drop_chance`) or to the debug
   list `_DEBUG_PASSIVES` in `scenes/inventory/inventory.gd`.
4. If it has art state or timers, reset them in `on_equip` and clean them in `on_unequip`.

## Traps

- Save/Continue stores `resource_path` and re-runs `on_equip`; a passive without a saved
  `.tres` path can't come back. Internal state (levels, timers, stacks) is **not** saved.
- `_process` iterates every equipped passive each frame; keep `on_update` cheap.
- The inventory screen preview reads dynamic fields with `"prop" in item` + `item.get()`;
  a new field with a different name won't show in the preview.
