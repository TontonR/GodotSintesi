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
- Cámara: `Camera2D` `offset (60,-70)`, `process_callback` física (0). Cada frame se redondea su `global_position` a píxel entero: con `snap_2d_transforms_to_pixel` el mundo y el parallax se desplazan en píxeles exactos y no tiemblan (medido: `canvas_transform` siempre entero). La Y se mueve como mucho 6 px/frame cuando el salto es de un escalón (`is_on_floor` y ≤ 18 px), así subir 1 tile tarda 3 frames y la vista no se sacude.

## Combate

- Click izquierdo: combo `attack_1/2/3`, `combo_window` 0.35 s, `hitbox_damage` 20.
- Click derecho o E: guardia (-15 + -20/s); bloquea daño frontal (`from_front`).
- Vida `max_health` 100: `take_damage()`, `heal()`; `_die()` es placeholder (respawn lleno).
- Monedas: `current_coins`, `initial_coins`.

## Trampas

- Giro con `sprite_pivot.scale.x`, nunca `flip_h`: con `flip_h` los pies se desplazan por el padding de la espada.
- El movimiento se lee con `Input.is_key_pressed` en crudo, no con la acción `movement` de `project.godot`.
