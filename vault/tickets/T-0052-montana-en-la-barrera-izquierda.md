# T-0052 · Montaña en la barrera izquierda en vez de vacío

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0044, T-0049, T-0051 |

## Petición

`humano-ruben`: la barrera de la izquierda deja ver el vacío (el terreno de chunk 0
termina en el tile 0 y a su izquierda no hay nada pintado). Quiere una **gran montaña**
en su lugar: al principio se puede escalar un poco, pero es tan alta que no se puede
subir, y así la barrera queda camuflada.

## Plan

1. `WorldChunk.paint()` acepta `left_heights` y pinta esas columnas en X local negativo.
2. `WorldGenerator` construye 56 columnas (`left_wall_tiles`) a la izquierda del tile 0:
   arranca en `base_height`, 2 pasos de 1 tile (`left_wall_climb_tiles`, que el auto
   step-up sube andando) y después 4 filas por columna (`left_wall_step_rows`) hasta
   `min_height`, donde se queda.
3. La pared no pasa por el tope de ±1: es una barrera, no terreno generado.
4. El tope del jugador pasa del tile 0 a la última columna pintada.

## Criterios de aceptación

- [x] No queda corte plano ni vacío a la izquierda: 56 columnas pintadas hasta x −896.
- [x] Los 2 primeros escalones se suben andando; el resto son paredes de 4 filas
      (64 px) que no se saltan (`jump_velocity` −340 y `gravity` 1400 → ~41 px).
- [x] La cresta queda en `min_height` (fila 5), muy por encima de la pantalla.
- [x] El jugador sigue sin poder salir del terreno pintado.
- [ ] F5 en editor.

## Resultado

`scripts/world/chunk.gd`: `paint()` recibe `left_heights` y pinta las columnas negativas
con el tono de hierba de la primera columna. `scripts/world_generator.gd`: grupo nuevo
`Left wall` (`left_wall_tiles` 56, `left_wall_climb_tiles` 2, `left_wall_step_rows` 4),
`_left_wall_heights()` y `_left_wall` cacheado; solo chunk 0 lo pinta.
`_keep_player_inside_world()` para al jugador en la última columna pintada (−880 px) en
vez de en `TILE_SIZE`.

Comprobado con script headless desechable sobre `scenes/game.tscn`: 56 columnas pintadas
de −56 a −1, la de −1 en fila 49 (base 50), subida máxima de 4 filas y 10 tramos de 4,
cresta plana en fila 5 desde −37; un jugador colocado en −5000 px acaba en −880 px.
F5 pendiente.
