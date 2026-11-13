# Items and inventory — catalog

_2026-10-14 · `feat/items-demo` · 2026-11-13 · 9 consumables, no skills_

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

All items are **implemented in code** and have an assigned sprite. The state column says `assigned icon`; the art can still change, but it is no longer missing. An item without logic would be `not done`.

## Consumables (9)

They are used up when used with 1/2/3.

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Healing Potion | `pocion_cura` | +20 health | Heals when used | assigned icon |
| Greater Healing Potion | `pocion_cura_menor` | +50 health | Heals when used | assigned icon |
| Perfect Healing Potion | `elixir_vida` | +100 health | Heals when used | assigned icon |
| Stamina Potion | `pocion_stamina` | +20 stamina | Restores stamina | assigned icon |
| Greater Stamina Potion | `pocion_mayor` | +50 stamina | Restores stamina | assigned icon |
| Perfect Stamina Potion | `pocion_stamina_mayor` | +100 stamina | Restores stamina | assigned icon |
| Tonic Drink | `bebida_tonificante` | +20 health, +20 stamina | Heals and restores stamina | assigned icon |
| Vigorizing Pie | `esencia_vital` | +40 health, +40 stamina | Heals and restores stamina | assigned icon |
| Mucus Potion | `pocion_mocos` | jump ×1.3 (60 s) | +1 permanent mucus level | assigned icon |

### Consumable icons (2026-11-13)

The `.tres` paths stay unchanged for save compatibility; only their internal
fields changed.

| `.tres` | Sprite |
| --- | --- |
| `pocion_cura` | `assets/potions/potion13.png` |
| `pocion_cura_menor` | `assets/potions/potion129.png` |
| `elixir_vida` | `assets/potions/potion158.png` |
| `pocion_stamina` | `assets/potions/potion108.png` |
| `pocion_mayor` | `assets/potions/potion137.png` |
| `pocion_stamina_mayor` | `assets/potions/potion166.png` |
| `bebida_tonificante` | `assets/potions/potion219.png` |
| `esencia_vital` | `assets/items/item410.png` |
| `pocion_mocos` | `assets/items/Icon19.png` |

## Passives dropped by enemies (17)

Each enemy has its own `item_drops` table; see “Drops”.

### Ogre (5)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Root Grabbers | `tapoarrabos` | +10 max stamina | Flat stamina bonus | assigned icon |
| Mace | `maza` | +2 attack | Flat attack bonus | assigned icon |
| Ogre Nail | `una_ogro` | +5 speed | Flat speed bonus | assigned icon |
| Iron Pendant | `colgante_hierro` | +25 max health (no heal) | Flat health bonus | assigned icon |
| Gold Stone | `piedra_oro` | +10 % coin on kill | Raises `coin_drop_chance` | assigned icon |

### Wolf (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Wolf Pelt | `piel_lobo` | +15 max health, +5 max stamina (no heal) | Flat bonus | assigned icon |
| Wolf Fang | `colmillo_lobo` | +3 attack | Flat attack bonus | assigned icon |
| Wolf Claws | `garras_lobo` | +20 % attack below 30 % health | Conditional attack | assigned icon |
| Werewolf DNA | `adn_hombre_lobo` | +15 % attack and +15 % speed at night | Night bonus | assigned icon |

### Frog (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Frog Saliva | `saliva_rana` | 25 % of base damage | Every 3rd attack fires a piercing projectile | assigned icon |
| Frog Tongue | `lengua_rana` | speed ×0.5 for 3 s | Slows the hit enemy | assigned icon |
| Frog Bubble | `burbuja_rana` | 15 % of base damage ×3 | 3 piercing projectiles in a fan | assigned icon |
| Skin Tubercles | `tuberculos_cutaneos` | 2 damage / 0.5 s, 4 s | Poison cloud when taking damage | assigned icon |

### Slime (4)

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Mucus | `moco` | +1 mucus level | Emits mucus particles | assigned icon |
| Compact Mucus | `moco_compacto` | +3 mucus levels | Each level gives +0.5 defense | assigned icon |
| Mucus Essence | `corazon_mucosil` | doubles the mucus level | More particles and defense | assigned icon |
| Mucus Potion | `pocion_mocos` | jump ×1.3 (60 s) | +1 permanent mucus level | assigned icon |

## Other passives (18)

No drop assigned yet; they are in debug and can be added to any `item_drops`.

| Name | `.tres` | Stats | Passive / effect | State |
| --- | --- | --- | --- | --- |
| Attack Amulet | `amuleto_ataque` | +6 damage | Flat attack bonus | assigned icon |
| Fury Amulet | `amuleto_furia` | +12 damage | Flat attack bonus | assigned icon |
| Critical Amulet | `amuleto_critico` | 20 % ×1.8 | Critical chance | assigned icon |
| Sanguine Ruby | `pulso_vampirico` | +2 health per hit | Life steal | assigned icon |
| Light Armor | `armadura_ligera` | −25 % damage taken | Damage reduction | assigned icon |
| Heavy Armor | `armadura_pesada` | −40 % damage taken | Damage reduction | assigned icon |
| Regeneration Talisman | `talisman_regen` | +1 health/s | Regeneration | assigned icon |
| Vigor Ring | `anillo_vigor` | +2 stamina/s | Stamina regeneration | assigned icon |
| Iron Heart | `corazon_hierro` | +25 max health and heals 25 | Health increase | assigned icon |
| Second Wind | `segundo_aliento` | +2 health/s below 30 % health | Conditional regeneration | assigned icon |
| Thorns | `espinas` | 20 % of damage taken, max 15, cd 2 s | Returns damage to the attacker | assigned icon |
| Gauntlet | `guantelete` | ×2 damage | Every 5th attack | assigned icon |
| Guardian's Wrath | `ira_guardian` | +30 % damage for 10 s | On block | assigned icon |
| Hunter's Faith | `cazador` | +20 % damage | Against enemies below 30 % health | assigned icon |
| Greed | `codicia` | +1 coin per death | Extra coins | assigned icon |
| Light Feet | `pies_ligeros` | +10 % speed | Movement bonus | assigned icon |
| Vampirism | `vampirismo` | +2 health per death | Heals on kill | assigned icon |
| Third-Hit Projectile | `proyectil_tercer_golpe` | 25 % of damage | Projectile every 3rd attack | assigned icon |
| Burst | `rafaga` | 15 % of damage ×3 | 3 projectiles every 3rd attack | assigned icon |

## Passive icons (2026-11-13)

Sprites come from `assets/items/item###.png`; none is repeated. `Focus` is not
an item and was not created. Third-Hit keeps its previous icon.
`Sanguine Ruby` uses `sanguine_ruby.png`, a copy of `Icon29.png`; `Wolf Fang`
and `Wolf Claws` use `Icon34.png` and `Icon12.png`.

| Item | Icon | Item | Icon | Item | Icon |
| --- | --- | --- | --- | --- | --- |
| Werewolf DNA | `item735` | Attack Amulet | `item871` | Critical Amulet | `item855` |
| Fury Amulet | `item869` | Vigor Ring | `item892` | Light Armor | `item221` |
| Heavy Armor | `item226` | Frog Bubble | `item804` | Hunter's Faith | `item828` |
| Greed | `item169` | Iron Pendant | `item890` | Wolf Fang | `Icon34` |
| Iron Heart | `item199` | Mucus Essence | `item1122` | Thorns | `item1018` |
| Wolf Claws | `Icon12` | Gauntlet | `item749` | Guardian's Wrath | `item933` |
| Frog Tongue | `item1094` | Mace | `item918` | Mucus | `item310` |
| Compact Mucus | `item593` | Gold Stone | `item591` | Wolf Pelt | `item202` |
| Light Feet | `item276` | Sanguine Ruby | `sanguine_ruby` | Burst | `item925` |
| Frog Saliva | `item805` | Second Wind | `item780` | Regeneration Talisman | `item872` |
| Root Grabbers | `item1036` | Skin Tubercles | `item910` | Ogre Nail | `item778` |
| Vampirism | `item1173` | Third-Hit Projectile | `magicW` | — | — |

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

- Final art pass: the assigned `item###.png` sprites can still be replaced.
- Assign the 18 passives without a drop to the appropriate enemies.
- Swapping with a full bar (today it stays on the ground).
- Legacy root `player.tscn` without `Inventory`/`PlayerPassives` (unused).
