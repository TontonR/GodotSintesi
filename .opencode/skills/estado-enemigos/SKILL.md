---
name: estado-enemigos
description: Use to read or update the state of any GodotSintesi enemy (stats, drops, mechanics, status). Reads vault/enemies.md and vault/enemies/<slug>.md instead of re-reading scenes, and keeps table, detail page and docs/enemies.md in sync.
---

# Enemy status board (`vault/`)

The living catalog of enemies is `vault/enemies.md` (index + state) plus one page per enemy in `vault/enemies/`. Technical truth is `docs/enemies.md` and `docs/loot.md`; the code wins over every doc.

## Read order (do not preload the whole vault)

1. `vault/enemies.md` — row, drops and `Estado`.
2. `vault/enemies/<slug>.md` — stats in full, mechanics, checklist and files.
3. `docs/enemies.md` + `docs/loot.md` — only if the detail page is not enough.
4. Code (`scripts/enemies/*.gd`, `scenes/enemies/*.tscn`) only when the docs disagree.

Slugs: `orco`, `slime`, `esqueleto`, `arquero`, `lobo`, `rana`, `fantasma`, `demonio`. Item pages live in `vault/items/<tres-name>.md`.

## State vocabulary

| Value | Meaning |
|---|---|
| `sin empezar` | Idea or scene not implemented. |
| `en proceso` | Someone is touching stats, AI or scene now. |
| `por asignar textura` | Logic done, provisional art. |
| `por revisar` | Code done; F5 or peer review pending. |
| `listo` | Played in the engine, reviewed and merged. |

Today **every enemy is `por revisar`**. `fantasma` and `demonio` are also unreachable: no biome lists them.

## When to update

- **Stats / AI / scene changed**: fix the detail page (stats table, mechanics) and the row in `vault/enemies.md`. If behavior changed, also `docs/enemies.md` (AGENTS rule) and the ticket/changelog.
- **`item_drops` changed**: update four places — the `.tscn`, the detail page drops table, the row in `vault/enemies.md`, and `vault/items.md` plus the affected item page.
- **New enemy**: create `vault/enemies/<slug>.md`, add the row, add its scene **and** its count to the biome (`enemy_scenes`/`enemy_counts`, same order), open a ticket.
- **Enemy disabled**: do not delete the page; mark it as unreachable and leave the "how to bring it back" note.
- Never mark `listo` without F5 and a merged PR.

## Quick checks (no Godot)

- Drops of one enemy: `grep -n "item_drops" scenes/enemies/<scene>.tscn` and read the `LootEntry` sub-resources.
- Biome sets: `grep -n "enemy_scenes\|enemy_counts" resources/world/biomes/*.tres`.
- Stats: `grep -n "max_health\|base_attack\|speed_movement" scripts/enemies/<enemy>.gd`.

Do not run `godot` or tests unless the user asks.

## Invariants and traps

- Drops are **one roll**: the total is the sum of `drop_chance`; on success a single weighted item drops. Coin roll is separate (45 %).
- Stats read `base → final`: `_ready()` applies `health_multiplier` 1.35 and `attack_multiplier` 1.25.
- Ground enemies use layer 3 and mask 1: the player walks through them and pays contact damage. `werewolf` overrides contact damage (`uses_custom_contact_damage()`).
- `projectile`, never `projectile_scene`.
- Any `take_damage` override must keep `(amount, critical = false)` and forward `critical`.

## Links

- Index: `vault/enemies.md` · items: `vault/items.md` · technical: `docs/enemies.md`, `docs/loot.md`
- Skills: `estado-items`, `docs-vivas`
