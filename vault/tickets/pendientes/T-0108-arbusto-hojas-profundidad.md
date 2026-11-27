# T-0108 · Hojas del arbusto: menos, en dos planos y con más física

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0103 · T-0093 · T-0096 |

## Petición

> Que los arbustos no generen tanta hoja, que una parte salga delante y otra detrás del
> arbusto y que esta se genere donde el jugador para que le siga un poco más; subir un poco
> el movimiento por físicas.

## Contexto

T-0103 dejaba 7 hojas al entrar y 18 al salir, todas en la capa `biome_particles`
(CanvasLayer 5): siempre delante del arbusto, todas desde la copa y con un abanico corto.

## Plan

1. Bajar los recuentos a 4 (entrar) y 9 (salir).
2. `SpriteFusionAmbient.rain = false` + `_hide_leaf()`: piscina que solo usan los estallidos.
3. `burst_z` para que la capa de detrás se quede en z 0.
4. `map/behind_leaves` en `game.tscn`, antes de los chunks, para dibujar tras el arbusto.
5. `DecorProp._emit_leaves()` reparte el estallido (`leaves_behind_share` 0.45) y lanza la
   parte de detrás desde el jugador (`behind_leaves_follow_player`).
6. `burst_force` 112 y abanico lateral/vertical más amplio.

## Criterios de aceptación

- [x] Menos hojas por estallido.
- [x] Una parte delante y otra detrás del arbusto.
- [x] La parte de detrás sale donde está el jugador.
- [x] Más recorrido por físicas.
- [x] `docs/fx.md` y `docs/decor.md` actualizados.

## Resultado

Hecho el 2026-11-27 por `buffy`. Ficheros: `scripts/world/decor_prop.gd`,
`scripts/world/spritefusion_ambient.gd`, `scenes/game.tscn`. La capa de detrás es
`map/behind_leaves` (`SpriteFusionAmbient`, `rain = false`, `burst_z = 0`, `density` 0.35,
`rng_seed` 21): se dibuja después del terreno y antes de los chunks, así que el arbusto
(primer hijo de su chunk) la tapa. `burst_leaves()` acepta hojas aparcadas con `wait = INF`.
`_behind_origin()` usa la posición del jugador con el arbusto como respaldo. Comprobado por
lectura, **sin F5**: falta ver los dos planos en el editor.
