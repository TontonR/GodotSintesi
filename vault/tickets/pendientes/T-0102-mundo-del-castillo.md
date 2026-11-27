# T-0102 · Mundo del castillo: escena limpia, sin fugas y pisos alineados

| Campo | Valor |
|---|---|
| Estado | `abierto` |
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

Pendiente, y es lo que queda del ticket:

- **"El mundo está abajo y congelado" al salir.** No está arreglado. `_close_dungeon()` restaura
  `process_mode` y llama a `refresh_chunks()`, pero sin F5 no se ha podido reproducir si el
  fallo es el refresco de chunks, la cámara quedándose con la Y del castillo o el jugador
  cayendo antes de que el chunk esté montado. Hay que reproducirlo antes de tocar nada más.

