# FX and combat feedback

_2026-11-05 · 2026-11-10_

- `scripts/fx.gd` (`fx` node in `game.tscn`, `fx` group): creates particles, damage numbers and screen layers in code. No new scenes or textures: the particles' white pixel is generated with `Image`.
- World particles (single-use `CPUParticles2D`): sparks when hitting an enemy, burst on death, dust when jumping/landing/running and sparks when picking up coins, items or healing.
- Bushes: `fx.leaves(world_position, color, amount)` (called by `DecorProp` when the
  player walks through) throws 7 slow leaves in the bush's own tint. It uses the shared
  `fx` node, so there is no particle node per bush and nothing inherits the sprite scale.
- Floating numbers: `Label` in `CanvasLayer` 8, placed with `get_canvas_transform()` (fixed size even if the camera has zoom), rising 18 px and fading in 0.65 s. Enemy in warm white, player in red, coin `+1` gold, healing `+N` green.
- Player damage: `shake()` moves `Camera2D.offset` with falloff for 0.18 s and `damage_flash()` places a red `ColorRect` (CanvasLayer 9, under the HUD) with alpha 0.3 → 0 in 0.32 s.
- The shake respects the camera framing: `shake()` saves the base `offset` at the start (60, −70 in the player's) and restores it at the end. Before, it wrote `Vector2.ZERO` at the end, so the first hit recentered the view forever (T-0033).
- HUD: `add_coin()` gives the counter a scale pop; the health bar pulses red below 30 %.
- To hook more effects: `fx.enemy_hit()`, `fx.enemy_death()`, `fx.player_hit()`, `fx.coin_pickup()`, `fx.item_pickup()`, `fx.heal()`, `fx.dust()`, `fx.shake()`. Consumers look up the node through the `fx` group.
- Dust: the player emits it at `_feet_offset()` (bottom half of its hitbox, 27 px below the origin), so it comes out at ground level when jumping, landing and running, with its own gravity (240) to stay down. The color is no longer fixed: `dust()` asks for the biome at that X from `WorldGenerator.biome_at_world_x()` and uses its `grass_color` lightened by 35 % (green in meadow, reddish in red forest, whitish in snow); without a generator it falls back to the previous toasted gray.
- Crates (`scripts/world/breakable_block.gd`): `fx.crate_hit(pos)` throws 6 wood splinters (streak texture aligned to velocity) plus a little dust on every sword hit; `fx.crate_break(pos)` fires a 26-plank explosion with a dust cloud, golden chips and `shake(1.2, 0.09)` when it breaks. Both receive the crate's center (`global_position + (8,-8)`) and are called through the `fx` group with `has_method`, so a crate still works without the node.
- Parry: `fx.parry()` launches two bursts (16 fast white sparks + 10 gold ones with gravity), a floating `PARRY!`, `shake(1.2, 0.1)` and a warm flash at alpha 0.16. It is triggered by the player when the just-raised guard stops a frontal hit (`parry_window`, 0.2 s, with a 0.3 s cooldown).
- Window-open notice: `fx.parry_ready()` releases 4 small gold sparks with no text or shake, to read the timing.
- Critical: `fx.enemy_hit(pos, damage, critical)` with `critical = true` switches to 14 gold sparks + 6 white, a 12 px amber number and `shake(1.0, 0.06)`. `_number()` accepts an optional font size (9 by default).
- Enemy death: since 2026-11-26 the burrito comes from `scripts/fx/spritefusion_blood.gd` (see the blood bullet below) plus a light spark burst and `shake(1.4, 0.12)`. `_burst()` still accepts `gravity`, `radius`, `spread` and `align_to_velocity` for the other effects.
- **Blood per enemy** (2026-11-10, now in the spray): `fx.enemy_death(pos, blood_color)` and `fx.enemy_hit(...)` pass the color to the spray, which derives its whole 6-tone ramp from it. `EnemyBase.blood_color` is exported and defaults to `fx.BLOOD_COLOR` (`0.82, 0.11, 0.1`); set it per enemy scene to change only that enemy.
- Mucus (`scripts/collectables/moco_emitter.gd`): 14×48 px box emission covering the player's hitbox, so it drips from the whole body instead of a central point.
- Biome particles (`scripts/world/biome_particles.gd`): leaves and snowflakes carry sideways wind and no longer pop in abruptly when crossing the border. There is no alpha crossfade: the layer is never translucent (2026-11-26).
- Ambient VFX (**2026-11-25, T-0093**): `scripts/world/spritefusion_ambient.gd` replaces the generated 5×5 leaf and 3×3 flake with the free MIT pixel-art effects from Sprite Fusion (`falling-leaves`, `snow`, sources in `assets/vfx/spritefusion/`). Leaves use 3 shapes × 4 autumn palettes, pendulum sway, flipping and 108 particles; snow uses four tones, three depths (260/150/30), animated 7×7 crystals, wind noise and the recipe's speeds (26/52/86 px/s). Each art pixel is 1 screen px (`pixel_scale`). The meadow runs the leaf recipe at density 0.2 and tints open-sky leaves and litter green (`ambient_leaf_color`), while the red forest keeps the full autumn cloud.
- **World-space, not screen-space** (T-0093 round 3): `biome_particles.gd` copies `get_canvas_transform()` into the `CanvasLayer.transform` every frame and the effects spawn/recycle around the visible world rect (from the camera, not the player). Walking scrolls the particles with the terrain instead of dragging them; the ground is `ground_y_at()` per tile column, sampled every 0.1 s. Without a generator (dungeon) the bottom of the view is the ground.
- **Ground layers**: the leaf recipe's litter is generated deterministically per 18 px world slot (shape/palette/angle from a hash), so it never slides; the snow recipe's drift is drawn with `_draw()` from a per-pixel ground line and the same colours (#e9f0ff/#c3cff0/#8e9ccc). Leaves and the two near snow layers land and rest 1–5 s; leaves now dissolve pixel by pixel, the near snow layers keep their short fade, and background flakes vanish on contact.
- **Per-pixel snow drift** (2026-11-26, T-0096): the ground is sampled once per 16 px tile (`GROUND_STEP`), and `_draw()` paints the drift one world pixel at a time, like the first version: no full-width tile bands. The cap follows the stepped ground and takes its height (3–7 px) from a broad low-frequency noise, so the surface undulates without the dense 1 px spikes that used to read as lines at 4x. At a block edge it ends on the upper ledge and restarts on the lower one, with no diagonal seam. Resting flakes also use `_ground_at()`. With **Enhanced VFX physics** the player's footprint compresses the cap to 1 px and leaves a low trail that lasts 3.5 s after leaving, then fades back. Without the toggle it keeps its normal height.
- **Gradual particle quantity and flat-edge snow cap** (2026-11-26, T-0097): `WorldGenerator.ambient_amount_at_world_x()` returns the raw 0..1 share of the ±`biome_transition_tiles` window for particles, and `ambient_density_at_world_x()` blends the biomes' density over that same window. Leaves and snowflakes therefore grow and shrink in count through the transition instead of switching at 0.8; a failed roll still hides the particle for one fall + rest cycle. The snow blanket keeps a hard 0/1 edge (`ambient_share_at_world_x` at `AMBIENT_SHARE_CUTOFF`), but `_snow_cover_columns()` extends that edge left and right over flat ground until the surface height changes, so the cap stops on a step instead of a vertical seam. Leaves re-scatter across the new view after a teleport (KP4/KP6, door, spawn) instead of every culled particle falling from the top in a wave, and crowns take turns so one tree never dumps a pile while the rest stay quiet (T-0093 round 6).
- **Mirrored attack boxes (2026-11-26, T-0098)**: `EnemyBase._collision_rect()` and `Player._shape_rect()` normalize the rectangle size with `absf` because enemy `attack_range` nodes live under `flip_pivot`, whose `scale.x` is `-1` when facing left. A negative-size `Rect2` is rejected by `get_center()`/`has_point()`, so every attack near leaves spammed the debugger with thousands of errors. `_lift_rect()` also sanitizes incoming rectangles with `Rect2.abs()` as a defensive fallback. The visual side of the interactive leaves is unchanged.
- **Interactive leaves and pixel dissolve (2026-11-26, T-0096)**: every living crown takes part in the round-robin, but only about 35 % of normal recycling leaves are born under a crown; the rest fills the open sky. The initial fill and the post-teleport scatter disable canopy spawning entirely, so a TP cannot pile leaves on the visible trees. `VfxSettings` (autoload) owns `[vfx] leaves` and `[vfx] enhanced_physics` in `user://settings.cfg`; `SettingsPanel` adds **Leaf particles** and **Enhanced VFX physics**, and the bush bursts obey the same leaf toggle. The player and enemies brush the leaves through `hurt_rect()`, and the active sword/enemy `attack_rects()` lift the ones inside the box (up to 4 per hit with a short cooldown; running brushes at most 2 per batch). Their lateral push comes from the movement direction or the hitbox side, not only upward. Ground litter lives 18–34 s, gains 5 s and cancels its dissolve when touched. Removal uses `assets/vfx/spritefusion/leaf_dissolve.gdshader`: a per-texel hash discards random pixels as `dissolve` grows, so leaves never fade as a whole.
- Blood (2026-11-26, T-0094): `scripts/fx/spritefusion_blood.gd` ports Sprite Fusion's free MIT `blood` recipe (source in `assets/vfx/spritefusion/blood.ts`). One world-space node per spray draws into a 256×160 RGBA8 canvas: 7 strands grow in 90 ms, drops and a jet fly with drag and gravity, splat on `ground_y_at()` leaving stains that dry over 6 s, plus mist, drips and a 6-tone ramp derived from `blood_color`. `fx.enemy_hit()` now creates a smaller directional jet away from the player on every hit; `fx.enemy_death()` keeps its signature, a light spark burst and the camera hit, and passes direction **0**, which turns the death spray into a radial, slower, 1.6×-heavier explosion (72 drops + 20 ring drops) instead of a directional jet, so blood never flies away from the corpse. The four `CPUParticles2D` blood layers are gone.

## Bush leaves (2026-11-27, T-0103)

- `DecorProp` no longer uses the old `fx.gd` burst: it asks the Sprite Fusion ambient
  (`SpriteFusionAmbient.burst_leaves(world_position, color, amount)`) so the bush sheds the
  same leaf art as the weather. The burst reuses the ambient pool (idle leaves re-seeded on
  the spot and kicked outwards) instead of creating nodes, and it does nothing while the
  leaves toggle is off (`visible == false`).
- Entering the bush throws `leaves_per_burst` (7) and leaving throws `leaves_on_exit` (18).
- Without an ambient in the scene (dungeon test scenes) it falls back to `fx.leaves()`.

## Bush leaves in depth (2026-11-27, T-0107)

- **Fewer leaves**: `leaves_per_burst` 7 → 4 and `leaves_on_exit` 18 → 9; the burst read as
  a green cloud over the player.
- **Two layers**: `leaves_behind_share` (0.45) splits every burst. The front part still goes
  to the `biome_particles` ambient (CanvasLayer 5, over everything); the behind part goes to
  the new `behind_leaves` node, a `SpriteFusionAmbient` child of `map` placed **before the
  chunks**, so it draws over the terrain but behind the bushes (bushes are their chunk's
  first child). `DecorProp._back_ambient()` finds it by name.
- That layer has `rain = false`: `SpriteFusionAmbient` builds only the pool, parks every leaf
  hidden (`_hide_leaf()`, `wait = INF`) and `_scatter()`/`_reset_leaf()` never spawn weather in
  it. `burst_leaves()` accepts parked leaves (it only skips the ones already in the air), and
  `burst_z = 0` keeps them from jumping in front of the foliage. `density` 0.35, `rng_seed` 21.
- **Trailing leaves**: the behind part is born at the player's body (`_behind_origin()`,
  `behind_leaves_follow_player`), so while he walks away they keep falling on him for a moment
  instead of all at the crown. The front part keeps the crown.
- **More physics**: `burst_force` (112, `BURST_FORCE` as the script default) and a wider
  lateral/upward roll (`±1.2 * force`, `0.55–1.2 * force`, spin ±8) make the leaves travel a
  little further and bounce before resting.
- The `Single leaf toggle` still wins: with leaves off (`ambient.visible == false`) neither
  layer throws anything.
