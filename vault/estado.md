# Estado del proyecto

_Actualizado 2026-11-25 por `opencode-jorge`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `test/fusion-structure`: fusión de estructuras y castillo (T-0074/T-0075/T-0076/T-0079/T-0080/T-0087/T-0088/T-0091/T-0093), sobre `main` `ccbae38` |
| Árbol | `revision` tras T-0080 y T-0093 (pasillo procedural 64×22): suelo continuo escalonado con autotiling 8-vecinos, techo visible, plataformas mínimas para subir, BFS alcanzable 20/20 y salida diferida sin errores de físicas. F5 pendiente |
| Fase | Ruben en F5; `buffy` terminó su parte (mazmorra/castillo). PixelForge sigue con el arte de T-0086. Planning de estructuras y tienda al **2026-12-11** |
| Siguiente paso | F5 de Ruben (hall T-0093, guardado dentro del castillo T-0080, ruinas, cajas, puerta y salida lejana) y PR de `test/fusion-structure` a `main`; después T-0081 (boss) y T-0078 (tienda) |
| Bloqueos | Tienda sin decisiones de moneda/precios/surtido (`vault/ideas.md` §7) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `humano-ruben` | F5 de la fusión, del castillo y del guardado; decisiones de diseño | — |
| `opencode-jorge` | T-0080 guardado por piso (hecho, pendiente F5) + revisión y testeo headless de T-0093 | `scripts/world/dungeon_layer.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scenes/structures/dungeon_test.tscn`, `docs/dungeon.md` |
| `pixelforge` | T-0086 texturas de caja rompible | `assets/map/structures/crate_*.png` |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-25 | T-0080 | Guardar dentro de la mazmorra conserva planta, posición y punto de vuelta; `run/position` y metros del mundo; partidas viejas cargan igual |
| 2026-11-25 | T-0093 (revisión) | Hall verificado en headless: colisión, one-way, semilla por planta; F6 arreglado con `UILayer` |
| 2026-11-24 | T-0090 | Interior del castillo con el atlas 8×6 de 32 px de `map.zip`: piedra, ladrillo, ventanas y estandartes; F5 pendiente |
| 2026-11-24 | T-0089 | Salida de la mazmorra: la cámara suavizada ya no arrastra el rango de chunks (49 → 5 chunks medidos); F5 pendiente |
| 2026-11-24 | T-0076 | Cajas rompibles en las ruinas: 40 de vida, 1–3 monedas, "ya roto" en `world/broken`; F5 pendiente |
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
- La mazmorra está separada en `CastleLayout` (datos), `CastleTiles` (atlas/colisión), `CastlePainter` (capas) y `DungeonGenerator` (ciclo); `WorldGenerator`/`WorldStructure` no se tocan. `Walls` lleva colisión completa y `Platforms` fina one-way: no mezclar.
- El atlas agrupa decoración/plataformas arriba, bordes/esquinas en medio y piedra de fondo abajo. Suelo: `20/24/19/22` + esquinas `18/21/26/23`. Marco que rodea la sala: `24/20/22/19` + esquinas interiores `28/29/27/30` (canto hacia dentro). `41` es piedra y `11-14` madera. El púrpura `#423a51` es el fondo original del atlas: no recortarlo ni sustituirlo por otro tono. `DungeonVoid` (`Polygon2D`, z = -5, mismo púrpura) tapa el parallax del mundo; no bajarlo por debajo de `z = -100` ni ponerlo delante de `Back` (z = -4).
- 16 enemigos por chunk maduro: si baja el rendimiento, `enemy_ramp_max_multiplier` y `decor_per_chunk` son las palancas.
- Las cajas rompibles son sólidas y solo salen en las ruinas y a partir del chunk 1: el chunk 0 (spawn) se queda sin cajas para no encerrar al jugador. Si se mueve el spawn, revisar `_crate_tiles()`.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y `DISABLED_ENEMY_SCENES`.
- La mazmorra es autónoma: `DungeonLayer` vacía los chunks con `unload_chunks()` y pausa `map`. Guardar dentro sí está resuelto (T-0080): la partida lleva `[dungeon] state` (`seed`, `floor`, `position`, `world_position`) y `run/position`/metros siguen en coordenadas del mundo. Entrar por una puerta siempre empieza en la planta 0; solo cargar una partida restaura otra planta.
- La mazmorra usa celdas de **32 px** (atlas del castillo), no de 16: `dungeon.tscn` y el pad de salida (32×64) van con ella. El atlas `.tres` del pack no trae colisión, se construye en código.
- `WorldGenerator._update_chunks()` ignora la cámara si está a más de media vista + margen del jugador: sin esa guarda, salir de la mazmorra o un teletransporte del debug generan todos los chunks intermedios.
