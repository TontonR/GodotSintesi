# T-0036 · Slime y lobo en el bosque rojo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | world |
| Creado | 2026-11-09 |
| Actualizado | 2026-11-09 |
| Relacionado | T-0023 |

## Problema

El bosque rojo no tenía slimes y llevaba 2 lobos por chunk. Ruben pide meter
slimes y bajar la cantidad de lobos.

## Plan

1. Añadir `slime.tscn` a `enemy_scenes` de `resources/world/biomes/bosque_rojo.tres`.
2. Bajar el lobo de 2 a 1 por chunk y poner 2 slimes.

## Criterios de aceptación

- [ ] En F5 el bosque rojo genera 1 lobo, 1 sapo, 1 demonio y 2 slimes por chunk.
- [x] `docs/world.md` actualizado.
- [x] Entrada en `changelog.md` y `estado.md`.

## Resultado

`bosque_rojo.tres`: `enemy_counts` pasa de `[2, 1, 1]` a `[1, 1, 1, 2]` con
`slime.tscn` al final de `enemy_scenes`. F5 pendiente.
