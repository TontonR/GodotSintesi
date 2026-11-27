# T-0089 · Salida de la mazmorra sin regenerar el mapa entero

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0079, T-0087, T-0088 |

## Problema

Salir de la mazmorra (`DungeonLayer._close_dungeon()` → `refresh_chunks()`) congela el
juego, y el tirón crece con la distancia recorrida desde el spawn.

## Causa

`WorldGenerator._update_chunks()` calcula `first`/`last` con
`Camera2D.get_screen_center_position()`. La cámara del jugador tiene `smoothing_enabled`,
así que tras el teletransporte de salida sigue en la mazmorra (origen) mientras el jugador
ya está a N tiles: `first` se recorta a 0 y `last` se amplía hasta el chunk del jugador,
ó sea que un solo frame genera todos los chunks desde el inicio. Medido en headless a
200 000 px: **49 chunks (0..48) sin guarda; 5 chunks con guarda (140 ms)**.

## Plan

1. En `_update_chunks()`, si el centro de cámara está a más de media vista +
   `load_margin_px` del jugador, usar la X del jugador.
2. Actualizar `docs/world.md` y `docs/dungeon.md`.
3. Comprobar en headless que la salida solo carga la ventana de chunks.

## Criterios de aceptación

- [x] Salir de la mazmorra lejos del spawn no regenera los chunks intermedios.
- [x] El caso normal (cámara siguiendo al jugador) no cambia.
- [x] `docs/world.md` actualizado.
- [x] Entrada en `changelog.md`, `bitacora.md` y `estado.md`.

## Resultado

Hecho el 2026-11-24 (`buffy`) en `test/fusion-structure`.

- `scripts/world_generator.gd` (`_update_chunks`): guarda de cámara obsoleta. También
  cubre los teletransportes del debug (KP4/KP6) y la carga tras restaurar partida.
- Medido con `_exit_bench.gd` (headless, borrado después): cámara en 868 px y jugador en
  200 000 px, `refresh_chunks()` carga 5 chunks en 140 ms; sin la guarda el rango era
  0..48 (49 chunks × ~16 enemigos).
- Falta el F5 de Ruben: entrar/salir lejos y comprobar que la salida no da tirón.
