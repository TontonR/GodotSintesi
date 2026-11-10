# UI — HUD, passive grid and inventory screen

_2026-10-15 · 2026-10-22 · branch `feat/skills-and-complex-passives` · 2026-11-06_

## Passive grid (`PassiveUI` · `UILayer/PassiveBar`)

- **6-column** `GridContainer` anchored top-right (under health/stamina), `grow_horizontal = 0` (adding rows widens it to the left) and `columns = 6`.
- **Order**: the newest is **top left** (`active_passives` is iterated in reverse within the visible page); rows grow downward.
- **Paging (2026-10-20)**: only **10 rows per page** (60 icons); **← / →** (`ui_left`/`ui_right`) change page with wraparound. The `Page X/Y` counter (`UILayer/PassivePageLabel`) is **above the grid** and only shows if there is more than one page. The arrows no longer move the player (only A/D + Space/W).
- 12×12 icons with alpha 0.55, `h/v_separation` 2. Refresh via `PlayerPassives.passives_changed` → `_refresh` (existing bind pattern).

## Stats panel (2026-11-05)

- `UILayer/StatsPanel`: **2-column** `GridContainer` anchored top-left at `position (5, 82)`, below the coin line (y≈63) so it doesn't cover it. `player.gd::_ensure_stats_ui()` creates it if missing, just like the health/stamina bars.
- **Always visible**, 9 px font with shadow and `modulate` alpha **0.6** so it doesn't cover the game. Six rows: `Damage`, `Atk. speed`, `Crit. damage`, `Crit. chance`, `Speed`, `Luck`; values in light gold, right-aligned.
- It only refreshes when something changes (`_stats_dirty`): it doesn't rewrite labels every frame. The values come from the player's `attack_speed`, `crit_damage`, `crit_chance`, `move_speed` and `luck`.

## Inventory screen (`scenes/inventory/inventory_screen.tscn` · `scenes/inventory/inventory_screen.gd`)

- **Opening**: `inventory` action = **Tab** or **I** (new in `project.godot`); **Esc** or **I** closes. With the screen open, **Tab toggles between column 1 and 2** (it doesn't close). **Pauses the game** (`get_tree().paused = true`; the screen lives with `process_mode = ALWAYS` and `_exit_tree` makes sure not to leave the tree paused).
- **3-column layout (2026-10-20, adjusted 2026-11-10)**: left = player portrait (copy of `SpritePivot/AnimatedSprite2D`, `idle` animation) + **Consumables** (3 slots, keys 1-3); center = **Collectables**; right = detail/preview. Each column is a `PanelContainer` with a **fixed width** (168/272/232 px) and its own outline, so it doesn't resize with content. Centered 744×380 window + dimmed background.
- **Doubled (2026-11-06)**: the viewport became 768×432 (T-0010) and the inventory kept the measurements from the 384×216 one. Everything was doubled in `inventory_screen.tscn`: window, margins (16/8), radii (12/8), borders (2), separations (20 and 8), fonts (18/16 and 20 for the name), portrait (144×104), preview (128 icon) and page sliders (32×32). In `inventory_screen.gd`: `SLOT_SIZE` 40×40, `COLLECTIBLE_SLOT_SIZE` 32×32 and `slot.expand_icon = true` so the icon fills the slot; the HUD keeps its 18×18 slot without expanding.
- **Collectables = the active passives** (`PlayerPassives.active_passives`, simple or complex, the same as in the HUD). **Paged**: 6-column `GridContainer` × **6 rows per page** (36/page, 16×16 buttons); the header shows **"Collectables"**, the **X/Y** counter and the **← / →** arrows right next to it.
- **Right** (right panel): 64 px icon, **name**, **stats** line and **description** of the selected item. Stats: health/stamina for consumables; for passives, dynamic properties are read (`bonus`, `reduction`, `heal_per_tick`+`interval`) with `"prop" in item` + `item.get()`.
- **GUI**: the structure (panels, labels and grids) lives in the `.tscn`; the code only instantiates/fills the dynamic slots (`InventorySlot`) and binds the `Inventory`/`PlayerPassives` data.
- **Slots**: `InventorySlot` (`scenes/inventory/inventory_slot.tscn`) is a reusable `Button` with styles in `resources/inventory/`; `InventoryScreen` instantiates it via `@export var slot_scene` and `_refresh()` only fills the icon/selection. **HUD**: `InventoryUI` instantiates the same slot with `preload` (18×18) for the 3 consumables, without creating buttons by hand in `game.tscn`.
- **Selection (2026-10-20, adjusted 2026-11-10)**: mouse (click on the slot), **A/D** previous/next within the active column and **W/S** up/down within the active column (left: a single row of consumables; center: grid rows). **Tab** toggles between column 1 and 2; column 3 (preview) can never be selected. Highlight = 1 px blue border, same width as the normal one (the slot doesn't change size) and **keeps the blue on mouse hover**. **Pages**: **← / →** and **Q** (previous/left) / **E** (next/right) change page and select the first collectable; the **← / →** buttons are in the header, next to "Collectables". Empty slots = disabled buttons with the same background; `focus_mode = NONE` (Tab is handled by hand to toggle columns).
- **No** use/equip buttons (not requested). Keys 1-3 do not respond while it's open (the pause blocks them). It remounts with `slots_changed`/`passives_changed` only if it is visible.

## Main menu (2026-11-03)

- `scenes/main_menu.tscn` + `scripts/ui/main_menu.gd`, now `run/main_scene` in `project.godot`. The game is called **OffBeaten Path** (`config/name`).
- Background: the same parallax as the game (clouds, mountains and two layers of pines, `z_index` -100) over the sky, which is the project's `default_clear_color`. `Camera2D` with the same `offset (60,-70)` as the player's so the layers fall in the same place as in-game.
- UI in `CanvasLayer` 10: centered `VBoxContainer` with the title (44 px Label, shadow) and the `Play` button (focused on start, so Enter/Space also work).
- No fades: Play calls `change_scene_to_file("res://scenes/game.tscn")` directly (the transition black was removed on 2026-11-03).
- `MountainBase`: `ColorRect` child of `mountains` (local and 62 → 400, 2064 px wide) with `#283D43` (`Color(0.157, 0.239, 0.263)`), so no sky shows below the range. Since 2026-11-03 it is **also** in `game.tscn` with the same color: the flat band is always visible, in the menu and in-game, and the day/night cycle darkens it along with the rest of the `mountains` node.
- The game starts with the fall from the sky (`FallIntro`, see `docs/world.md`).

## Language convention (2026-10-15)

- **In English**: identifiers (functions/vars/constants/enums), `@export`, `@export_group` titles and `##` doc (what the inspector shows).
- **In English**: regular `#` comments, UI text (labels, `.tres`) and `docs/`.
- Refactor scope: objects/inventory/UI/passives/loot systems — `item_pickup.gd`, `scenes/inventory/inventory.gd`, `scenes/inventory/inventory_ui.gd`, `passive_ui.gd`, `scenes/inventory/inventory_screen.gd`, `player_passive.gd`, `collectables/*`, `loot_drop_item.gd`. **Untouched**: `player.gd`, `enemy_base.gd`, `world_generator.gd`, `ghost*.gd`.
