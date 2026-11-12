# GodotSintesi

**OffBeaten Path**: a 2D pixel-art action roguelike made with **Godot 4.7**. The player explores generated zones, fights enemies, picks up consumables and equips passives that modify combat.

## Run

1. Open `project.godot` with Godot 4.7.
2. Press **F5**. The main scene is `scenes/main_menu.tscn`: **New Game** (click or Enter) loads `scenes/game.tscn`, where the player falls from the sky into the generated world. **Continue** appears when there is a save, and **Settings** holds window mode and resolution.

## Controls

| Action | Key |
|---|---|
| Move | `A` / `D` |
| Jump | `Space` / `W` |
| Run | `Shift` |
| Attack | Left click |
| Guard | Right click / `E` |
| Open inventory | `Tab` / `I` |
| Close inventory | `Esc` / `I` |
| Toggle inventory column | `Tab` (column 1 ↔ 2; the preview cannot be selected) |
| Use consumable 1-3 | `1` / `2` / `3` |
| Pause menu (resume, settings, save and quit) | `Esc` |
| Change passive page (HUD) | `←` / `→` |
| Move inventory selection | `A` / `D` (previous/next), `W` / `S` (up/down) within the active column |
| Change inventory page | `←` / `→`, `Q` (previous) / `E` (next) or the `←` / `→` buttons next to "Collectables" |

The inventory has 3 fixed-width outlined columns: character/consumables, collectables and preview. `Tab` toggles between the first two; the preview can never be selected. Passives do not use slots: they are equipped on pickup.

## Temporary debug

With the numpad, while the game is not paused:

| Key | Effect |
|---|---|
| `KP 0` | Empties the inventory and active passives |
| `KP 1` | Spawns a random consumable |
| `KP 2` | Spawns a random passive/collectable |
| `KP 4` / `KP 6` | Fast travel left / right (64 tiles), landing a few tiles above the ground |
| `KP 7` / `KP 8` / `KP 9` | Game speed halved / reset to x1 / doubled (`Engine.time_scale`, no cap) |

Items are added directly to the inventory or to active passives. The item code lives in `scenes/inventory/inventory.gd` (`DEBUG_TOOLS`) and the speed/travel code in `scripts/debug_tools.gd`; both are meant to be deleted when the testing phase ends. The current speed and keys are shown in a label at the bottom left (`DebugHint`).

## Structure

- `scenes/`: game scenes (`game.tscn`, `player.tscn`, enemies).
- `scenes/inventory/`: all inventory (screen, slots, logic and consumable HUD).
- `scripts/`: GDScript logic (player, enemies, world, UI and collectables).
- `resources/inventory/`: inventory slot styles.
- `resources/`: data objects (`.tres`) of the catalog.
- `assets/`: sprites, tiles, coins and effects.
- `docs/`: living documentation per system.
- `AGENTS.md`: working rules and documentation index.

`documentation.md` and the root `player.tscn` / `item_pickup.*` are historical material; the game uses those in `scenes/` and `scripts/`.

## Documentation

Start with `AGENTS.md`; per-system details are in `docs/`:

- `docs/items.md`: inventory, consumable catalog and debug.
- `docs/passives.md`: passive system, hooks and the 35-passive catalog.
- `docs/loot.md`: coin/item drops, tables and pickup physics.
- `docs/ui.md`: HUD, passive grid, inventory, menus and save.
- `docs/player.md`: movement, combat, health and stamina.
- `docs/enemies.md`: enemy base, catalog and spawning.
- `docs/world.md`: world generation, day/night and fall intro.
- `docs/biomes.md`: biome resources, runs, transitions and tint.
- `docs/fx.md`: particles, damage numbers and screen feedback.
