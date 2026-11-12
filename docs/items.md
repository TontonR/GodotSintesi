# Items — inventory and consumable catalog

_2026-10-14 · 2026-11-10 · 2026-11-12_

## Hierarchy

`Items` (`Resource`) → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` /
`PassiveItems`. Concrete passives extend `PassiveItems` (see [`docs/passives.md`](passives.md)).
The generic ground pickup is `item_pickup.gd/.tscn` with `@export var item: Items`;
`Skills` and its slots no longer exist.

All 44 resources in `resources/*.tres` have an **icon** now (potions from
`assets/potions/`, passives from `assets/items/`). They are provisional art, not final, but
the old "missing texture" state is gone.

## Slots (3) and keys

| Slots | Type | Keys |
|---|---|---|
| 1–3 | Consumables (used up) | `1`, `2`, `3` (`use_slot_1..3`) |

- `Inventory.MAX_SLOTS = 3`; `add_item()` puts the item in the first free slot and returns
  `false` when all three are full (the pickup stays on the ground).
- `use_slot()` empties the slot **before** calling `item.use(target)`, then emits
  `slots_changed`.
- The HUD bar (`InventoryUI`, `scenes/inventory/inventory_ui.gd`) instantiates three 18×18
  `InventorySlot` buttons; the inventory screen shows the same slots at 40×40.
- Passives never take a slot: they go to `PlayerPassives` on touch.

## Base fields (`Items`)

`id`, `item_name`, `description` (multiline), `icon`, `quality` (`Normal` / `Rare`),
`max_stack` 99, `value`. Consumables add `heal_amount`, `stamina_amount` and `duration`.

## Consumables (9)

Used up when used with 1/2/3.

| Name | `.tres` | Values | Effect |
|---|---|---|---|
| Healing Potion | `pocion_cura` | heal 30 | Restores 30 health |
| Minor Healing Potion | `pocion_cura_menor` | heal 15 | Restores 15 health |
| Vigor Elixir | `pocion_mayor` | heal 60 | Restores 60 health |
| Life Elixir | `elixir_vida` | heal 100 | Restores 100 health |
| Stamina Potion | `pocion_stamina` | stamina 40 | Restores 40 stamina |
| Greater Stamina Potion | `pocion_stamina_mayor` | stamina 70 | Restores 70 stamina |
| Tonic Drink | `bebida_tonificante` | heal 20, stamina 20 | Restores both |
| Vital Essence | `esencia_vital` | heal 40, stamina 40 | Restores both |
| Mucus Potion | `pocion_mocos` | jump ×1.3, 60 s, +1 mucus level | `MocoPotion`: also leaves the mucus emitter on permanently |

The Mucus Potion is the only consumable with its own script (`MocoPotion`); it is also
listed among the slime drops, but it still occupies a consumable slot when picked up.

## Passives

35 passive resources: 16 assigned to enemies (orc 5, werewolf 4, toad 4, slime 3) and 19
without a drop yet. Full catalog, effects and quality: [`docs/passives.md`](passives.md).

## Drops

Chances, single-roll rule, duplicate filtering, pickup physics and persistence:
[`docs/loot.md`](loot.md).

## Debug (temporary, `scenes/inventory/inventory.gd`)

- `DEBUG_TOOLS = true`; numpad `0` empties inventory and passives, `1` gives a random
  consumable and `2` a random passive from `_DEBUG_PASSIVES` (36 paths, including the
  shared Mucus Potion).
- Items are added directly: consumables to the first free slot (discarded if full),
  passives to `PlayerPassives`. There is no `KP 3` anymore.
- To remove: set `DEBUG_TOOLS = false` or delete `_handle_debug_key`,
  `_clear_debug_items` and `_give_debug_item`.

## Pending

- Final textures for all items.
- Assign the 19 neutral passives to enemies.
- Swapping when the bar is full (today the item stays on the ground).
- `max_stack` and `value` are stored but unused.
