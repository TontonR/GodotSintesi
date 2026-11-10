# Items and inventory — catalog

_2026-10-14 · `feat/items-demo` · 2026-11-10 · 3 consumables, no skills_

## Hierarchy

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → concrete passives. Generic pickup: `item_pickup.gd/.tscn` with `@export var item: Items`. `Skills` is removed: there are no skill slots anymore.

## Slots (3) and keys

| Slots | Type | Keys (`use_slot_1..3`) |
| --- | --- | --- |
| 1-3 | Consumables (used up) | 1, 2, 3 |

- `Inventory.MAX_SLOTS = 3`; `add_item` puts the item in the first free slot. If all 3 are full, the item stays on the ground.
- Passives do not take a slot: they go to `PlayerPassives` when touched (`body_entered`).
- The HUD bar (`InventoryUI`) shows the 3 consumables, with no separator.

## Item state

All items are **implemented in code**, but none has final art yet. That is why every table row is marked **`missing texture`**. When the art is added it will change to `done`; an item without logic would be `not done`.

## Consumables (9)

They are used up when used with 1/2/3.

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Healing Potion | `pocion_cura` | +30 health | Heals when used | missing texture |
| Minor Healing Potion | `pocion_cura_menor` | +15 health | Heals when used | missing texture |
| Vigor Elixir | `pocion_mayor` | +60 health | Heals when used | missing texture |
| Life Elixir | `elixir_vida` | +100 health | Heals when used | missing texture |
| Stamina Potion | `pocion_stamina` | +40 stamina | Restores stamina | missing texture |
| Greater Stamina Potion | `pocion_stamina_mayor` | +70 stamina | Restores stamina | missing texture |
| Tonic Drink | `bebida_tonificante` | +20 health, +20 stamina | Heals and restores stamina | missing texture |
| Vital Essence | `esencia_vital` | +40 health, +40 stamina | Heals and restores stamina | missing texture |
| Mucus Potion | `pocion_mocos` | jump ×1.3 (60 s) | +1 permanent mucus level | missing texture |

## Passives dropped by enemies (17)

Each enemy has its own `item_drops` table; see “Drops”.

### Ogre (5)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Root Grabbers | `tapoarrabos` | +10 max stamina | Flat stamina bonus | missing texture |
| Mace | `maza` | +2 attack | Flat attack bonus | missing texture |
| Ogre Nail | `una_ogro` | +5 speed | Flat speed bonus | missing texture |
| Iron Pendant | `colgante_hierro` | +25 max health (no heal) | Flat health bonus | missing texture |
| Gold Stone | `piedra_oro` | +10 % coin on kill | Raises `coin_drop_chance` | missing texture |

### Wolf (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Wolf Pelt | `piel_lobo` | +15 max health, +5 max stamina (no heal) | Flat bonus | missing texture |
| Wolf Fang | `colmillo_lobo` | +3 attack | Flat attack bonus | missing texture |
| Wolf Claws | `garras_lobo` | +20 % attack below 30 % health | Conditional attack | missing texture |
| Werewolf DNA | `adn_hombre_lobo` | +15 % attack and +15 % speed at night | Night bonus | missing texture |

### Frog (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Frog Saliva | `saliva_rana` | 25 % of base damage | Every 3rd attack fires a piercing projectile | missing texture |
| Frog Tongue | `lengua_rana` | speed ×0.5 for 3 s | Slows the hit enemy | missing texture |
| Frog Bubble | `burbuja_rana` | 15 % of base damage ×3 | 3 piercing projectiles in a fan | missing texture |
| Skin Tubercles | `tuberculos_cutaneos` | 2 damage / 0.5 s, 4 s | Poison cloud when taking damage | missing texture |

### Slime (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Mucus | `moco` | +1 mucus level | Emits mucus particles | missing texture |
| Compact Mucus | `moco_compacto` | +3 mucus levels | Each level gives +0.5 defense | missing texture |
| Mucus Heart | `corazon_mucosil` | doubles the mucus level | More particles and defense | missing texture |
| Mucus Potion | `pocion_mocos` | jump ×1.3 (60 s) | +1 permanent mucus level | missing texture |

## Other passives (18)

No drop assigned yet; they are in debug and can be added to any `item_drops`.

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Attack Amulet | `amuleto_ataque` | +6 damage | Flat attack bonus | missing texture |
| Fury Amulet | `amuleto_furia` | +12 damage | Flat attack bonus | missing texture |
| Critical Amulet | `amuleto_critico` | 20 % ×1.8 | Critical chance | missing texture |
| Vampiric Pulse | `pulso_vampirico` | +2 health per hit | Life steal | missing texture |
| Light Armor | `armadura_ligera` | −25 % damage taken | Damage reduction | missing texture |
| Heavy Armor | `armadura_pesada` | −40 % damage taken | Damage reduction | missing texture |
| Regeneration Talisman | `talisman_regen` | +1 health/s | Regeneration | missing texture |
| Vigor Ring | `anillo_vigor` | +2 stamina/s | Stamina regeneration | missing texture |
| Iron Heart | `corazon_hierro` | +25 max health and heals 25 | Health increase | missing texture |
| Second Wind | `segundo_aliento` | +2 health/s below 30 % health | Conditional regeneration | missing texture |
| Thorns | `espinas` | 20 % of damage taken, max 15, cd 2 s | Returns damage to the attacker | missing texture |
| Gauntlet | `guantelete` | ×2 damage | Every 5th attack | missing texture |
| Guardian's Wrath | `ira_guardian` | +30 % damage for 10 s | On block | missing texture |
| Hunter | `cazador` | +20 % damage | Against enemies below 30 % health | missing texture |
| Greed | `codicia` | +1 coin per death | Extra coins | missing texture |
| Light Feet | `pies_ligeros` | +10 % speed | Movement bonus | missing texture |
| Vampirism | `vampirismo` | +2 health per death | Heals on kill | missing texture |
| Third-Hit Projectile | `proyectil_tercer_golpe` | 25 % of damage | Projectile every 3rd attack | missing texture |
| Burst | `rafaga` | 15 % of damage ×3 | 3 projectiles every 3rd attack | missing texture |

## Drops (2026-11-09)

- Each enemy defines its own `item_drops` table (`Array[LootEntry]`, editable in its scene). Each entry is an item (`.tres`) with `drop_chance`, `min_amount` and `max_amount`.
- **Single item roll**: probabilities are added together (30 % + 10 % = 40 % chance that something drops) and, if it does, **one** item is chosen weighted by its probability. Two different items from the same enemy cannot drop.
- **Coins always separate**: `coin_drop_chance` (45 %) + `coin_drop_amount` (1, more than one allowed) go in their own roll, independent of items.
- There are no shared pools or presets: a new variant copies or rebuilds its table. The 2 coins per chunk from the generator are independent pickups.
- The archer, the skeleton and the flyers have no entries until they are added.
- The drop is parented first and then receives `global_position`; assigning it before made the chunk offset add up twice.
- Physics (`item_pickup.gd`): gravity 900, bounce 0.45 until <35 px/s, sway 1.5 px, `z_index` 1. Pickup with a 32 px icon, `HALF_HEIGHT` 16 and radius 16. Tooltip at 40 px.

## Debug (temporary, `scenes/inventory/inventory.gd`)

- Numpad `0` empties inventory and passives; `1` adds a random consumable; `2` a random passive. There is no `3` key anymore.
- They are added directly (consumables to the 3 slots, passives to `PlayerPassives`); if the inventory is full, the item is discarded.
- To remove it: `DEBUG_TOOLS = false` (or delete `_handle_debug_key`, `_clear_debug_items` and `_give_debug_item`).

## Pending

- Final textures for all items.
- Assign the 18 passives without a drop to the appropriate enemies.
- Swapping with a full bar (today it stays on the ground).
- Legacy root `player.tscn` without `Inventory`/`PlayerPassives` (unused).
