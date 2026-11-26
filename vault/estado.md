# Estado del proyecto

_Actualizado 2026-11-26 por `buffy`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `feat/castillo-plantas-3-10`: castillo de 3 a 10 plantas que sube al pisar la puerta (T-0095), apilada sobre `feat/vfx-suelo-transicion-sangre` (VFX: suelo por tile, transición por densidad, rondas 4–6 y sangre radial T-0094, PR #12 abierto); `feat/vfx-ambiente-spritefusion` ya está fusionado (PR #11) |
| Árbol | `revision` tras T-0080, T-0095 y T-0097 (hall de 64×22 con suelo escalonado continuo, sin diagonales y con autotiling en las caras superiores): VFX ambientales de Sprite Fusion anclados al mundo (hojas y nieve con litter y ventisquero por tile, transición por densidad, hojas de ronda 9 sin oleadas ni montones tras TP, y sangre de la receta `blood` en golpes y muerte), castillo de 3–10 plantas que asciende al pisar la puerta (T-0095), hojas interactivas con disolución por píxeles y ajustes VFX (T-0096) y ronda 12: hojas verdes y escasas en el prado (densidad 0,2), ruido de nieve 3–7 px, ambiente con corte al 80 % y puerta del castillo con sprite de 64×64; ronda 13: subida automática con alcance real y apoyo, partículas con cantidad gradual y manto de nieve prolongado por terreno llano hasta un cambio de altura; ronda 14: rectángulos de ataque normalizados para que `flip_pivot` no genere `Rect2` negativos. F5 pendiente |
| Fase | Ruben en F5; `buffy` terminó su parte (mazmorra/castillo). PixelForge sigue con el arte de T-0086. Planning de estructuras y tienda al **2026-12-11** |
| Siguiente paso | F5 de Ruben (hall T-0095 de 64×22 con suelo escalonado, guardado dentro del castillo T-0080, ruinas, cajas, puerta, salida lejana, frontera hojas/nieve, hojas verdes del prado (ronda 12), subida automática y borde del manto (T-0097, ronda 13), rectángulos de ataque (T-0098, ronda 14), sangre al golpe y en la muerte, subida de plantas T-0095 y hojas interactivas T-0096); PR #12 (`feat/vfx-suelo-transicion-sangre`) y PR de `feat/castillo-plantas-3-10` (base: la rama de VFX); después T-0081 (boss) y T-0078 (tienda) |
| Bloqueos | Tienda sin decisiones de moneda/precios/surtido (`vault/ideas.md` §7) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `humano-ruben` | F5 de la fusión, del castillo y del guardado; decisiones de diseño | — |
| `opencode-jorge` | T-0080 guardado por piso (hecho, pendiente F5) + revisión y testeo headless de T-0093 | `scripts/world/dungeon_layer.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scenes/structures/dungeon_test.tscn`, `docs/dungeon.md` |
| `buffy` | T-0093 VFX ambientales (rondas 4 y 5: suelo por tile, transición por densidad y hojas) + T-0094 sangre de Sprite Fusion + T-0095 castillo de 3–10 plantas + T-0096 hojas interactivas + T-0097 subida automática y borde de nieve + T-0098 rectángulos de ataque (hechos, pendientes de F5) | `scripts/player.gd`, `scripts/world/spritefusion_ambient.gd`, `scripts/world/biome_particles.gd`, `scripts/world_generator.gd`, `scripts/fx/spritefusion_blood.gd`, `scripts/fx.gd`, `scripts/structures/castle/dungeon_generator.gd`, `scripts/world/dungeon_layer.gd`, `scripts/world/dungeon_test.gd`, `assets/vfx/spritefusion/`, `docs/player.md`, `docs/fx.md`, `docs/biomes.md`, `docs/world.md`, `docs/decor.md`, `docs/dungeon.md`, `scripts/vfx_settings.gd`, `assets/vfx/spritefusion/leaf_dissolve.gdshader` |
| `pixelforge` | T-0086 texturas de caja rompible | `assets/map/structures/crate_*.png` |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-26 | T-0098 | Rectángulos de ataque normalizados bajo `flip_pivot`; `_lift_rect()` sanea `Rect2` negativos y deja de inundar el debugger; F5 pendiente |
| 2026-11-26 | T-0097 | Subida automática con alcance por velocidad y comprobación de apoyo; partículas con cantidad gradual y manto de nieve extendido por terreno llano hasta el primer cambio de altura; F5 pendiente |
| 2026-11-26 | T-0096 (ronda 12) | El prado gana hojas ambientales verdes a densidad 0,2 (una quinta parte del bosque rojo), incluidas las copas de sus árboles y el litter; F5 pendiente |
| 2026-11-26 | T-0096 (ronda 11) | Nieve con ruido de baja frecuencia 3–7 px, fin del degradado de ambiente (corte 0,8) y puerta del castillo con sprite 64×64 visible; F5 pendiente |
| 2026-11-26 | T-0096 (ronda 10) | Nieve de 3 px sobre el escalón real, sin picos ni diagonales; TP sin copas, sangre al golpe y castillo de 64 tiles restaurado; F5 pendiente |
| 2026-11-26 | T-0096 (ronda 9) | TP sin copas, nieve interpolada sin costuras, sangre al golpe y castillo de 64 tiles restaurado |
| 2026-11-26 | T-0096 (ronda 8) | Nieve por píxel sin bandas de 16 px, 1 px más alta, huella baja de 3,5 s con Enhanced VFX physics; hojas menos numerosas por golpe/carrera, con empuje lateral y sin volver al slot; F5 pendiente |
| 2026-11-26 | T-0096 | Hojas interactivas con jugador/enemigos/hitboxes, vida del litter, disolución por píxeles y ajustes de partículas/físicas VFX; F5 pendiente |
| 2026-11-26 | T-0093 (ronda 6) | Vuelta al hall de tres bloques sin autotiling diagonal, borde solo en la cara superior, hojas sin oleadas tras TP y copas por turnos; F5 pendiente |
| 2026-11-26 | T-0094 (ronda 6) | Sangre de muerte radial: más gotas en 360° y menos velocidad que el chorro, sin dirección contraria; F5 pendiente |
| 2026-11-26 | T-0095 | Castillo de 3 a 10 plantas: la puerta sube una planta y la última vuelve al mundo (`floor_changed`); F5 pendiente |
| 2026-11-26 | T-0093 (ronda 5) | Hojas a 0,75 px, 108 unidades precargadas ±260 px fuera de la vista con deriva propia y lluvia bajo las copas con el tinte del árbol; F5 pendiente |
| 2026-11-26 | T-0094 | Sangre de Sprite Fusion en la muerte de enemigos: hebras, gotas con estela, niebla, goteo y costras que secan 6 s sobre el suelo; rampa derivada de `blood_color`; F5 pendiente |
| 2026-11-26 | T-0093 (ronda 4) | Suelo de los VFX por tile (bandas de nieve escalonadas, sin diagonales) y transición por densidad por bloque, sin alfa; F5 pendiente |
| 2026-11-25 | T-0080 | Guardar dentro de la mazmorra conserva planta, posición y punto de vuelta; `run/position` y metros del mundo; partidas viejas cargan igual |
| 2026-11-26 | T-0093 (VFX) | Partículas ambientales de Sprite Fusion (hojas y nieve) ancladas al mundo, con litter, ventisquero y crossfade de ~64 tiles; F5 pendiente |
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
