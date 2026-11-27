# T-0102 · Mundo del castillo: escena limpia, sin fugas y pisos alineados

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `bug` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0079 · T-0095 · T-0100 |

## Petición

> He comunicado en reiteradas ocasiones que cuando entras al castillo debe ser en otra
> escena, pero al tepearte con 6 se bugea todo: sales de la estructura y descubres que el
> mundo está abajo congelado. Además, dentro del castillo siguen estando las partículas de
> caminar con el color del bioma. Escena LITERALMENTE VACÍA sin nada más que la estructura.
> Por cierto, los pisos a partir de ahora estarán uno encima del otro, pero de manera
> escalonada: la puerta de salida y la de entrada estarán siempre en el mismo eje X.

## Problemas a arreglar

1. **Fuga al salir**: el mundo aparece "abajo y congelado" al volver del castillo.
2. **Partículas de caminar con el tinte del bioma** dentro del castillo.
3. **Escena limpia**: dentro solo debe estar la estructura (sin parallax, sin mundo).
4. **Pisos alineados**: entrada y salida en la misma X en todas las plantas, apilados y
   escalonados.

## Criterios de aceptación

- [ ] Al salir del castillo vuelves exactamente al sitio y el mundo sigue vivo (se genera,
      se mueve y se puede jugar) sin reiniciar la partida.
- [ ] Dentro no se ve ni el mundo ni sus partículas de bioma; el polvo al caminar usa el
      tono del castillo.
- [ ] La puerta de entrada y la de siguiente planta caen siempre en la misma columna X.
- [ ] `docs/dungeon.md` actualizado.

## Resultado

En curso (2026-11-27). Hecho:

- **Puertas en la misma X:** `CastleLayout` fija `ENTRY_COLUMN` (4) y `hall_width - EXIT_MARGIN`
  (5 desde el marco derecho), con la altura leída del bloque que cubre cada columna
  (`_top_at()`). Todas las plantas comparten columna de entrada y salida.
- **Partículas de caminar con color del bioma:** el polvo sale de `Fx.dust()`, que muestreaba
  `biome.grass_color` con la X del castillo. Ahora `DungeonLayer` fija `fx.dust_color` a gris
  piedra al entrar y lo limpia al salir.
- **Escena limpia:** la escena del castillo ya se construye de cero (`dungeon.tscn` +
  `DungeonGenerator`), sin capas del mundo.

Añadido el 2026-11-27:

- **"El mundo está abajo y congelado" al salir.** `_close_dungeon()` ahora saca el castillo
  del árbol antes de `queue_free()` (no se queda pintado un frame) y termina con
  `_restore_world_view()`:
  - si la posición de vuelta está a más de 120 px sobre el suelo real
    (`WorldGenerator.ground_y_at()`), el jugador baja hasta `suelo − player_spawn_height_tiles`;
    es el caso de una partida guardada sin `world_position` o de un viaje rápido del debug
    usado dentro del castillo, que dejaban al jugador en el cielo con el mundo muy abajo;
  - `Camera2D.reset_smoothing()` para que la vista caiga en el jugador ese mismo frame;
  - si el chunk del jugador aún no está montado, `refresh_chunks()` se repite en el
    siguiente frame de idle en vez de dejar el mundo vacío.

Comprobado por lectura y con `--check-only`. **F5 pendiente** de entrar, salir y volver a
entrar.

