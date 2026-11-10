# Player — movement, combat, health and stamina

_2026-10-20 · branch `feat/skills-and-complex-passives`_

## What it does and where it lives

- `scripts/player.gd` on a `CharacterBody2D` in `scenes/player.tscn`; it's in the `player` group (enemies detect it through that).
- ×2 scale: ≈56 px tall, 16×54 collider (origin sits ~27 px above the feet).
- HUD in `UILayer` (`HealthBar`, `StaminaBar`, coins); `_ensure_health_ui()` / `_ensure_stamina_ui()` recreate the bars in code if the editor deletes the nodes.

## Movement

- `move_speed` 130, `acceleration` 750, `friction` 1000, `jump_velocity` -340, `gravity` 1400, fall ×1.6, coyote 0.1, buffer 0.12.
- Keys read raw: A/D, jump Space/W. Shift = run (1.7×, -10 + -10/s). The arrows are left only for the UI (passive and inventory pages).
- Auto step-up of 1 tile (16 px) with `test_move` on the real shape: it tests 1 px ahead, goes up 17 px and continues with X intact (doesn't brake or block the frame). The sprite stays 16 px below and rises interpolated in `step_duration` (0.08 s) so the hop isn't visible. 2+ tiles must be jumped.
- Attacking or guarding blocks jump and turn; while attacking it moves at 38%.
- Camera: `Camera2D` `offset (60,-70)`, physics `process_callback` (0). The follow target is `player.global_position`, never `camera.global_position`: using the camera's previous position makes the smoothing offset permanent. Each frame the global position is rounded to a whole pixel; on a step jump the Y advances up to 6 px/frame while the offset is ≤18 px. Measured over 1,200 frames on seeds 12345, 67890 and 20261029: max offset 10.21 px, max camera movement 6 px/frame and final offset after settling <0.28 px. `_diag.gd` repeats this check per seed.

## Combat

- Left click: `attack_1/2/3` combo, `combo_window` 0.35 s, `hitbox_damage` 20.
- Right click or E: guard (-15 + -20/s); blocks frontal damage (`from_front`).
- Parry: `parry_window` (0.2 s) from when the guard is raised. If a frontal hit lands within the window, it deals no damage, returns `parry_stamina_refund` (30) and fires `fx.parry()` (sparks, `PARRY!`, flash and shake); the window is consumed and the rest of the guard blocks normally. When the window opens a subtle notice plays (`fx.parry_ready()`).
- Anti-spam: `parry_cooldown` (0.3 s) is added to the window when it opens (`_parry_cooldown_timer = parry_window + parry_cooldown`), so holding or mashing the click doesn't chain parries and each attempt pays the guard (15 + 20/s). A successful parry also resets that cooldown.
- Guard and parry don't push: `_apply_damage()` returns whether the hit actually removed health and `take_damage_from()` cuts before the knockback/knockup when it didn't.

## Stats (2026-11-05)

- Base in `player.gd` ("Combat stats" group): `attack_speed` 1.0 (scales the attack animation and with it the combo cadence), `crit_chance` 0.05, `crit_damage` 2.0 and `luck` 0 (percentage points of drop). Speed is `move_speed` (130).
- Base critical: `_deal_damage()` makes its own roll after the passives and multiplies by `crit_damage`; passives like `amuleto_critico` still roll separately. A critical is announced in `fx.enemy_hit(..., critical)` with more gold sparks, a 12 px number and a short shake.
- Luck: `EnemyBase._luck_drop_bonus()` adds `luck × 0.01` to any loot `drop_chance` (with 0 nothing changes).
- API for passives: `add_attack_speed()`, `add_crit_chance()`, `add_crit_damage()`, `add_luck()`.
- `UILayer/StatsPanel` panel: 2-column `GridContainer` created by `_ensure_stats_ui()` on the left (5 px, 26 px, under the consumables), always visible, `modulate` alpha 0.6 and 9 px font with shadow. It refreshes with `_stats_dirty` (`_update_stats_ui()`) when `attack_speed`, `crit_*`, `luck` or `move_speed` change.
- Health `max_health` 100: `take_damage()`, `heal()`; `_die()` is a placeholder (full respawn).
- Enemy push: `take_damage_from(amount, attacker_pos, knockback, lock, knockup)` applies damage and, if the guard doesn't block it, `apply_knockback()` / `apply_knockup()`. While `lock` lasts (0.12–0.15 s) horizontal input is ignored.
- `is_guarding()` for enemy areas that distinguish blocking (demon fire).
- The player's body only collides with the world (`collision_mask` 1): it passes through enemies, can't climb on them. Damage and hits go through `Area2D`.
- Coins: `current_coins`, `initial_coins`.

## Initial fall (2026-11-03, retimed 2026-11-10)

- `scripts/world/fall_intro.gd` defaults: `fall_height_px` 260 and `fall_speed` 620, so the drop lasts ~0.4 s (it used to be 520 px at 300 px/s, ~1.7 s) plus the 6 tiles the generator leaves between the spawn point and the ground; `max_seconds` 3 is only the safety net. Change the exports, not the world generator.
- Three public variables handled by `scripts/world/fall_intro.gd`: `control_enabled` (false = no input, jump, attack or guard), `camera_follow_enabled` (false = camera doesn't follow) and `fall_speed_cap` (fall speed cap in px/s, 0 = no cap).
- With `control_enabled = false`, `_physics_process` cuts before stamina/combat: it brakes X, applies gravity ×1.6, limits Y and calls `move_and_slide()`. The animation keeps updating.
- By default all three stay at their normal value (`true`, `true`, `0`): outside the intro the player behaves as before.

## Debug (temporary, 2026-11-03)

- `scripts/debug_tools.gd` (`DebugTools`, `debug_tools` node in `game.tscn`): KP7/KP8/KP9 set `Engine.time_scale` to x1/x5/x20 and KP4/KP6 do a fast travel of 64 tiles left/right going up 10 tiles (to get out of mountains). Distances in `teleport_distance_tiles` and `teleport_lift_tiles`.
- **KP5** toggles immortality (`player.toggle_immortal()` → `immortal`): with it active `_apply_damage()` exits without touching health; the push/knockback from `take_damage_from()` still applies. The debug notice shows `immortal yes/no`. It's an independent numpad key; it doesn't use slots 1-3.
- Travel calls `player.debug_teleport(offset)`: it moves, cuts velocity, clears the visual step offset and resets `_cam_y` so the camera doesn't drag the jump.
- `_exit_tree` returns `time_scale` to 1.0: leaving the scene doesn't leave the game sped up.
- The test items (KP0-KP3) live separately, in `scenes/inventory/inventory.gd` (see `docs/items.md`).

## Traps

- Turn with `sprite_pivot.scale.x`, never `flip_h`: with `flip_h` the feet shift because of the sword padding.
- Movement is read with `Input.is_key_pressed` raw, not with the `movement` action in `project.godot`.
