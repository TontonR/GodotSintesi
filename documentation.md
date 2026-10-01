# Documentación del Proyecto - test (Godot 4.7)

## 1. Visión General
Proyecto 2D plataforma/action en **Godot 4.7 (Forward Plus)**. Escena principal `icon.tscn:1` (uid `uid://copiyrk0io0oy`) con **mundo plano infinito**, personaje **Knight_3** con física, salto, ataque, cámara desplazada y HUD de vida.

Ejecución: `project.godot:13` `run/main_scene="uid://copiyrk0io0oy"` → abrir Godot 4.7 y dar Play.

---

## 2. Estructura de Archivos

| Archivo | Descripción | Líneas clave |
|---|---|---|
| `project.godot:1` | Configuración engine, input `movement` (A/D), `default_clear_color` cielo | `project.godot:40` |
| `icon.tscn:1` | Escena principal (packed). Contiene TileSet, SpriteFrames, nodos `game`, `player`, `TileMapLayer`, `ParallaxBackground`, `UILayer`, `Camera2D` | `icon.tscn:432` `icon.tscn:488` |
| `assets/forest_tileset_lite/Sprites/Background/` | Sprites parallax: `sky.png` 688×211, `sky_cloud.png` 688×211, `cloud.png` 634×136, `mountain2.png` 688×127, `pine1.png` 688×148, `pine2.png` 688×199 | `icon.tscn:3-9` |
| `iconmove.gd:1` | Lógica del `CharacterBody2D` jugador: movimiento, salto, ataque, vida, pivot | `iconmove.gd:4` `iconmove.gd:32` `iconmove.gd:48` |
| `world_generator.gd:1` | Generación procedural del suelo plano | `world_generator.gd:4` `world_generator.gd:13` |
| `tilesetgrass.png` | `TileSet` 16×16 (`TileSet_yb26g` `icon.tscn:352`) atlas `1:0` hierba, `2:1` tierra, `2:2` tierra profunda | `icon.tscn:169` |
| `assets/Knight_3/*.png` | Sprites `Idle.png` 4f, `Walk.png` 8f, `Attack 1.png` 5f (128×128) | `icon.tscn:4` |
| `assets/...` | Resto de packs `Mystic Woods`, `Pixel Art Grassland` sin uso activo | - |

### Jerarquía `icon.tscn`
```
. (root implícito)
├─ game (Node2D) uid 2045042830 — contenedor lógico
├─ ParallaxBackground uid 510311040 — fondo multilayer
│  ├─ LayerSky     motion_scale 0,0    mirroring 447 → Sky (sprite 0.65, y -280)
│  ├─ LayerSkyCloud motion_scale 0.02,0 mirroring 447 → SkyCloud (0.65, y -280)
│  ├─ LayerCloud   motion_scale 0.08,0 mirroring 413 → Cloud (0.6, y -160, x 100)
│  ├─ LayerMountain motion_scale 0.15,0 mirroring 413 → Mountain (0.6, y -40)
│  ├─ LayerPine1   motion_scale 0.35,0 mirroring 447 → Pine1 (0.65, y -10)
│  └─ LayerPine2   motion_scale 0.6,0  mirroring 447 → Pine2 (0.65, y 20)
├─ UILayer (CanvasLayer) layer 10 — HUD
│  ├─ HealthBar (ProgressBar) top-right + Label "100 / 100" (rojo)
│  └─ StaminaBar (ProgressBar) justo debajo + Label "100 / 100" (verde)
├─ player (CharacterBody2D) script iconmove.gd
│  ├─ SpritePivot (Node2D) pos -5,-21 (hitbox)
│  │  └─ AnimatedSprite2D pos 14,-14 scale 0.435, SpriteFrames
│  ├─ Camera2D offset 60,-70 (nodo normal, sin lógica de script)
│  └─ CollisionShape2D pos -5,-21 size 5×17 scale 1.6
└─ TileMapLayer (TileMapLayer) script world_generator.gd — terreno
```

---

## 3. Generación de Mundo Plano

**`world_generator.gd:1`**
```gdscript
@export var world_width: int = 3000   # antes 500 → +600% más grande
@export var ground_level: int = 20    # antes 12 → 8 tiles (128px) más bajo
@export var ground_depth: int = 15
func _generate_world() -> void:       # world_generator.gd:13
	clear()
	for x in world_width:
		set_cell(Vector2i(x, ground_level), 0, Vector2i(1, 0)) # hierba
		for y in range(ground_level+1, ground_level+ground_depth):
			if y == ground_level+1: set_cell(Vector2i(x,y),0,Vector2(2,1))
			else: set_cell(Vector2i(x,y),0,Vector2i(2,2))     # tierra
	player.position = Vector2(player_x*16+8, ground_level*16-32)
```
- Eliminado `FastNoiseLite`, `height_variation`, `noise_seed` y `heights[]` → mundo **100% plano sin montañas**.
- 3000 tiles ×16 = 48.000px de ancho.
- Suelo ajustado a `y=20` para ver más cielo (combinado con cámara).

---

## 4. Jugador `iconmove.gd:1` — Física

### 4.1 Parámetros (`iconmove.gd:3`)
```gdscript
@export var move_speed: float = 130.0   # 320→160→130 (bajado bastante)
@export var acceleration: float = 750.0 # 1800→900→750
@export var friction: float = 1000.0    # 2400→1200→1000
@export var jump_velocity: float = -340.0 # -650→-340 (salto bastante menos)
@export var gravity: float = 1400.0      # 1800→1400
@export var fall_gravity_multiplier: float = 1.6 # cae más rápido
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12
```
`move_speed` y `jump_velocity` son exportables → ajustables en inspector sin tocar código.

### 4.2 Movimiento `iconmove.gd:140`
- `Input A/D` → `raw_direction ±1` → filtrado si ataca.
- Si `raw_direction` es contraria a `_facing_right` mientras `_is_attacking`, `direction=0` (`iconmove.gd:151`) → **no puede avanzar ni girar al lado contrario**.
- Si `direction !=0`: `move_toward(velocity.x, direction*effective_speed, effective_accel*delta)` con `effective_speed = move_speed*0.38` durante ataque (`iconmove.gd:155`) → camina ~49px/s, **no se para solo** salvo que sueltes tecla (aplica `friction`).
- `if not _is_attacking` para actualizar `_facing_right` (`iconmove.gd:162`) → dirección de ataque bloqueada.

### 4.3 Salto `iconmove.gd:172`
- `coyote_time` y `jump_buffer` clásicos.
- **Bloqueado al atacar** (`iconmove.gd:173` `if _is_attacking: reset buffers` ) → no puedes saltar en mitad de `attack`.
- Salto variable: soltar espacio corta `velocity.y *=0.45`.

### 4.4 Cámara `player.tscn:450`
```ini
Camera2D offset = Vector2(60, -70)
```
- La cámara es un nodo normal **sin lógica en el script**: sigue al jugador libremente en ambos ejes.
- `x=60` → personaje a la izquierda, de dónde viene el look-ahead hacia la derecha.
- `y=-70` → más cielo, menos suelo (con `ground_level=20`).
- **Eliminado** el bloqueo estilo Mario (`camera_lock_left`, `_camera_max_center_x`) y los límites de pantalla (`_clamp_to_view`, `_camera_view_half`, `_player_half_width`): el jugador ya no choca con los bordes y la cámara puede volver hacia la izquierda. Se restauró el comportamiento de `main`.

### 4.5 Fondo `project.godot:40` + `ParallaxBackground` `icon.tscn:432`
- `project.godot:40` `environment/defaults/default_clear_color=Color(0.51,0.79,0.99,1)` → solo visible si falta textura.
- `ParallaxBackground` con 6 `ParallaxLayer` (tabla jerarquía §2): todas con `motion_mirroring` horizontal → tiling infinito; `motion_scale.y=0` → no se mueven al saltar.
- **Parallax con zoom out**: cada `Sprite2D` tiene `scale` 0.6–0.65 (antes 1.0 → las montañas salían recortadas por el `Camera2D zoom 3`). `Sky`/`SkyCloud` bajados a `y=-280` para cubrir el hueco superior.
- Antes había un `SkyLayer`/`Sky ColorRect` fullscreen que sobresalía por encima del parallax → **eliminado**.

---

## 5. Animaciones `icon.tscn:97`

| Nombre | Frames | Textura | Loop | Speed | Uso |
|---|---|---|---|---|---|
| `attack` | 5 (0-510×128) | `Knight_3/Attack 1.png` | `0` (no loop) | 10 | `iconmove.gd:210` |
| `idle` | 4 (0-384×128) | `Knight_3/Idle.png` | `1` | 5 | reposo / caída |
| `movement_right` | 8 (0-896×128) | `Knight_3/Walk.png` | `1` | 10 | andar / salto ascendente |
| `run_right` | 6 (0-768×128) | `Knight_3/Run.png` | `1` | 8 | correr (con `Shift`) |
| `defend` | — | `Knight_3/Defend.png` | `1` | — | guardia (`Click Derecho` / `E`) |

Histórico: antes `idle_center` + `idle_right` duplicados (ambos 8f de Walk) → unificado a un único `idle` de 4f de `Idle.png` (`icon.tscn:114`).

`AnimatedSprite2D` `icon.tscn:357` `pos 14,-14` dentro de `SpritePivot` scale `0.435`, animación inicial `idle`.

### 5.1 Pivot en Hitbox (fix teleporte) `icon.tscn:354` `iconmove.gd:53`
Problema: textura 128×128 con padding derecho para espada. `flip_h` sobre centro de imagen movía pies 2× offset al girar.

Solución:
```ini
SpritePivot (Node2D) pos -5,-21 # = CollisionShape2D pos
  └─ AnimatedSprite2D pos 14,-14 # 9-(-5), -35-(-21)
```
```gdscript
# iconmove.gd:53
sprite_pivot.scale.x = 1.0 if _facing_right else -1.0 # rota sobre hitbox
animated_sprite.flip_h = false
```
Giro alrededor de `CollisionShape2D`, pies anclados, padding irrelevante.

---

## 6. Ataque Click Izquierdo `iconmove.gd:30`

```gdscript
var _is_attacking: bool = false # iconmove.gd:30
func _input(event): # iconmove.gd:132 y _unhandled_input:136
	if event is InputEventMouseButton and button_index==MOUSE_BUTTON_LEFT and pressed:
		_try_attack()
func _try_attack(): # iconmove.gd:206
	if _is_attacking: return
	_is_attacking = true
	animated_sprite.play("attack")
func _on_attack_finished(): # iconmove.gd:212 conectado en _ready:34
	if animation=="attack":
		_is_attacking=false
		_update_animation()
func _update_animation(): # iconmove.gd:217
	if _is_attacking: return # prioridad
	if not is_on_floor(): play(movement_right/idle)
	elif abs(velocity.x)>10: play(movement_right)
	else: play(idle)
```
- `loop=0` → `animation_finished` dispara fin.
- Durante ataque: `_update_animation` bloqueado, movimiento 38% velocidad, salto bloqueado.

---

## 7. Sistema de Vida — Explicación Detallada

### 7.1 Variables `iconmove.gd:11`
```gdscript
@export var max_health: int = 100 # vida base, editable en inspector
var health: int                    # vida actual
var health_bar: ProgressBar        # referencia UI (asignada dinámicamente)
var health_label: Label
```

### 7.2 Inicialización `iconmove.gd:32`
```gdscript
func _ready() -> void:
	health = max_health            # 100
	animated_sprite.animation_finished.connect(_on_attack_finished)
	_ensure_health_ui()            # crea/busca HUD
	_update_health_ui()            # refleja 100/100
```

### 7.3 API `iconmove.gd:38`
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
	# aquí puedes: get_tree().reload_current_scene() o animación muerte
```
Uso externo:
```gdscript
player.take_damage(15) # enemigo
player.heal(20)        # poción
player.health # leer
```

### 7.4 HUD `icon.tscn:370` + `_ensure_health_ui()` `iconmove.gd:48`
**Declarativo** (`icon.tscn:370`):
```ini
UILayer (CanvasLayer) layer 10
 └─ HealthBar (ProgressBar) anchor 1.0,0.0 offset -220/12/-12/36 (=208×24)
	 theme_override_styles/background = StyleBoxFlat_health_bg (gris 0.176 borde negro 2px radius 6)
	 theme_override_styles/fill = StyleBoxFlat_health_fg (rojo 0.86 radius 4)
	 └─ Label anchors 15 full, center, "100 / 100" font 14 blanco sombra negra
```
**Procedural fallback** (`iconmove.gd:48` `_ensure_health_ui`):
- Busca `get_parent().get_node_or_null("UILayer/HealthBar")` y `../UILayer/HealthBar` (soporta ambas jerarquías).
- Si no existe (editor lo borró), crea `CanvasLayer`, `ProgressBar`, `StyleBoxFlat` y `Label` por código con mismos valores. Así el HUD **nunca desaparece** aunque el `.tscn` se sobrescriba.
- Se llama en `_ready` antes de `_update_health_ui`.

**Por qué arriba-derecha:**
`anchor_left=1.0, anchor_top=0.0` ancla a esquina superior derecha, independiente de resolución (`project.godot:21` `aspect=expand`). `offset_left=-220` lo desplaza 220px a la izquierda del borde.

Flujo: `take_damage` → `health` → `_update_health_ui` → `ProgressBar.value` + `Label.text` → render en `UILayer` (CanvasLayer no afectado por `Camera2D` ni `zoom`).

---

## 8. Historial de Cambios (orden cronológico peticiones)

1. **Mundo plano grande** `world_generator.gd:4` 500→3000 tiles, eliminado ruido.
2. **Idle único** `icon.tscn:114` dos `idle_*` → uno `idle` 4f.
3. **Fondo azul + suelo bajo + cámara** `project.godot:40` clear_color cielo, `ground_level 12→20`, `Camera2D offset 0,0→80,-60`.
4. **Personaje a la izquierda** `Camera2D offset.x 0→80`.
5. **Ataque click izquierdo** `SpriteFrames attack` 5f `loop 0` + `iconmove.gd:206` `_try_attack`.
6. **Pivot hitbox** `SpritePivot -5,-21` + `scale.x` en vez de `flip_h` (`iconmove.gd:59`).
7. **Fix ataque bloqueado** `Sky mouse_filter=2` + doble `_input/_unhandled_input` + animación inicial `idle`.
8. **Velocidad/salto** `move_speed 320→160, jump -650→-340`.
9. **HUD vida + más lento** `max_health 100`, `UILayer/HealthBar`, `move_speed 160→130` (actual).
10. **HUD fix + ataque ralentiza/bloquea salto** `move_speed*0.38 al atacar` (`iconmove.gd:155`), `salto bloqueado` (`iconmove.gd:173`), HUD dinámico (`iconmove.gd:48`), offsets corregidos.
11. **Ataque bloquea giro** `raw_direction` filtrado + `_facing_right` bloqueado si `_is_attacking` (`iconmove.gd:151` `iconmove.gd:162`) → no se puede cambiar dirección ni moverte al lado contrario mientras atacas.
12. **Combo `attack_1/2/3`** `SpriteFrames` 3 animaciones de ataque, `loop 0`, `speed 14` en 2/3, ventana `combo_window=0.35s`.
13. **Parallax 6 capas** `ParallaxBackground` con todos los sprites de `forest_tileset_lite/.../Background` (sky, sky_cloud, cloud, mountain2, pine1, pine2), `motion_scale` 0→0.6, `motion_mirroring` horizontal.
14. **Fix fondo sobresaliente** eliminado `SkyLayer`/`Sky ColorRect` que se veía por encima del parallax; `Sky`/`SkyCloud` a `y=-280`.
15. **Zoom out del parallax** `scale 0.6–0.65` en todos los sprites + `motion_mirroring` ajustado al ancho escalado (447/413) → las montañas se ven completas con `Camera2D zoom 3`.
16. **Sistema de stamina** `max_stamina 100`, correr con `Shift` (‑10 inicial + ‑10/s, 1.7× velocidad, animación `run_right` ya existente en `SpriteFrames`), defender con `Click Derecho`/`E` (‑15 inicial + ‑20/s), regeneración +10/s, sin negatives y sin poder iniciar acciones sin stamina suficiente. `StaminaBar` verde bajo la barra de vida (`_ensure_stamina_ui()` con fallback por código).
17. **Cámara sin lock ni bounds** eliminados `camera_lock_left`, `_update_camera()`, `_clamp_to_view()`, `_camera_view_half` y `_player_half_width` → la cámara sigue al jugador en ambos ejes y el personaje no choca con los bordes de pantalla, igual que en `main`. La vida vuelve a rojo y la stamina usa verde.
18. **Test de stamina** `_stamina_test.gd` (24 comprobaciones headless) y borrado `_bounds_test.gd`.

---

## 9. Controles

| Tecla | Acción |
|---|---|
| `A / ←` | Izquierda |
| `D / →` | Derecha |
| `Espacio / W / ↑` | Salto (coyote + buffer) |
| `Shift` + dirección | **Correr** (1.7× velocidad, animación `run_right`, gasta stamina) |
| `Click Izquierdo` | Ataque (no salta, 38% velocidad, bloquea giro/dirección contraria) |
| `Click Derecho / E` | **Defender** (bloquea daño frontal, no mueve ni salta, gasta stamina) |

---

## 10. Sistema de Stamina — Explicación Detallada

### 9.1 Parámetros `iconmove.gd:11`
```gdscript
@export var max_stamina: float = 100.0            # stamina base
@export var run_speed_multiplier: float = 1.7     # velocidad al correr (130 -> 221 px/s)
@export var run_acceleration_multiplier: float = 1.3
@export var run_initial_cost: float = 10.0        # golpe inicial al empezar a correr
@export var run_drain_per_second: float = 10.0    # goteo al correr
@export var guard_initial_cost: float = 15.0      # golpe inicial al empezar a defender
@export var guard_drain_per_second: float = 20.0  # goteo al defender
@export var stamina_regen_per_second: float = 10.0
```

### 9.2 Tabla de costes
| Acción | Golpe inicial | Continuo | Nota |
|---|---|---|---|
| Correr (`Shift` + dirección) | -10 | -10/s | animación `run_right`, 1.7× velocidad |
| Defender (`Click Derecho` / `E`) | -15 | -20/s | bloquea movimiento, salto y giro |
| Atacar / saltar / quieto | 0 | 0 | +10/s de regeneración |

### 9.3 Lógica `_update_stamina()` `iconmove.gd:236`
Orden de prioridad en cada frame de física:
1. **Defender** — si ya se defendía, sigue drenando; si se acaba la stamina la guardia **se rompe sola**.
2. **Correr** — requiere `is_on_floor()`, no atacar y no defender. Al agotarse la carrera **se corta sola**.
3. **Regenerar** — `+10/s` si no se está corriendo ni defendiendo (atacar no consume, así que regenera).

### 9.4 Requisitos de stamina
- `can_run()` / `can_guard()` devuelven `false` si no hay stamina para pagar el golpe inicial → **no se puede iniciar** la acción sin stamina.
- Una vez iniciada, la acción continúa drenando hasta llegar a 0 (correr/defender no se cortan a mitad).
- `spend_stamina()` usa `maxf(stamina - amount, 0.0)` → la stamina nunca queda en negativo.
- API pública: `has_stamina(cantidad)`, `spend_stamina(cantidad)`, `restore_stamina(cantidad)`.

### 9.5 HUD
- Nodo `UILayer/StaminaBar` en `icon.tscn`, justo debajo de la vida, relleno verde (`StyleBoxFlat_stamina_fg`).
- `_ensure_stamina_ui()` + `_update_stamina_ui()` replican el patrón de la vida (busca el nodo de la escena y, si falta, lo crea por código).
- La vida vuelve a rojo (`StyleBoxFlat_health_fg`); la stamina es verde (`STAMINA_COLOR` como fallback).

---

## 11. Cómo Probar / Extender

- **Ajustar vida**: inspector `player` `max_health` o código `player.max_health=200`.
- **Ajustar stamina**: inspector `player` `max_stamina`, `run_drain_per_second`, `guard_drain_per_second`, etc.
- **Prueba automática**: `godot --headless --script _stamina_test.gd` → 24 comprobaciones de costes, regeneración, requisitos de stamina y agotamiento.
- **Daño prueba**: en consola o enemigo `get_node("../player").take_damage(10)`.
- **Cambiar HUD**: editar `icon.tscn:273` offsets o colores `StyleBoxFlat_health_*` / `StyleBoxFlat_stamina_fg`.
- **Muerte real**: editar `_die()` para `queue_free()` o `get_tree().reload_current_scene()`.
- **Añadir enemigo**: instanciar `CharacterBody2D` con `Area2D` que llame `player.take_damage`.

---

## 12. Notas Técnicas

- `AnimatedSprite2D` scale `0.435` para ajustar 128px a ~55px mundo.
- `CollisionShape2D` `RectangleShape2D 5×17` scale `1.6` → hitbox ~8×27.
- `TileMapLayer` colisión `physics_layer_0` todos los tiles con polígono 16×16.
- `UILayer` es `CanvasLayer` → no sigue a `Camera2D`; `ParallaxBackground` sí, pero con `motion_scale` reducido.
- Editor puede sobrescribir `icon.tscn`; `_ensure_health_ui()` y `_ensure_stamina_ui()` evitan pérdida de HUD.
- Si cambias el `scale` de un sprite del parallax, recalcula `motion_mirroring = ancho_textura * scale` de su `ParallaxLayer` para que el tiling no deje huecos.
- La animación `run_right` (8 frames de `Run.png`, loop, speed 8) ya existía en `player.tscn`; solo había que dispararla.
- La cámara no tiene lógica en el script: para cambiar el comportamiento de límites usa las propiedades `limit_*` del nodo `Camera2D` en el editor.

*Última actualización: sistema de stamina completo (correr -10 inicial/-10s, defender -15 inicial/-20s, regen +10/s), HUD StaminaBar verde, cámara sin lock ni bounds (como en `main`).*
