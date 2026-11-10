# FX and combat feedback

_2026-11-05 · 2026-11-10_

- `scripts/fx.gd` (`fx` node in `game.tscn`, `fx` group): creates particles, damage numbers and screen layers in code. No new scenes or textures: the particles' white pixel is generated with `Image`.
- World particles (single-use `CPUParticles2D`): sparks when hitting an enemy, burst on death, dust when jumping/landing/running and sparks when picking up coins, items or healing.
- Floating numbers: `Label` in `CanvasLayer` 8, placed with `get_canvas_transform()` (fixed size even if the camera has zoom), rising 18 px and fading in 0.65 s. Enemy in warm white, player in red, coin `+1` gold, healing `+N` green.
- Player damage: `shake()` moves `Camera2D.offset` with falloff for 0.18 s and `damage_flash()` places a red `ColorRect` (CanvasLayer 9, under the HUD) with alpha 0.3 → 0 in 0.32 s.
- The shake respects the camera framing: `shake()` saves the base `offset` at the start (60, −70 in the player's) and restores it at the end. Before, it wrote `Vector2.ZERO` at the end, so the first hit recentered the view forever (T-0033).
- HUD: `add_coin()` gives the counter a scale pop; the health bar pulses red below 30 %.
- To hook more effects: `fx.enemy_hit()`, `fx.enemy_death()`, `fx.player_hit()`, `fx.coin_pickup()`, `fx.item_pickup()`, `fx.heal()`, `fx.dust()`, `fx.shake()`. Consumers look up the node through the `fx` group.
- Dust: the player emits it at `_feet_offset()` (bottom half of its hitbox, 27 px below the origin), so it comes out at ground level when jumping, landing and running, with its own gravity (240) to stay down. The color is no longer fixed: `dust()` asks for the biome at that X from `WorldGenerator.biome_at_world_x()` and uses its `grass_color` lightened by 35 % (green in meadow, reddish in red forest, whitish in snow); without a generator it falls back to the previous toasted gray.
- Parry: `fx.parry()` launches two bursts (16 fast white sparks + 10 gold ones with gravity), a floating `PARRY!`, `shake(1.2, 0.1)` and a warm flash at alpha 0.16. It is triggered by the player when the just-raised guard stops a frontal hit (`parry_window`, 0.2 s, with a 0.3 s cooldown).
- Window-open notice: `fx.parry_ready()` releases 4 small gold sparks with no text or shake, to read the timing.
- Critical: `fx.enemy_hit(pos, damage, critical)` with `critical = true` switches to 14 gold sparks + 6 white, a 12 px amber number and `shake(1.0, 0.06)`. `_number()` accepts an optional font size (9 by default).
- Enemy death: four blood layers derived from a single color (dark jet of 32 particles with a 2×5 drop aligned to velocity, splatter, large mist and sparks, up to 300 px/s) plus `shake(1.4, 0.12)`. `_burst()` accepts `gravity`, `radius`, `spread` and `align_to_velocity`.
- **Blood per enemy** (2026-11-10): `fx.enemy_death(pos, blood_color)` takes the color and derives the jet (`darkened(0.4)`), the splatter (as-is), the mist (`alpha 0.55`) and the sparks (`lightened(0.75)`). `EnemyBase.blood_color` is exported and defaults to `fx.BLOOD_COLOR` (`0.82, 0.11, 0.1`), i.e. the red used before; set it per enemy scene to change only that enemy.
- Mucus (`scripts/collectables/moco_emitter.gd`): 14×48 px box emission covering the player's hitbox, so it drips from the whole body instead of a central point.
- Biome particles (`scripts/world/biome_particles.gd`): leaves and snowflakes enter/leave with a 0.4 s fade and carry sideways wind; they no longer pop in abruptly when crossing the border.
