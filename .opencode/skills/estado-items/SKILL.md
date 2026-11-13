---
name: estado-items
description: Use to read or update the state of any GodotSintesi item (consumable or passive): effect, in-game texture path, drop source and status. Reads vault/items.md and vault/items/<slug>.md and keeps them in sync with the .tres and the enemies' loot tables.
---

# Item status board (`vault/`)

The living catalog is `vault/items.md` (index + state) with one page per item in `vault/items/`. Technical truth: `docs/items.md`, `docs/passives.md`, `docs/loot.md`. The code wins over every doc.

## Read order

1. `vault/items.md` — row, drops, `Estado`.
2. `vault/items/<slug>.md` — effect, `.tres`, script, texture path, drop source.
3. `docs/items.md` / `docs/passives.md` / `docs/loot.md` only if needed.
4. `.tres` or scripts only when the docs disagree.

**Slug = the `.tres` basename** (`resources/maza.tres` → `vault/items/maza.md`). It is stable across language changes; do not rename pages to the in-game name.

## State vocabulary

| Value | Meaning |
|---|---|
| `sin empezar` | Idea without a resource. |
| `en proceso` | Script, `.tres` or loot table being written. |
| `por asignar textura` | Logic and `.tres` done, icon is provisional pack art. |
| `por revisar` | Done, F5 or peer review pending. |
| `listo` | Verified in game **and** final texture applied. |

Today **all 44 items are `por asignar textura`**: every `.tres` already has an `icon` (potions from `assets/potions/`, passives from `assets/items/`), but it is provisional. A PNG existing is not the same as a final texture.

## When to update

- **New or changed `.tres`**: update the item page (effect, fields, icon path, quality) and its row in `vault/items.md`.
- **Loot table changed**: update the enemy page, the enemy row in `vault/enemies.md`, this catalog and the item page.
- **Texture replaced**: change `icon` in the `.tres`, the "Textura en el juego" line, and the state (`listo` only after seeing it in game).
- **New neutral passive**: add the `.tres`, the page, the row, and the debug list in `scenes/inventory/inventory.gd`.
- Open a ticket for anything beyond a doc sync.

## Quick checks (no Godot)

- All resources and names: `ls resources/*.tres` (filter, never list `assets/` unfiltered).
- One item's icon/script: read `resources/<slug>.tres` (`icon`, `script`, `item_name`, `quality`).
- Who drops it: `grep -n "item_drops" scenes/enemies/*.tscn`.
- Debug: `DEBUG_TOOLS` in `scenes/inventory/inventory.gd`; numpad `1` random consumable, `2` random passive, `0` clears.

Do not run `godot` or tests unless the user asks.

## Invariants and traps

- One roll per enemy: the total is the sum of `drop_chance`; passives the player owns are filtered out.
- Passives never take a slot; consumables do (3 slots, keys `1`–`3`) and are consumed on use.
- `Mucus Potion` is a **consumable** (`MocoPotion extends Consumable`) even though it comes from the slime passive set.
- `quality` defaults to `Normal`; only write `Rare` when the `.tres` says so.
- Item name is English UI text; page filenames are Spanish `.tres` slugs.
- Descriptions live in the `.tres`; do not paraphrase them away in the page.

## Links

- Index: `vault/items.md` · enemies: `vault/enemies.md` · technical: `docs/items.md`, `docs/passives.md`, `docs/loot.md`
- Skills: `estado-enemigos`, `docs-vivas`
