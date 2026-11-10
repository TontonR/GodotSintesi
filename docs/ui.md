# UI — HUD, passive grid and inventory screen

_2026-10-15 · 2026-10-22 · branch `feat/skills-and-complex-passives` · 2026-11-06 · 2026-11-10_

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
- Background: the same parallax as the game (clouds, mountains and two layers of pines, `z_index` -100) over the sky, which is the project's `default_clear_color`.
- **Camera at the spawn point (2026-11-10, T-0047)**: `Camera2D` has the player's `offset (60,-70)` **and** `position (808, 773)`. `Parallax2D` moves each layer by camera position × `scroll_scale`, so a camera at (0,0) left the two pine layers 116 px apart relative to each other and sky showed between them while the in-game spawn looked right. The values are the in-game camera at rest on the spawn: x = `safe_start_tiles` 50 × 16 + 8 = 808; y = ground row (`base_height` 50) × 16 − half the player collider (17 × 3.2 / 2 = 27.2) = 772.8 → 773. If those exports or the collider change, the menu background drifts again and the menu looks like a different screen.
- UI in `CanvasLayer` 10: centered `VBoxContainer` with the title (44 px Label, shadow) and **New Game / Continue / Settings / Quit** buttons. `NewGame` is focused on start, so Enter/Space work; arrows move between buttons.
- **Seed dialog (2026-11-10, T-0048)**: New Game hides the buttons and shows `Menu/SeedDialog` (a `PanelContainer` styled like the settings panel): title, a `LineEdit` with `Empty = random`, and **Back** / **Start**. Enter starts too, **Esc** goes back. An empty field or text that is not an integer means random. The number is stored in `SaveGame.pending_seed` (static, like `pending_load`) because the scene change happens after; `WorldGenerator._ready()` consumes it and clears it. The debug overlay shows the live seed, so typing it back reproduces the world.
- **Continue (2026-11-10)**: only visible when `SaveGame.has_save()` (`user://savegame.cfg`). It calls `SaveGame.request_load()` and changes scene; the new Game root (`scripts/game.gd`) applies the data. New Game cancels any pending load.
- **Settings (2026-11-10)**: `scenes/ui/settings_panel.tscn` + `scripts/ui/settings_panel.gd` (`class_name SettingsPanel`), instanced both here and in the pause menu. Hidden until Settings is pressed, closes with `Back` or **Esc** and emits `closed`. Two rows: **Window mode** (`Windowed`, `Fullscreen` = exclusive, `Borderless fullscreen`) and **Resolution**. Both apply immediately and are stored in `user://settings.cfg` (`[display] window_mode`, `width`, `height`), then re-applied when the panel starts.
- **Window handling (2026-11-10, T-0046)**: `window/stretch/mode="canvas_items"` and `content_scale_stretch = 1` (`integer`) never change. The panel changes the OS window (`window_set_mode()` / `window_set_size()`) **and the size of the game viewport** (`_apply_layout()`). Fullscreen reads `screen_get_size()`, windowed uses the chosen size; the viewport becomes `size / factor`, with `factor` the largest whole pixel size that still leaves 768×432 for the UI (`_best_factor()`). Every art pixel is exactly `factor` screen pixels, so the texel size is constant (no shimmer) and the leftover space is **more visible world, never black bars**. At most `factor - 1` px is left when the size is not divisible (1 px at 2×, e.g. the 1079-tall borderless window).
- **Why not fractional (T-0045)**: forcing `fractional` to fill the screen was what made the mountains judder — at 2.5× the nearest-filtered texels change size every frame. Integer + adaptive viewport gets a full screen and crisp pixels at the same time.
- Resolution list (2026-11-10, T-0046): 18 window sizes (`1024×576` … `3840×2160`, including `1366×768`, `1680×1050`, `1920×1200`, `2560×1600` and `3440×1440`), filtered to those that fit in the usable screen area and disabled outside windowed mode. A size saved by an older build is validated against the list and falls back to 2×.
- Side effects of a viewport bigger than 768×432: HUD anchors stay at the corners, the inventory (744×380) still fits, and the code that reads `get_visible_rect()` (`day_night`, `biome_particles`, ghost teleport, item pickups) adapts on its own.
- No fades: New Game/Continue call `change_scene_to_file("res://scenes/game.tscn")` directly (the transition black was removed on 2026-11-03).
- `MountainBase`: `ColorRect` child of `mountains` (local and 62 → 400, 2064 px wide), so no sky shows below the range. Since 2026-11-03 it is also in `game.tscn`: the flat band is always visible, in the menu and in-game. In the menu it keeps `#283D43`; in-game it follows the biome (2026-11-10): `WorldGenerator.base_tint_paths` points to it and `_update_biome_tint()` sets its `color` to the biome's `forest_color` darkened 0.35, so the meadow reproduces `#283D43` and the red forest/snow shift with the rest of the background. The day/night cycle still darkens it along with the whole `mountains` node.
- The game starts with the fall from the sky (`FallIntro`, see `docs/world.md`).

## Debug overlay (2026-11-10, T-0048)

- `scripts/debug_tools.gd` (`debug_tools` node in `game.tscn`) creates `UILayer/DebugHint`, an 11 px label anchored to the **bottom left** (alpha 0.75 + shadow) with two lines:
  - `speed x1 · immortal no · KP7/KP8/KP9 x1/x5/x20 · KP4/KP6 quick travel · KP5 immortal` (the keys), and
  - `pos 808, 773 · tile 50, 48 · seed 12345`: the player position in pixels (rounded), the same in tiles (`floori(px / 16)`) and the seed of the run (`WorldGenerator.current_seed()`, random when the menu field was left empty).
- The second line is rebuilt in `_process` and only written to the label when it changes, so standing still costs nothing and the seed is readable without stopping.

## Pause menu (2026-11-10)

- `scenes/ui/pause_menu.tscn` + `scripts/ui/pause_menu.gd` (`class_name PauseMenu`), instanced in `game.tscn` as `PauseMenu` (CanvasLayer 20, `process_mode = ALWAYS`). Hidden until **Esc** (`ui_cancel`). Buttons: **Resume**, **Settings** (same `SettingsPanel`) and **Save and quit**.
- It pauses the tree (`get_tree().paused = true`) and `_exit_tree` un-pauses it as a safety net. While the inventory screen is open the tree is already paused and Esc belongs to it: the pause menu returns without handling it, so the inventory closes first.
- `Save and quit` saves the run (see below) and loads `scenes/main_menu.tscn`.

## Save slot (2026-11-10)

- `scripts/save_game.gd` (`class_name SaveGame`, static) writes `user://savegame.cfg` in `[run]` (seed, position, health, stamina, coins), `[inventory]`, `[passives]` (resource paths) and `[world]` (killed-enemy and collected-coin spawn ids).
- On Continue, `pending_load` + `data` are static so they survive `change_scene_to_file()`: `WorldGenerator._ready()` uses the saved seed and restores the spawn ids before instancing chunks; `FallIntro` skips itself; `Game._ready()` (root `scripts/game.gd`) re-equips passives, restores inventory with `Inventory.restore_from_save()`, puts the player at the saved position (camera `reset_smoothing`) and sets health/stamina/coins with `Player.restore_run_state()`.
- Not saved: passive internal state (levels/timers), live enemies that had not been killed, and the day/night clock. Saving only happens from the pause menu.

## Language convention (2026-10-15)

- **In English**: identifiers (functions/vars/constants/enums), `@export`, `@export_group` titles and `##` doc (what the inspector shows).
- **In English**: regular `#` comments, UI text (labels, `.tres`) and `docs/`.
- Refactor scope: objects/inventory/UI/passives/loot systems — `item_pickup.gd`, `scenes/inventory/inventory.gd`, `scenes/inventory/inventory_ui.gd`, `passive_ui.gd`, `scenes/inventory/inventory_screen.gd`, `player_passive.gd`, `collectables/*`, `loot_drop_item.gd`. **Untouched**: `player.gd`, `enemy_base.gd`, `world_generator.gd`, `ghost*.gd`.
