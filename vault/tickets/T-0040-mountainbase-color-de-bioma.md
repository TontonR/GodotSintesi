# T-0040 · MountainBase con el color del bioma

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world / ui |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0023, T-0024, T-0025, T-0026 |

## Problema

La banda plana bajo las montañas (`mountains/MountainBase`, `ColorRect`) se quedaba
siempre en `#283D43`. En el bosque rojo y en la nieve desentonaba, mientras el césped, los
pinos y la roca sí seguían al bioma.

## Causa / contexto

`_update_biome_tint()` solo recorre `forest_tint_paths` (modulate) y `rock_tint_paths`
(modulate); la banda no estaba en ninguna lista. No se puede resolver con `modulate`: el
`ColorRect` ya trae un color casi negro y multiplicarlo lo apagaría del todo.

## Plan

1. Exportar `base_tint_paths` (por defecto `^"../mountains/MountainBase"`).
2. En `_update_biome_tint()`, escribir su `color` con `forest_color` oscurecido
   (`MOUNTAIN_BASE_DARKENING` 0.35): la pradera reproduce el `#283D43` actual.
3. Documentar en `docs/world.md` y `docs/ui.md`.

## Criterios de aceptación

- [ ] La banda cambia de tono al cruzar de bioma, con la misma transición suave que el resto.
- [ ] En pradera se ve igual que antes (`#283D43`).
- [ ] El ciclo día/noche sigue oscureciéndola.
- [x] `docs/world.md` y `docs/ui.md` actualizados.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

`scripts/world_generator.gd`: `base_tint_paths` + `_base_tint_nodes` y `color =
forest.darkened(0.35)` en `_update_biome_tint()`. El menú principal mantiene el color fijo
porque no tiene generador. F5 pendiente.
