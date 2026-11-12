# T-0054 · El viaje rápido del numpad aterriza sobre el terreno

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `debug` |
| Prioridad | `baja` |
| Dueño | `buffy` |
| Sistema | debug |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0015, T-0052, T-0053 |

## Petición

`humano-ruben`: KP4/KP6 no deben subir un número fijo de tiles respecto a la posición
actual, sino dejar al jugador **un poco por encima del terreno** en el destino.

## Plan

1. `WorldGenerator.ground_y_at(world_x)`: fila superior de la columna en píxeles, usando
   `_height_at()`, que ya devuelve la altura de la montaña de la izquierda en tiles
   negativos (T-0052) y `base_height` si la barrera está desactivada.
2. `DebugTools._teleport()` calcula el destino en X y pone la Y en suelo −
   `teleport_above_ground_tiles` (4), en vez de sumar `-teleport_lift_tiles` (10) a la Y
   actual.
3. Tras mover, `refresh_chunks()` para que el terreno del destino exista en el mismo frame
   y no caiga a través del suelo durante un frame.

## Criterios de aceptación

- [x] KP6 y KP4 dejan al jugador a 4 tiles del suelo del destino, esté donde esté al pulsar.
- [x] No acaba dentro de una ladera ni cae al vacío al cruzar la barrera izquierda.
- [x] La cámara sigue sin arrastrar el salto (`_cam_y` lo resetea `debug_teleport`).

## Resultado

`WorldGenerator.ground_y_at(world_x)` (fila superior de la columna en píxeles) y
`_left_wall_height_at()` para tiles negativos, que `_height_at()` usa ya. `DebugTools`:
`teleport_lift_tiles` (10) pasa a `teleport_above_ground_tiles` (4) y `_teleport()`
calcula el destino en X, pone la Y en suelo − 4 tiles y llama a `refresh_chunks()` para
que el terreno exista en el mismo frame.

Comprobado con script headless sobre `game.tscn` enviando KP6/KP4 al nodo `debug_tools`:
KP6 desde el spawn (tile 50 → 114.5, hueco 4.00 tiles), KP6 otra vez (tile 178.5,
hueco 4.00), KP4 de vuelta (tile 114.5, hueco 3.96) y KP4 contra la pared izquierda
(tile −52 sobre la cresta de la fila 5, hueco 3.92 tras un frame de caída). F5 pendiente.
