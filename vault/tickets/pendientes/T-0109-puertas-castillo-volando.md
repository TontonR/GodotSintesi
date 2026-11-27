# T-0109 · Las puertas del castillo no pueden quedar en el aire

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `bug` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0100 · T-0102 |

## Problema

Las puertas negras para subir de piso (`Exit` en `scenes/structures/dungeon.tscn`) aparecen a
veces **volando**: la base queda 4 tiles (128 px) por encima del suelo y el jugador tiene que
caer al fondo del marco para alcanzarlas. Pasa en algunas plantas y semillas, no en todas.

## Causa / contexto

`CastleLayout.build()` genera bloques de suelo en un bucle que acaba con
`while cursor_x < interior_end - 8`, y su guarda `remaining - block_width < 6` acepta un resto
de exactamente 6 columnas: el último bloque puede terminar en la 56 y dejar 57..62 sin suelo
sobre `bottom_row`. La puerta de salida está fijada en la columna 59 (T-0102), así que
`_top_at()` no encuentra bloque, cae al respaldo `MAX_BLOCK_TOP` (17) y `_place_exit()` coloca
la puerta en la fila 17 en lugar de la 21.

## Plan

1. Extender el último bloque hasta `interior_end + 1` al salir del bucle, antes de calcular
   `exit_cell`.
2. Helper `_cover_interior()` idempotente, con el comentario de por qué existe.
3. `docs/dungeon.md`.

## Criterios de aceptación

- [x] La puerta de salida apoya siempre en el bloque que cubre su columna.
- [x] No hay hueco de suelo entre el último bloque y el marco derecho.
- [x] Las plantas que ya llegaban al marco no cambian.
- [x] `docs/dungeon.md` actualizado.

## Resultado

Hecho el 2026-11-27 por `buffy`. `CastleLayout._cover_interior()` estira el último bloque de
`blocks` hasta `interior_end + 1` justo después del bucle; `_top_at()` encuentra bloque en
todas las columnas interiores y la puerta vuelve a apoyar en el suelo, igual que el respaldo
de `_ground_top()` para cajas, monedas y arqueros. Fichero: `scripts/structures/castle/castle_layout.gd`.
Comprobado por lectura, **sin F5**: falta ver la puerta en el editor.
