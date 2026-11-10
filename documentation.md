# Project Documentation - test (Godot 4.7)

> **Historical** (2026-10-20). Superseded by `docs/player.md`, `docs/enemies.md` and `docs/world.md`; kept for the long explanations. Do not load by default.

## 1. Overview
2D platform/action project in **Godot 4.7 (Forward Plus)**. Main scene `icon.tscn:1` (uid `uid://copiyrk0io0oy`) with an **infinite flat world**, **Knight_3** character with physics, jump, attack, offset camera and health HUD.

Run: `project.godot:13` `run/main_scene="uid://copiyrk0io0oy"` → open Godot 4.7 and press Play.

---

## 2. File Structure

| File | Description | Key lines |
|---|---|---|
| `project.godot:1` | Engine configuration, `movement` input (A/D), sky `default_clear_color` | `project.godot:40` |
| `icon.tscn:1` | Main scene (packed). Contains TileSet, SpriteFrames, `game`, `player`, `TileMapLayer`, `ParallaxBackground`, `UILayer`, `Camera2D` nodes | `icon.tscn:432` `icon.tscn:488` |
| `assets/forest_tileset_lite/Sprites/Background/` | Parallax sprites: `sky.png` 688×211, `sky_cloud.png` 688×211, `cloud.png` 634×136, `mountain2.png` 688×127, `pine1.png` 688×148, `pine2.png` 688×199 | `icon.tscn:3-9` |
| `player.gd:1` | `CharacterBody2D` player logic: movement, jump, attack, health, pivot | `player.gd:4` `player.gd:32` `player.gd:48` |
| `world_generator.gd:1` | Procedural generation of the flat ground | `world_generator.gd:4` `world_generator.gd:13` |
| `tilesetgrass.png` | 16×16 `TileSet` (`TileSet_yb26g` `icon.tscn:352`), atlas `1:0` grass, `2:1` dirt, `2:2` deep dirt | `icon.tscn:169` |
| `assets/Knight_3/*.png` | `Idle.png` 4f, `Walk.png` 8f, `Attack 1.png` 5f sprites (128×128) | `icon.tscn:4` |
| `assets/...` | Rest of the `Mystic Woods`, `Pixel Art Grassland` packs, not actively used | - |

### `icon.tscn` hierarchy
```
. (implicit root)
├─ game (Node2D) uid 2045042830 — logical container
├─ ParallaxBackground uid 510311040 — multilayer background
│  ├─ LayerSky     motion_scale 0,0    mirroring 447 → Sky (sprite 0.65, y -280)
│  ├─ LayerSkyCloud motion_scale 0.02,0 mirroring 447 → SkyCloud (0.65, y -280)
│  ├─ LayerCloud   motion_scale 0.08,0 mirroring 413 → Cloud (0.6, y -160, x 100)
│  ├─ LayerMountain motion_scale 0.15,0 mirroring 413 → Mountain (0.6, y -40)
│  ├─ LayerPine1   motion_scale 0.35,0 mirroring 447 → Pine1 (0.65, y -10)
│  └─ LayerPine2   motion_scale 0.6,0  mirroring 447 → Pine2 (0.65, y 20)
├─ UILayer (CanvasLayer) layer 10 — HUD
│  ├─ HealthBar (ProgressBar) top-right + Label "100 / 100" (red)
│  └─ StaminaBar (ProgressBar) just below + Label "100 / 100" (green)
├─ player (CharacterBody2D) script player.gd
│  ├─ SpritePivot (Node2D) pos -5,-21 (hitbox)
│  │  └─ AnimatedSprite2D pos 14,-14 scale 0.435, SpriteFrames
│  ├─ Camera2D offset 60,-70 (plain node, no script logic)
│  └─ CollisionShape2D pos -5,-21 size 5×17 scale 1.6
└─ TileMapLayer (TileMapLayer) script world_generator.gd — terrain
```

---

## 3. Flat World Generation

**`world_generator.gd:1`**
```gdscript
@export var world_width: int = 3000   # was 500 → +600% bigger
@export var ground_level: int = 20    # was 12 → 8 tiles (128px) lower
@export var ground_depth: int = 15
func _generate_world() -> void:       # world_generator.gd:13
	clear()
	for x in world_width:
		set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0)) # grass
		for y in range(ground_level+1, ground_level+ground_depth):
			if y == ground_level+1: set_cell(Vector2i(x,y),0,Vector2(2,1))
			else: set_cell(Vector2i(x,y),0,Vector2i(2,2))     # dirt
	player.position = Vector2(player_x*16+8, ground_level*16-32)
```
- Removed `FastNoiseLite`, `height_variation`, `noise_seed` and `heights[]` → **100% flat world with no mountains**.
- 3000 tiles ×16 = 48,000px wide.
- Ground moved to `y=20` to see more sky (combined with the camera).

---

## 4. Player `player.gd:1` — Physics

### 4.1 Parameters (`player.gd:3`)
```gdscript
@export var move_speed: float = 130.0   # 320→160→130 (lowered quite a bit)
@export var acceleration: float = 750.0 # 1800→900→750
@export var friction: float = 1000.0    # 2400→1200→1000
@export var jump_velocity: float = -340.0 # -650→-340 (much lower jump)
@export var gravity: float = 1400.0      # 1800→1400
@export var fall_gravity_multiplier: float = 1.6 # falls faster
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12
```
`move_speed` and `jump_velocity` are exported → adjustable in the inspector without touching code.

### 4.2 Movement `player.gd:140`
- `Input A/D` → `raw_direction ±1` → filtered while attacking.
- If `raw_direction` is opposite to `_facing_right` while `_is_attacking`, `direction=0` (`player.gd:151`) → **it can neither move forward nor turn to the other side**.
- If `direction !=0`: `move_toward(velocity.x, direction*effective_speed, effective_accel*delta)` with `effective_speed = move_speed*0.38` while attacking (`player.gd:155`) → walks ~49px/s, **it doesn't stop by itself** unless you release the key (`friction` applies).
- `if not _is_attacking` to update `_facing_right` (`player.gd:162`) → attack direction is locked.

### 4.3 Jump `player.gd:172`
- Classic `coyote_time` and `jump_buffer`.
- **Blocked while attacking** (`player.gd:173` `if _is_attacking: reset buffers` ) → you can't jump in the middle of `attack`.
- Variable jump: releasing space cuts `velocity.y *=0.45`.

### 4.4 Camera `player.tscn:450`
```ini
Camera2D offset = Vector2(60, -70)
```
- The camera is a plain node **with no logic in the script**: it follows the player freely on both axes.
- `x=60` → character on the left, where the look-ahead to the right comes from.
- `y=-70` → more sky, less ground (with `ground_level=20`).
- **Removed** the Mario-style lock (`camera_lock_left`, `_camera_max_center_x`) and the screen limits (`_clamp_to_view`, `_camera_view_half`, `_player_half_width`): the player no longer collides with the edges and the camera can move back left. The `main` behaviour was restored.

### 4.5 Background `project.godot:40` + `ParallaxBackground` `icon.tscn:432`
- `project.godot:40` `environment/defaults/default_clear_color=Color(0.51,0.79,0.99,1)` → only visible if a texture is missing.
- `ParallaxBackground` with 6 `ParallaxLayer` (hierarchy table §2): all with horizontal `motion_mirroring` → infinite tiling; `motion_scale.y=0` → they don't move when jumping.
- **Parallax with zoom out**: each `Sprite2D` has `scale` 0.6–0.65 (previously 1.0 → the mountains were cropped by `Camera2D zoom 3`). `Sky`/`SkyCloud` lowered to `y=-280` to cover the top gap.
- There used to be a fullscreen `SkyLayer`/`Sky ColorRect` sticking out above the parallax → **removed**.

---

## 5. Animations `icon.tscn:97`

| Name | Frames | Texture | Loop | Speed | Use |
|---|---|---|---|---|---|
| `attack` | 5 (0-510×128) | `Knight_3/Attack 1.png` | `0` (no loop) | 10 | `player.gd:210` |
| `idle` | 4 (0-384×128) | `Knight_3/Idle.png` | `1` | 5 | idle / falling |
| `movement_right` | 8 (0-896×128) | `Knight_3/Walk.png` | `1` | 10 | walking / rising jump |
| `run_right` | 6 (0-768×128) | `Knight_3/Run.png` | `1` | 8 | running (with `Shift`) |
| `defend` | — | `Knight_3/Defend.png` | `1` | — | guard (`Right click` / `E`) |

History: before there were duplicated `idle_center` + `idle_right` (both 8f of Walk) → unified into a single 4f `idle` from `Idle.png` (`icon.tscn:114`).

`AnimatedSprite2D` `icon.tscn:357` `pos 14,-14` inside `SpritePivot` scale `0.435`, initial animation `idle`.

### 5.1 Pivot on the Hitbox (teleport fix) `icon.tscn:354` `player.gd:53`
Problem: 128×128 texture with right padding for the sword. `flip_h` around the image center moved the feet 2× the offset when turning.

Solution:
```ini
SpritePivot (Node2D) pos -5,-21 # = CollisionShape2D pos
  └─ AnimatedSprite2D pos 14,-14 # 9-(-5), -35-(-21)
```
```gdscript
# player.gd:53
sprite_pivot.scale.x = 1.0 if _facing_right else -1.0 # mirrors around the hitbox
animated_sprite.flip_h = false
```
Turn around the `CollisionShape2D`, feet anchored, padding irrelevant.

---

## 6. Left-Click Attack `player.gd:30`

```gdscript
var _is_attacking: bool = false # player.gd:30
func _input(event): # player.gd:132 and _unhandled_input:136
	if event is InputEventMouseButton and button_index==MOUSE_BUTTON_LEFT and pressed:
		_try_attack()
func _try_attack(): # player.gd:206
	if _is_attacking: return
	_is_attacking = true
	animated_sprite.play("attack")
func _on_attack_finished(): # player.gd:212 connected in _ready:34
	if animation=="attack":
		_is_attacking=false
		_update_animation()
func _update_animation(): # player.gd:217
	if _is_attacking: return # priority
	if not is_on_floor(): play(movement_right/idle)
	elif abs(velocity.x)>10: play(movement_right)
	else: play(idle)
```
- `loop=0` → `animation_finished` fires the end.
- While attacking: `_update_animation` blocked, movement at 38% speed, jump blocked.

---

## 7. Health System — Detailed Explanation

### 7.1 Variables `player.gd:11`
```gdscript
@export var max_health: int = 100 # base health, editable in the inspector
var health: int                    # current health
var health_bar: ProgressBar        # UI reference (assigned dynamically)
var health_label: Label
```

### 7.2 Initialisation `player.gd:32`
```gdscript
func _ready() -> void:
	health = max_health            # 100
	animated_sprite.animation_finished.connect(_on_attack_finished)
	_ensure_health_ui()            # creates/finds the HUD
	_update_health_ui()            # shows 100/100
```

### 7.3 API `player.gd:38`
```gdscript
func take_damage(amount: int) -> void:
	health = maxi(health - amount, 0)
	_update_health_ui()
	if health <= 0: _die()

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	_update_health_ui()

func _update_health_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]

func _die() -> void:
	health = max_health            # respawn placeholder
	_update_health_ui()
	# here you can: get_tree().reload_current_scene() or a death animation
```
External use:
```gdscript
player.take_damage(15) # enemy
player.heal(20)        # potion
player.health # read
```

### 7.4 HUD `icon.tscn:370` + `_ensure_health_ui()` `player.gd:48`
**Declarative** (`icon.tscn:370`):
```ini
UILayer (CanvasLayer) layer 10
 └─ HealthBar (ProgressBar) anchor 1.0,0.0 offset -220/12/-12/36 (=208×24)
	 theme_override_styles/background = StyleBoxFlat_health_bg (grey 0.176, black 2px border, radius 6)
	 theme_override_styles/fill = StyleBoxFlat_health_fg (red 0.86 radius 4)
	 └─ Label anchors 15 full, center, "100 / 100" font 14 white with black shadow
```
**Procedural fallback** (`player.gd:48` `_ensure_health_ui`):
- Looks for `get_parent().get_node_or_null("UILayer/HealthBar")` and `../UILayer/HealthBar` (supports both hierarchies).
- If it doesn't exist (the editor deleted it), it creates `CanvasLayer`, `ProgressBar`, `StyleBoxFlat` and `Label` in code with the same values. That way the HUD **never disappears** even if the `.tscn` is overwritten.
- It is called in `_ready` before `_update_health_ui`.

**Why top-right:**
`anchor_left=1.0, anchor_top=0.0` anchors to the top-right corner, independent of resolution (`project.godot:21` `aspect=expand`). `offset_left=-220` shifts it 220px left of the edge.

Flow: `take_damage` → `health` → `_update_health_ui` → `ProgressBar.value` + `Label.text` → rendered in `UILayer` (CanvasLayer unaffected by `Camera2D` or `zoom`).

---

## 8. Change History (chronological order of requests)

1. **Big flat world** `world_generator.gd:4` 500→3000 tiles, noise removed.
2. **Single idle** `icon.tscn:114` two `idle_*` → one 4f `idle`.
3. **Blue background + lower ground + camera** `project.godot:40` sky clear_color, `ground_level 12→20`, `Camera2D offset 0,0→80,-60`.
4. **Character on the left** `Camera2D offset.x 0→80`.
5. **Left-click attack** `SpriteFrames attack` 5f `loop 0` + `player.gd:206` `_try_attack`.
6. **Hitbox pivot** `SpritePivot -5,-21` + `scale.x` instead of `flip_h` (`player.gd:59`).
7. **Fix blocked attack** `Sky mouse_filter=2` + double `_input/_unhandled_input` + initial `idle` animation.
8. **Speed/jump** `move_speed 320→160, jump -650→-340`.
9. **Health HUD + slower** `max_health 100`, `UILayer/HealthBar`, `move_speed 160→130` (current).
10. **HUD fix + attack slows/blocks jump** `move_speed*0.38 while attacking` (`player.gd:155`), `jump blocked` (`player.gd:173`), dynamic HUD (`player.gd:48`), fixed offsets.
11. **Attack locks turning** filtered `raw_direction` + `_facing_right` locked while `_is_attacking` (`player.gd:151` `player.gd:162`) → you can't change direction or move to the opposite side while attacking.
12. **`attack_1/2/3` combo** `SpriteFrames` 3 attack animations, `loop 0`, `speed 14` on 2/3, `combo_window=0.35s` window.
13. **6-layer parallax** `ParallaxBackground` with all the `forest_tileset_lite/.../Background` sprites (sky, sky_cloud, cloud, mountain2, pine1, pine2), `motion_scale` 0→0.6, horizontal `motion_mirroring`.
14. **Fix protruding background** removed the `SkyLayer`/`Sky ColorRect` that showed above the parallax; `Sky`/`SkyCloud` to `y=-280`.
15. **Parallax zoom out** `scale 0.6–0.65` on all sprites + `motion_mirroring` adjusted to the scaled width (447/413) → the mountains are fully visible with `Camera2D zoom 3`.
16. **Stamina system** `max_stamina 100`, run with `Shift` (‑10 initial + ‑10/s, 1.7× speed, `run_right` animation already in `SpriteFrames`), guard with `Right click`/`E` (‑15 initial + ‑20/s), regeneration +10/s, no negatives and no starting actions without enough stamina. Green `StaminaBar` under the health bar (`_ensure_stamina_ui()` with a code fallback).
17. **Camera without lock or bounds** removed `camera_lock_left`, `_update_camera()`, `_clamp_to_view()`, `_camera_view_half` and `_player_half_width` → the camera follows the player on both axes and the character no longer collides with the screen edges, same as in `main`. Health is red again and stamina uses green.
18. **Stamina test** `_stamina_test.gd` (24 headless checks) and deleted `_bounds_test.gd`.

---

## 9. Controls

| Key | Action |
|---|---|
| `A / ←` | Left |
| `D / →` | Right |
| `Space / W / ↑` | Jump (coyote + buffer) |
| `Shift` + direction | **Run** (1.7× speed, `run_right` animation, drains stamina) |
| `Left click` | Attack (no jump, 38% speed, locks turning/opposite direction) |
| `Right click / E` | **Guard** (blocks frontal damage, no movement or jump, drains stamina) |

---

## 10. Stamina System — Detailed Explanation

### 9.1 Parameters `player.gd:11`
```gdscript
@export var max_stamina: float = 100.0            # base stamina
@export var run_speed_multiplier: float = 1.7     # running speed (130 -> 221 px/s)
@export var run_acceleration_multiplier: float = 1.3
@export var run_initial_cost: float = 10.0        # initial hit when starting to run
@export var run_drain_per_second: float = 10.0    # drain while running
@export var guard_initial_cost: float = 15.0      # initial hit when starting to guard
@export var guard_drain_per_second: float = 20.0  # drain while guarding
@export var stamina_regen_per_second: float = 10.0
```

### 9.2 Cost table
| Action | Initial hit | Continuous | Note |
|---|---|---|---|
| Run (`Shift` + direction) | -10 | -10/s | `run_right` animation, 1.7× speed |
| Guard (`Right click` / `E`) | -15 | -20/s | blocks movement, jump and turning |
| Attack / jump / idle | 0 | 0 | +10/s regeneration |

### 9.3 Logic `_update_stamina()` `player.gd:236`
Priority order on each physics frame:
1. **Guard** — if already guarding, it keeps draining; if stamina runs out the guard **breaks by itself**.
2. **Run** — requires `is_on_floor()`, not attacking and not guarding. When stamina runs out the run **cuts out by itself**.
3. **Regenerate** — `+10/s` if not running or guarding (attacking doesn't consume, so it regenerates).

### 9.4 Stamina requirements
- `can_run()` / `can_guard()` return `false` when there is no stamina to pay the initial hit → **the action cannot start** without stamina.
- Once started, the action keeps draining until it reaches 0 (run/guard don't stop halfway).
- `spend_stamina()` uses `maxf(stamina - amount, 0.0)` → stamina never goes negative.
- Public API: `has_stamina(amount)`, `spend_stamina(amount)`, `restore_stamina(amount)`.

### 9.5 HUD
- `UILayer/StaminaBar` node in `icon.tscn`, just under health, green fill (`StyleBoxFlat_stamina_fg`).
- `_ensure_stamina_ui()` + `_update_stamina_ui()` replicate the health pattern (look for the scene node and, if missing, create it in code).
- Health is red again (`StyleBoxFlat_health_fg`); stamina is green (`STAMINA_COLOR` as fallback).

---

## 11. How to Test / Extend

- **Adjust health**: inspector `player` `max_health` or code `player.max_health=200`.
- **Adjust stamina**: inspector `player` `max_stamina`, `run_drain_per_second`, `guard_drain_per_second`, etc.
- **Automated test**: `godot --headless --script _stamina_test.gd` → 24 checks of costs, regeneration, stamina requirements and exhaustion.
- **Test damage**: in the console or from an enemy `get_node("../player").take_damage(10)`.
- **Change the HUD**: edit `icon.tscn:273` offsets or the `StyleBoxFlat_health_*` / `StyleBoxFlat_stamina_fg` colours.
- **Real death**: edit `_die()` to `queue_free()` or `get_tree().reload_current_scene()`.
- **Add an enemy**: instantiate a `CharacterBody2D` with an `Area2D` that calls `player.take_damage`.

---

## 12. Technical Notes

- `AnimatedSprite2D` scale `0.435` to fit 128px into ~55px of world.
- `CollisionShape2D` `RectangleShape2D 5×17` scale `1.6` → hitbox ~8×27.
- `TileMapLayer` collision `physics_layer_0`, every tile with a 16×16 polygon.
- `UILayer` is a `CanvasLayer` → it doesn't follow `Camera2D`; `ParallaxBackground` does, but with a reduced `motion_scale`.
- The editor can overwrite `icon.tscn`; `_ensure_health_ui()` and `_ensure_stamina_ui()` prevent losing the HUD.
- If you change the `scale` of a parallax sprite, recompute `motion_mirroring = texture_width * scale` on its `ParallaxLayer` so the tiling leaves no gaps.
- The `run_right` animation (8 frames of `Run.png`, loop, speed 8) already existed in `player.tscn`; it only had to be triggered.
- The camera has no logic in the script: to change the limit behaviour use the `limit_*` properties of the `Camera2D` node in the editor.

*Last update: enemy refactor (EnemyBase + Ghost) on branch `refactor/base_enemies`.*

---

## 13. Enemy System (`EnemyBase` + children)

### 13.1 `scripts/enemies/enemy_base.gd` — base class
`CharacterBody2D` with generic AI: chase → attack (melee or projectile) → optional flee → loot on death.

| Export group | Key content |
|---|---|
| Basic Stats | `max_health`, `base_attack`, `base_defense`, `speed_movement`, `attack_cooldown` |
| Enemy Config | `flying_enemy` (no gravity, X+Y), `ranged_enemy` + `projectile` / `projectile_speed` / `projectile_spawn`, `flee_enemy` + `flee_area` |
| Attack | `attack_impact_delay` (impact), `attack_duration` (lock) |
| Loot | `loot_table: Array[LootDropItem]`, spreads |
| Nodes | `sprite`, `detection_area`, `attack_range`, `flip_pivot` |
| Animations | `idle_animation`, `move_animation`, `attack_animation`, `sprite_faces_right` |

**Hooks for children** (override):
- `_update_behavior(delta)` — priority flee > attack > chase
- `_start_attack()` / `_perform_attack()` / `_chase` / `_flee`
- `_on_death()` — `queue_free()` by default
- `_refresh_area_flags()` — revalidates `attack_range` / `flee_area` (useful after TPs)

**Attack flow**: `_start_attack` waits `attack_impact_delay` → `_perform_attack` (projectile or melee) → waits out the rest of `attack_duration`.

### 13.2 `scripts/enemies/ghost.gd` — flying ghost
Extends `EnemyBase`. No state machine; it uses the base hooks.

| Export | Default | Description |
|---|---|---|
| `charge_time` | 0.4s | Time in range before firing |
| `tp_cooldown` | 4s | Teleport cooldown |
| `post_attack_tp_delay` | 0.5s | Extra TP blocked after each attack (added to the cooldown) |
| `tp_zone_margin` | 10px | Margin outside flee / inside attack |
| `tp_min_travel` | 80px | Minimum distance between the last TP and the new one |
| `tp_attempts` | 12 | Random attempts (×20 safety net in the loop) |
| `invulnerable_while_teleporting` | true | No damage during the TP |

**Behaviour**:
1. **Flee** = only try to TP to the attack zone. If it can't (cooldown / no position), it **doesn't run**: it stays and keeps attacking.
2. **TP** is computed from the player's position, on the elliptical ring between `flee_range` and `attack_range` (rx ≠ ry). Never above the player (`offset.y >= 0`).
3. **Search**: precondition `attack > flee + 2×margin` on both axes; then it retries until `tp_min_travel` is met (safety cap `tp_attempts × 20`).
4. **No TP during an attack**; when a normal attack ends: lockout `tp_cooldown + post_attack_tp_delay`. The "hold the ground" attacks don't reset the full cooldown.
5. Invulnerable while playing `vanish`/`appear`.

**Scene** `scenes/enemies/ghost.tscn`:
- Elliptical areas: `attack_range` scale ≈ 0.6×0.45, `flee_range` ≈ 0.35×0.25 (same `CircleShape2D`)
- `Pivot/SpawnPoint` for the projectile
- The projectile export is called **`projectile`** (not `projectile_scene`)

### 13.3 `scripts/enemies/orc.gd` — ground melee
Minimal child example: just `_init` with stats and node autodetection in `_ready` (~28 lines). No gravity off, body-to-body melee.

### 13.4 How to add a new enemy
1. Create a `CharacterBody2D` scene with a script `extends EnemyBase` (or an existing child).
2. Add `AnimatedSprite2D`, `detection_area`, `attack_range` (+ `flee_area` / projectile if needed).
3. Assign the exports in the inspector or in `_init()` as `orc.gd` does.
4. The player must be in the **`player`** group to be detected.
