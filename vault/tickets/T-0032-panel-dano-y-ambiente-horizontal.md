# T-0032 · Daño en el panel y partículas de ambiente más anchas

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | ui / world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0031, T-0028 |

## Problema

- El panel de estadísticas no muestra el daño de ataque y, en `position (5, 26)`,
  su última fila pisa la línea de monedas (`UILayer/coins`, y≈63).
- Las partículas de ambiente solo cubren de −10 % a 110 % del ancho de pantalla:
  cuando las hojas o los copos derivan de lado se ven zonas vacías en los bordes.

## Plan

1. Añadir la fila `Daño` (`hitbox_damage`, ya incluye bonus planos) y pasar el
   panel a 6 filas.
2. Bajar el panel a `(5, 82)`.
3. Emisión de ambiente: extents X `view.x × 1.2` (el doble de ancho) y el doble de
   partículas (hojas 28→56, copos 220→440) para mantener la densidad.

## Criterios de aceptación

- [ ] El panel muestra Daño, Vel. ataque, Daño crítico, Prob. crítico, Velocidad y Suerte.
- [ ] El panel no se solapa con las monedas.
- [ ] Hojas y copos cubren los dos laterales de la pantalla sin huecos.
- [ ] `docs/ui.md` y `docs/world.md` al día; changelog y estado al cerrar.

## Resultado

Pendiente de F5. Código en `scripts/player.gd` y
`scripts/world/biome_particles.gd`.
