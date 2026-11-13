# GodotSintesi — Agent rules

2D pixel-art roguelike in **Godot 4.7** (`project.godot`). Language: `#` comments, UI text and `.tres` **in English**; identifiers, `@export(_group)` and `##` doc **in English** in the objects/inventory/UI/passives/loot systems (see `docs/ui.md`). `player`/`enemies`/`world_generator` stay as they were.

## Lazy documentation loading (CRITICAL)

This is the only file always in context. **Do not read anything else "just in case"**:

- If the task needs details about a system, load ONLY the file from the index with Read, on demand.
- Do not preload all of them; do not re-investigate what is already documented.
- For broad searches across the code, delegate to `@explore` and ask for a summary: that way you don't flood the main context.

### Index (read only if needed)

| File | When |
|---|---|
| `docs/items.md` | Inventory (3 consumables), full catalog with stats/passive/state, drops and pickup |
| `docs/ui.md` | HUD, passive grid (6 cols, 10 rows/page), inventory screen (Tab/I), EN/ES convention |
| `docs/player.md` | Movement, combo, guard, health, stamina and keys |
| `docs/enemies.md` | `EnemyBase`, ghost (TP) and orc; loot |
| `docs/world.md` | Zone generation, ground, population and layers |
| `docs/fx.md` | Combat particles, damage numbers, shake and HUD feedback |
| `docs/decor.md` | Decor sprites (bushes, trees, rocks): spawn, layering, tinting and biome colors |
| `docs/biomes.md` | Biome `.tres`, runs, transitions, tints and ambient |
| `docs/loot.md` | Coin/item rolls, per-enemy tables, pickup physics and saved spawn ids |
| `docs/passives.md` | `PlayerPassives`, hooks and the 35-passive catalog |
| `docs/historial.md` | Bugs already fixed (drops, loot); read only if something smells like that |
| `documentation.md` | Historical (396 lines). Archaeology only; do not use as a source |
| `vault/README.md` | Plan and channel with the partner's opencode: tickets, status and log |

## Working rules

- **Do not touch anything that wasn't asked for.** No tests, validation, commits or Godot commands unless explicitly requested.
- **Before touching code**: read `vault/estado.md` and work from a ticket in `vault/tickets/` (contract in `vault/README.md`). When closing, update the ticket, `changelog.md` and `estado.md`.
- **Git flow**: never commit to `main`; each feature uses its own `feat/<slug>` branch and lands through a PR (see `vault/README.md`).
- The Godot editor is usually **open**: after a `checkout/reset` it reserializes open scenes (adds `unique_id`/`node_paths`). If `git status` shows a scene you didn't touch, it's the editor.
- Terminal output: **always filter**. Never list `assets/` unfiltered (+1000 PNGs blow up the context).

## Conventions

- GDScript with tabs; `class_name`; `##` above every `@export`; group into `@export_group`.
- Scenes in `scenes/`, scripts in `scripts/`; all inventory lives in `scenes/inventory/` and its styles in `resources/inventory/`. Legacy at the root: `player.tscn`, `item_pickup.gd/.tscn`, `documentation.md`.
- Enemies extend `EnemyBase` (`scripts/enemies/enemy_base.gd`); player in the `player` group.
- 2D layers: 1 world, 2 player, 3 enemies, 4 player attack. Viewport 384×216.
- Ghost scene exports: `projectile` (not `projectile_scene`).

## Saving knowledge (always)

When finishing a task that changes behavior or closes a decision:

1. Summarize the result in `docs/<system>.md` (create it if it doesn't exist), ~30 lines max, dated `YYYY-MM-DD`.
2. **This file does not grow**: if it exceeds ~70 lines, the new content goes to `docs/`.
3. If you create a new file, add it to the index above.
4. Template and when to write: `docs-vivas` skill (load it before investigating and when closing the task).
