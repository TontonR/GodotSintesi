# Estado del proyecto

_Actualizado 2026-11-17 por `opencode-jorge`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `main` con T-0068 (PR #4) y los iconos de Jorge (T-0069–T-0071) mergeados |
| Árbol | Limpio. `.obsidian/` en `.gitignore` |
| Fase | **Todo lo construido está verificado en F5** (Ruben, 2026-11-17): 52 tickets cerrados en bloque. Los 44 objetos ya tienen icono definitivo asignado |
| Siguiente paso | F5 de los iconos y de los nuevos tiers de poción; luego T-0003 (inventario lleno) y los coleccionables del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. Decisiones de diseño abiertas en `vault/ideas.md` §7 |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `opencode-jorge` | T-0069–T-0071 (iconos de items), en `revision` hasta el F5 | `resources/*.tres`, `docs/items.md`, `vault/items*` |
| `buffy` | — | — |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-17 | T-0069–T-0071 | Iconos definitivos de los 44 objetos, tiers de poción 20/50/100 y renombres (`Vigorizing Pie`, `Mucus Essence`, `Hunter's Faith`, `Sanguine Ruby`) |
| 2026-11-17 | T-0068 | Cierre en bloque de 52 tickets tras el F5 de Ruben, T-0002 descartado (sin skills) y diseño de objetos corregido (consumibles + coleccionables, sin armas) |
| 2026-11-13 | T-0066 · T-0067 | Biomas de 2–8 chunks, estamina más barata, monedas que afloran y salto que no corta la carrera (PR #3) |
| 2026-11-13 | T-0057..T-0064 | Decoración de bioma, daño al atravesar, muerte, 3 slots, metros, parry/stun del lobo y cimas nevadas (PR #1) |
| 2026-11-12 | T-0056 | Auditoría de documentación: `enemies`/`items` reescritos, `biomes`/`loot`/`passives` nuevos |

## Riesgos vivos

- El proyecto no tiene tests: cada cambio se verifica con F5 o un script headless desechable.
- `AGENTS.md` llama legacy a `item_pickup.gd/.tscn`, pero es el pickup **vivo** (`scripts/enemies/enemy_base.gd:54`). No borrar (T-0004).
- **Ningún bioma puede subir `terrain_amplitude_multiplier` ni `terrain_frequency_multiplier` por encima de 1.0**: con el tope de ±1 salen rampas de un escalón por columna (T-0051). Un bioma solo aplana.
- El tope de pendiente encadena alturas desde la columna 0: no recalcular una columna suelta sin su predecesora. `_clamped_last` es la semilla de la cadena.
- La montaña de la izquierda (T-0052) no pasa por `_build_clamped_heights()`: si entra en la cadena, el tope la vuelve escalable y deja el vacío a la vista.
- El editor abierto reserializa escenas: borra `node_paths` (el script lo tolera con `get_node_or_null`) y añade `unique_id`. Revisar `git status` antes de commitear.
- Los iconos son definitivos, pero el arte puede cambiar: `docs/items.md` los marca `assigned icon` y `vault/items.md` `icono asignado`.
- 16 enemigos por chunk maduro: si baja el rendimiento, `enemy_ramp_max_multiplier` y `decor_per_chunk` son las palancas.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y `DISABLED_ENEMY_SCENES`.
