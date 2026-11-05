# Jugador — movimiento, combate, vida y stamina

_2026-10-20 · rama `feat/skills-and-complex-passives`_

## Qué hace y dónde vive

- `scripts/player.gd` sobre `CharacterBody2D` en `scenes/player.tscn`; está en el grupo `player` (los enemigos lo detectan por ahí).
- Escala ×2: ≈56 px de alto, collider 16×54 (el origen queda ~27 px sobre los pies).
- HUD en `UILayer` (`HealthBar`, `StaminaBar`, monedas); `_ensure_health_ui()` / `_ensure_stamina_ui()` recrean las barras por código si el editor borra los nodos.

## Movimiento

- `move_speed` 130, `acceleration` 750, `friction` 1000, `jump_velocity` -340, `gravity` 1400, caída ×1.6, coyote 0.1, buffer 0.12.
- Teclas leídas en crudo: A/D, salto Espacio/W. Shift = correr (1.7×, -10 + -10/s). Las flechas quedan solo para la UI (páginas de pasivas e inventario).
- Auto-subida de 1 tile (16 px) con `test_move` sobre la forma real: prueba 1 px por delante, sube 17 px y sigue con la X intacta (no frena ni bloquea el frame). El sprite se queda 16 px abajo y sube interpolado en `step_duration` (0.08 s) para que no se vea el salto. 2+ tiles se saltan.
- Atacar o defender bloquea salto y giro; atacando se mueve al 38%.
- Cámara: `Camera2D` `offset (60,-70)`, `process_callback` física (0). El objetivo de seguimiento es `player.global_position`, nunca `camera.global_position`: usar la posición previa de la cámara hace permanente el desfase del suavizado. Cada frame se redondea la posición global a píxel entero; en un salto de escalón la Y avanza hasta 6 px/frame mientras el desfase sea ≤18 px. Medido durante 1.200 frames en semillas 12345, 67890 y 20261029: desfase máximo 10.21 px, movimiento máximo de cámara 6 px/frame y desfase final tras asentarse <0.28 px. `_diag.gd` repite esta comprobación por semilla.

## Combate

- Click izquierdo: combo `attack_1/2/3`, `combo_window` 0.35 s, `hitbox_damage` 20.
- Click derecho o E: guardia (-15 + -20/s); bloquea daño frontal (`from_front`).
- Parry: `parry_window` (0,2 s) desde que se levanta la guardia. Si un golpe frontal entra dentro de la ventana, no hace daño, devuelve `parry_stamina_refund` (30) y dispara `fx.parry()` (chispas, `¡PARRY!`, destello y sacudida); la ventana se consume y el resto de la guardia bloquea normal. Al abrir la ventana suena un aviso discreto (`fx.parry_ready()`).
- Anti-spam: `parry_cooldown` (0,3 s) se suma a la ventana al abrirla (`_parry_cooldown_timer = parry_window + parry_cooldown`), así mantener o machacar el clic no encadena parries y cada intento paga la guardia (15 + 20/s). Un parry correcto también reinicia ese enfriamiento.
- Guardia y parry no empujan: `_apply_damage()` devuelve si el golpe llegó a quitar vida y `take_damage_from()` corta antes del knockback/knockup cuando no llegó.

## Estadísticas (2026-11-05)

- Base en `player.gd` (grupo «Estadísticas de combate»): `attack_speed` 1.0 (escala la animación de ataque y con ella la cadencia del combo), `crit_chance` 0,05, `crit_damage` 2.0 y `luck` 0 (puntos porcentuales de drop). La velocidad es `move_speed` (130).
- Crítico base: `_deal_damage()` hace su propia tirada después de las pasivas y multiplica por `crit_damage`; las pasivas tipo `amuleto_critico` siguen tirando aparte. Un crítico se anuncia en `fx.enemy_hit(..., critical)` con más chispas doradas, número de 12 px y sacudida corta.
- Suerte: `EnemyBase._luck_drop_bonus()` suma `luck × 0,01` a cualquier `drop_chance` del loot (con 0 no cambia nada).
- API para pasivas: `add_attack_speed()`, `add_crit_chance()`, `add_crit_damage()`, `add_luck()`.
- Panel `UILayer/StatsPanel`: `GridContainer` de 2 columnas creado por `_ensure_stats_ui()` a la izquierda (5 px, 26 px, bajo los consumibles), siempre visible, `modulate` alpha 0,6 y fuente 9 con sombra. Se refresca con `_stats_dirty` (`_update_stats_ui()`) cuando cambian `attack_speed`, `crit_*`, `luck` o `move_speed`.
- Vida `max_health` 100: `take_damage()`, `heal()`; `_die()` es placeholder (respawn lleno).
- Empuje de enemigos: `take_damage_from(amount, attacker_pos, knockback, lock, knockup)` aplica daño y, si no lo bloquea la guardia, `apply_knockback()` / `apply_knockup()`. Mientras dura `lock` (0.12–0.15 s) se ignora el input horizontal.
- `is_guarding()` para las áreas enemigas que distinguen bloqueo (fuego del demonio).
- El cuerpo del jugador solo colisiona con el mundo (`collision_mask` 1): atraviesa a los enemigos, no se sube encima. El daño y los golpes van por `Area2D`.
- Monedas: `current_coins`, `initial_coins`.

## Caída inicial (2026-11-03)

- Tres variables públicas que maneja `scripts/world/fall_intro.gd`: `control_enabled` (false = sin input, salto, ataque ni guardia), `camera_follow_enabled` (false = la cámara no sigue) y `fall_speed_cap` (tope de caída en px/s, 0 = sin tope).
- Con `control_enabled = false`, `_physics_process` corta antes de stamina/combate: frena la X, aplica gravedad ×1.6, limita la Y y hace `move_and_slide()`. La animación se sigue actualizando.
- Por defecto las tres quedan en su valor normal (`true`, `true`, `0`): fuera de la intro el jugador se comporta igual que antes.

## Debug (temporal, 2026-11-03)

- `scripts/debug_tools.gd` (`DebugTools`, nodo `debug_tools` en `game.tscn`): KP7/KP8/KP9 fijan `Engine.time_scale` a x1/x5/x20 y KP4/KP6 hacen un viaje rápido de 64 tiles a izquierda/derecha subiendo 10 tiles (para salir de montañas). Distancias en `teleport_distance_tiles` y `teleport_lift_tiles`.
- **KP5** alterna la inmortalidad (`player.toggle_immortal()` → `immortal`): con ella activa `_apply_damage()` sale sin tocar vida; el empuje/knockback de `take_damage_from()` sigue aplicándose. El aviso de debug muestra `inmortal sí/no`. Tecla independiente de `use_slot_5` (que es la tecla 5 de la fila superior, no el numpad).
- El viaje llama a `player.debug_teleport(offset)`: mueve, corta la velocidad, borra el desfase visual de escalón y reinicia `_cam_y` para que la cámara no arrastre el salto.
- `_exit_tree` devuelve `time_scale` a 1.0: salir de la escena no deja el juego acelerado.
- Los ítems de prueba (KP0-KP3) viven aparte, en `scenes/inventory/inventory.gd` (ver `docs/items.md`).

## Trampas

- Giro con `sprite_pivot.scale.x`, nunca `flip_h`: con `flip_h` los pies se desplazan por el padding de la espada.
- El movimiento se lee con `Input.is_key_pressed` en crudo, no con la acción `movement` de `project.godot`.
