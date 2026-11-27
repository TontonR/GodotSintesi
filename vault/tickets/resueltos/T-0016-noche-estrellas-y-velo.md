# T-0016 · Noche: estrellas, montañas oscuras y velo del 10%

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-11-03) |
| Tipo | `feat` (arte/ambiente) |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world / ciclo día-noche |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `scripts/world/day_night.gd`, `docs/world.md` |

## Pedido

Poner estrellas en la noche, que las montañas se vean bastante más oscuras y añadir encima de toda la pantalla un negro al 10% para que todo parezca algo más oscuro sin molestar.

## Hecho

- `_night_factor_at()` devuelve 0 (día) → 1 (noche) con el mismo fundido de 12 s que el color del cielo; los tres efectos nuevos cuelgan de ese factor.
- Estrellas: clase interna `StarField` (`Control._draw` con `draw_rect`), en un `CanvasLayer` `layer = -1` para que queden detrás del mundo y del parallax. 110 estrellas de 2 px, semilla fija 20261103, repartidas en el 90% superior. Su alfa es el factor de noche, así que aparecen con el fundido.
- Montañas: `mountains_path` (`../mountains`) recibe `modulate` interpolado de blanco a `mountain_night_tint` `Color(0.33, 0.36, 0.52)`. El resto del parallax no se toca.
- Velo: `ColorRect` negro en un `CanvasLayer` `layer = 11` (por encima del `UILayer`, que está en 10), `night_veil_alpha` 0.1 × factor de noche, `mouse_filter = IGNORE` para no tragarse clics.
- Nada de `CanvasModulate`: los tiles, los sprites y el HUD mantienen su color, deque el velo es lo único que los tiñe y solo un 10%.

## Resultado

La noche se ve con cielo oscuro, estrellas, montañas mucho más apagadas y un velo tenue sobre todo. Todo exportado en el inspector del nodo `day_night` (`star_count`, `star_size`, `star_color`, `mountain_night_tint`, `mountains_path`, `night_veil_alpha`); poner `star_count = 0` o `night_veil_alpha = 0` desactiva cada efecto sin tocar código.
