# Estado del proyecto

_Actualizado 2026-11-26 por `opencode-jorge`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `refactor/world-split` (T-0094), apilada sobre `feat/vfx-ambiente-spritefusion` (T-0095), que sale de `test/fusion-structure` (T-0074…T-0093), sobre `main` `ccbae38` |
| Árbol | `revision`: castillo/ruinas/cajas/mazmorra con guardado, VFX ambientales anclados al mundo y `world_generator.gd` partido en tres managers (1654 → 677 líneas). F5 pendiente en las tres ramas |
| Fase | Tres PRs en cadena pendientes del F5 de Ruben. PixelForge sigue con el arte de T-0086; T-0092 espera decisión de cuenta. Planning de estructuras y tienda al **2026-12-11** |
| Siguiente paso | F5 y PR **en este orden**: (1) `test/fusion-structure`, (2) `feat/vfx-ambiente-spritefusion`, (3) `refactor/world-split`. Después T-0081 (boss) y T-0078 (tienda) |
| Bloqueos | Tienda sin decisiones de moneda/precios/surtido (`vault/ideas.md` §7); T-0092 necesita la cuenta/clave de Ruben |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `humano-ruben` | F5 de la cadena (castillo → VFX → refactor) y decisiones de diseño | — |
| `opencode-jorge` | T-0094 refactor hecho y revisado en estático; pendiente F5 | `scripts/world_generator.gd`, `scripts/world/world_biome_manager.gd`, `scripts/world/world_decor_manager.gd`, `scripts/world/world_spawner.gd`, `docs/world.md`, `docs/biomes.md` |
| `buffy` | Ronda 4 de VFX (sangre de Sprite Fusion) **sin commitear** en el worktree `GodotSintesi-vfx`; T-0089/T-0090/T-0091/T-0093 castillo | `scripts/fx.gd`, `scripts/enemies/enemy_base.gd`, `scripts/world/spritefusion_blood.gd`, `assets/vfx/spritefusion/blood.ts` |
| `pixelforge` | T-0086 texturas de caja rompible | `assets/map/structures/crate_*.png` |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-26 | T-0094 | `world_generator.gd` de 1654 a 677 líneas: `WorldBiomeManager`, `WorldDecorManager` y `WorldSpawner` como `RefCounted`; API pública y exports intactos; `ambient_weight_at_world_x` movido al manager con delegado; F5 pendiente |
| 2026-11-25 | T-0093 (VFX) | Hojas y nieve de Sprite Fusion ancladas al mundo, con litter, ventisquero y crossfade de 64 tiles; falta F5 de densidad. Renombrado a **T-0095** |
| 2026-11-25 | T-0080 | Guardar dentro de la mazmorra conserva planta, posición y punto de vuelta; `run/position` y metros del mundo; partidas viejas cargan igual |
| 2026-11-25 | T-0093 (castillo) | Hall verificado en headless: colisión, one-way, semilla por planta; F6 arreglado con `UILayer` |
| 2026-11-24 | T-0090 | Interior del castillo con el atlas 8×6 de 32 px de `map.zip`: piedra, ladrillo, ventanas y estandartes; F5 pendiente |
| 2026-11-24 | T-0089 | Salida de la mazmorra: la cámara suavizada ya no arrastra el rango de chunks (49 → 5 chunks medidos); F5 pendiente |
| 2026-11-24 | T-0076 | Cajas rompibles en las ruinas: 40 de vida, 1–3 monedas, "ya roto" en `world/broken`; F5 pendiente |
| 2026-11-17 | T-0054 | 14 objetos de arquero, esqueleto, fantasma y demonio: arco cargado, invulnerabilidad, teleport, rata invulnerable, DOT de quemadura y loot en cuatro enemigos |
| 2026-11-17 | T-0073 | Editor web local de `vault/items`: landing con filtros por estado y edición de nombre, textura, habilidad y valores |
| 2026-11-17 | T-0069–T-0071 | Iconos definitivos de los 44 objetos, tiers de poción 20/50/100 y renombres (`Vigorizing Pie`, `Mucus Essence`, `Hunter's Faith`, `Sanguine Ruby`) |

## Riesgos vivos

- El proyecto no tiene tests: cada cambio se verifica con F5 o un script headless desechable. En esta sesión no hay Godot CLI, así que el refactor solo se ha revisado en estático.
- **PRs apiladas**: `refactor/world-split` contiene ya los commits de VFX y del castillo. No se puede mergear antes que ellas ni abrir su PR antes; si se mergea en otro orden, hay que rebanar de nuevo.
- **Código nuevo de mundo va en los managers**, no en `world_generator.gd`: biomas/colores en `WorldBiomeManager`, decor en `WorldDecorManager`, entidades y persistencia en `WorldSpawner`. La API pública (`ground_y_at`, `biome_at_world_x`, `meters_at`, `save_persistent_state`) sigue en `WorldGenerator`.
- `WorldGenerator.ambient_weight_at_world_x()` es un delegado al manager: `biome_particles.gd` lo busca por el grupo `world_generator`, así que no borrarlo sin cambiar el VFX.
- El worktree `GodotSintesi-vfx` tiene la ronda de sangre sin commitear: no pisarlo ni hacer checkout de esa rama en el worktree principal.
- El id `T-0093` está duplicado (castillo y VFX). El de VFX pasa a **T-0095**; los mensajes de commit antiguos siguen diciendo T-0093.
- `AGENTS.md` llama legacy a `item_pickup.gd/.tscn`, pero es el pickup **vivo** (`scripts/enemies/enemy_base.gd:54`). No borrar (T-0004).
- **Ningún bioma puede subir `terrain_amplitude_multiplier` ni `terrain_frequency_multiplier` por encima de 1.0**: con el tope de ±1 salen rampas de un escalón por columna (T-0051). Un bioma solo aplana.
- El tope de pendiente encadena alturas desde la columna 0: no recalcular una columna suelta sin su predecesora. `_clamped_last` es la semilla de la cadena.
- La montaña de la izquierda (T-0052) no pasa por `_build_clamped_heights()`: si entra en la cadena, el tope la vuelve escalable y deja el vacío a la vista.
- El editor abierto reserializa escenas: borra `node_paths` (el script lo tolera con `get_node_or_null`) y añade `unique_id`. Revisar `git status` antes de commitear.
- Los iconos son definitivos, pero el arte puede cambiar: `docs/items.md` los marca `assigned icon` y `vault/items.md` `icono asignado`.
- Las estructuras son placeholders: `assets/map/structures/*.png` se importan como textura (`.import` versionado) y el bioma las elige por `display_name`, así que renombrar una en su `.tres` rompe el `structure_kinds`.
- 16 enemigos por chunk maduro: si baja el rendimiento, `enemy_ramp_max_multiplier` y `decor_per_chunk` son las palancas.
- Las cajas rompibles son sólidas y solo salen en las ruinas y a partir del chunk 1: el chunk 0 (spawn) se queda sin cajas para no encerrar al jugador. Si se mueve el spawn, revisar `_crate_tiles()`.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y `DISABLED_ENEMY_SCENES`.
- La mazmorra es autónoma: `DungeonLayer` vacía los chunks con `unload_chunks()` y pausa `map`. Guardar dentro está resuelto (T-0080): la partida lleva `[dungeon] state` (`seed`, `floor`, `position`, `world_position`) y `run/position`/metros siguen en coordenadas del mundo.
- La mazmorra usa celdas de **32 px** (atlas del castillo), no de 16: `dungeon.tscn` y el pad de salida (32×64) van con ella. El atlas `.tres` del pack no trae colisión, se construye en código.
- `WorldGenerator._update_chunks()` ignora la cámara si está a más de media vista + margen del jugador: sin esa guarda, salir de la mazmorra o un teletransporte del debug generan todos los chunks intermedios.
