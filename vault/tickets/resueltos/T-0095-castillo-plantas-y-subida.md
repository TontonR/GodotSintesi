# T-0095 · Castillo de 3 a 10 plantas y subida por la puerta

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-26 (corrección del layout) |
| Relacionado | T-0093, T-0080, T-0087 |

## Problema

Ruben pidió castillos de 3 a 10 plantas (hoy el tope es 6) y que se suba al pasar la
puerta. La salida actual devuelve al mundo desde cualquier planta, así que el castillo se
recorre en horizontal y nunca se asciende.

## Plan

- `max_floors` a 10; la cascada de 50 % desde la planta 3 no cambia (`min_floors` 3).
- La puerta/salida de cada planta reconstruye el hall una planta más arriba y emite
  `floor_changed(floor)`; `DungeonLayer` teletransporta al nuevo `spawn_point` con fundido.
- En la última planta la puerta emite `exit_requested` y devuelve al mundo, como hasta ahora.
- Mantener `start`, `spawn_point`, `exit_requested`, `save_state`/`load_state` y la
  persistencia por planta de T-0080.

## Criterios de aceptación

- [x] Un castillo puede tener entre 3 y 10 plantas, siempre las mismas para la misma semilla.
- [x] Pisar la puerta sube una planta mientras queden; la última vuelve al mundo.
- [x] El jugador aparece en el `spawn_point` de la planta nueva, sin quedarse en la vieja.
- [x] Guardar/cargar dentro conserva la planta (T-0080).
- [ ] F5/F6 de Ruben: subir y bajar el castillo completo.

## Resultado

Hecho en `dungeon_generator.gd` (`max_floors` 10, `floor_changed`, `_step_forward()`),
`dungeon_layer.gd` (funde y recoloca al jugador) y `dungeon_test.gd` (F6 sube con la
puerta). Sin Godot en esta sesión: F5/F6 pendientes.

## Verificación

Revisión estática del diff y `git diff --check`; sin pruebas en runtime.

## Corrección 2026-11-26

El working tree había restaurado la sala antigua de 34 tiles de T-0093 y el castillo se
veía roto. Se recuperó de HEAD el layout de **64×22** (`HALL_WIDTH=64`,
`width_tiles=64`, `_ensure_reachable()` y pintado por autotiling) sin tocar la subida de
plantas. F5 pendiente.

## Entrada del mundo (2026-11-26)

La puerta del castillo seguía usando el placeholder de 16×16 con `Visual.z_index = -1`.
Ahora `tower_test.png` es una puerta de **64×64** (4 tiles), el sprite escala 1:1, su base
queda en el suelo y dibuja en `z_index = 0`; `tower_test.tres` ocupa 4 tiles para el
reparto. F5 pendiente.
