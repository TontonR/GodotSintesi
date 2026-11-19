# Estado del proyecto

_Actualizado 2026-11-18 por `opencode-jorge`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `feat/estructuras-chunk` con T-0074 (código hecho, sin commit) sobre `main` `ccbae38` |
| Árbol | T-0074 sin commitear: estructura + biomas + docs + vault. `.obsidian/` en `.gitignore` |
| Fase | T-0074 en `revision` y T-0075 (estructuras por bloques con bloque gris de prueba) en `revision`; falta F5 de ambos. Planning de estructuras y tienda al **2026-12-11** |
| Siguiente paso | F5 de T-0074/T-0075; commit + PR; después T-0076 (bloques rompibles), T-0078 (tienda) y T-0079–T-0081 (explorable) según [`planning-estructuras.md`](planning-estructuras.md) |
| Bloqueos | Tienda sin decisiones de moneda/precios/surtido (`vault/ideas.md` §7) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `humano-ruben` | Estructuras (bloques y explorable) y tienda, con F5 | `scripts/world/*`, `scenes/world/*`, `scripts/world_generator.gd`, `docs/world.md`, `docs/biomes.md` |
| `opencode-jorge` | Enemigos y objetos nuevos de estructura, y arte (texturas y sonidos) | `scenes/enemies/*`, `scripts/enemies/*`, `resources/*.tres`, `assets/` |
| `buffy` | T-0074 código terminado por `opencode-jorge`, pendiente de F5 | `scripts/world/structure.gd`, `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/structures/`, `assets/map/structures/`, `docs/world.md`, `docs/biomes.md` |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-17 | T-0054 | 14 objetos de arquero, esqueleto, fantasma y demonio: arco cargado, invulnerabilidad, teleport, rata invulnerable, DOT de quemadura y loot en cuatro enemigos |
| 2026-11-17 | T-0073 | Editor web local de `vault/items`: landing con filtros por estado y edición de nombre, textura, habilidad y valores |
| 2026-11-17 | T-0072 | Inventario: fuentes más pequeñas, descripción que no estira la ventana y slots de tamaño fijo con el icono adaptado |
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
- Las estructuras son placeholders: `assets/map/structures/*.png` se importan como textura (`.import` versionado) y el bioma las elige por `display_name`, así que renombrar una en su `.tres` rompe el `structure_kinds`.
- 16 enemigos por chunk maduro: si baja el rendimiento, `enemy_ramp_max_multiplier` y `decor_per_chunk` son las palancas.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y `DISABLED_ENEMY_SCENES`.
