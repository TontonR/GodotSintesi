# Roadmap — lo que queda por hacer

_2026-11-03 · reescrito 2026-11-17 sobre `main` `3001492` · limpieza 2026-11-27: `main` `69814d9` y los resueltos separados_

Estados: `abierto` · `en-curso` · `bloqueado` · `revision` (código hecho, sin commit o sin PR) · `resuelto` (código en `main`, falta F5 y cierre) · `cerrado` (va al `changelog.md`).

## P1 — Huecos funcionales del juego

**Estructuras y tienda al 2026-12-11**: calendario, tipos, estimaciones y reparto en
[`planning-estructuras.md`](planning-estructuras.md). Quedan T-0077 y T-0081…T-0085 de ese plan.

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0101](tickets/pendientes/T-0101-ajustes-de-verdad.md) | ui | Ajustes: remapeo de controles, VSync, tope de FPS, calidad gráfica, idioma y debug | `revision` |
| [T-0102](tickets/pendientes/T-0102-mundo-del-castillo.md) | mundo | Castillo como escena limpia: vuelta al mundo sin quedarse arriba, partículas de bioma dentro y puertas alineadas en la misma X | `revision` |
| [T-0103](tickets/pendientes/T-0103-mas-vfx.md) | fx | Hojas nuevas al entrar y salir del arbusto, con más partículas al salir | `resuelto` |
| [T-0107](tickets/pendientes/T-0107-debug-hud-nunca.md) | player | El aviso de debug no puede aparecer en una partida normal y las herramientas se encienden en Ajustes | `revision` |
| [T-0109](tickets/pendientes/T-0109-puertas-castillo-volando.md) | world | Puertas del castillo a veces en el aire: el suelo no llegaba al marco derecho | `revision` |
| [T-0108](tickets/pendientes/T-0108-arbusto-hojas-profundidad.md) | fx | Hojas del arbusto: menos, repartidas delante y detrás y desde el jugador, con más física | `revision` |
| [T-0104](tickets/pendientes/T-0104-tienda-zona-segura-y-stock-persistente.md) | mundo/UI | Tienda: zona segura alrededor del puesto y stock vendido persistido por `spawn_id` | `resuelto` |
| [T-0105](tickets/pendientes/T-0105-shop-screen-error-parseo.md) | ui | Error de parseo en `shop_screen.gd` que dejaba la tienda sin abrir | `resuelto` |
| [T-0078](tickets/resueltos/T-0078-tienda-stock-precios-y-ui.md) | mundo/UI | Tienda: puesto de mercader con stock de 3, precios derivados de stats y ventana de compra con F | `resuelto` |
| [T-0099](tickets/resueltos/T-0099-estructuras-detras-y-castillo-grande.md) | mundo | Estructuras de sprite detrás del jugador (`z_index` −1), tienda hundida y castillo a 8 tiles | `resuelto` |
| [T-0100](tickets/resueltos/T-0100-puertas-negras-y-contenido-mazmorra.md) | mundo | Puertas negras del castillo usadas con F (`enter`/`exit`) y cajas, monedas y arqueros por planta | `resuelto` |
| [T-0092](tickets/pendientes/T-0092-investigar-sprite-fusion.md) | docs | Investigar Sprite Fusion: export a Godot, MCP/API de pixel art, coste y claves | `abierto` |
| `T-0077` | mundo | Enemigos exclusivos y loot table por estructura simple (previsto) | `abierto` |
| `T-0081` | enemigos | Boss, arena y loot exclusivo (previsto) | `abierto` |
| `T-0082` | docs | F5 en bloque y documentación (previsto) | `abierto` |
| `T-0083` | enemigos | Enemigos exclusivos de estructura y boss (Jorge; previsto) | `abierto` |
| `T-0084` | objetos | Objetos exclusivos/rotos de estructuras (Jorge; previsto) | `abierto` |
| `T-0085` | assets | Texturas de estructuras y sonidos (Jorge; previsto) | `abierto` |
| [T-0003](tickets/pendientes/T-0003-inventario-lleno-intercambio.md) | inventario | Intercambio/rechazo cuando la barra está llena (hoy el drop se queda en el suelo) | `abierto` |
| [T-0007](tickets/pendientes/T-0007-pulido-enemigos-nuevos.md) | enemigos | Balance, capas y muerte de los enemigos integrados | `abierto` |

## P2 — Deuda y limpieza

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0004](tickets/pendientes/T-0004-legado-raiz-y-docs-obsoletos.md) | repo | Borrar legado real (`player.tscn`, `orc.tscn`, `coin` de `game.tscn`) y corregir docs falsos | `abierto` |
| [T-0005](tickets/resueltos/T-0005-quitar-debug-numpad.md) | inventario | Retirar el debug del numpad cuando acabe la fase de pruebas | `resuelto` |
| [T-0006](tickets/resueltos/T-0006-converger-docs-enemigos.md) | docs | Converger los docs del compañero con `docs/enemies.md` (la rama se portó a mano en T-0019) | `resuelto` |

## P3 — Contenido

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0008](tickets/pendientes/T-0008-mundo-biomas-y-densidad.md) | mundo | Biomas/zonas y densidad con 5 tipos de enemigo | `abierto` |

- **Coleccionables del arquero**: las 4 filas de `vault/pasivas/arquero.md` ya tienen
  diseño en `ideas.md` §4.2; falta decidir calidad de cada una y abrir ticket.
- **Coleccionables de esqueleto, fantasma y demonio**: diseñados, sin ticket.

## Resueltos — código en `main`, falta F5 y cierre

Nada de esta tabla sigue en juego: se cerrarán (y pasarán al `changelog.md`) cuando Rubén
haga el F5 en bloque de T-0082. Si uno falla ahí, vuelve a P1 con el motivo.

| Id | Sistema | Qué |
|---|---|---|
| [T-0069](tickets/resueltos/T-0069-iconos-consumibles-y-pociones.md) | inventario | Iconos de consumibles y tiers de poción 20/50/100 |
| [T-0070](tickets/resueltos/T-0070-iconos-pasivas-pendientes.md) | inventario | Iconos de las 34 pasivas que seguían provisionales |
| [T-0071](tickets/resueltos/T-0071-ajustes-iconos-pasivas.md) | inventario | Correcciones de iconos y renombres (`Hunter's Faith`, `Sanguine Ruby`) |
| [T-0072](tickets/resueltos/T-0072-inventario-texto-y-slots.md) | inventario | Texto del inventario más pequeño, slots de tamaño fijo y fichas de items al día |
| [T-0073](tickets/resueltos/T-0073-editor-web-de-objetos.md) | vault | Editor web local de objetos: lista, filtros por estado y edición de fichas |
| [T-0074](tickets/resueltos/T-0074-estructuras-por-chunk.md) | mundo | Estructuras por chunk: un `.tres` por tipo y una tirada independiente por estructura |
| [T-0075](tickets/resueltos/T-0075-estructuras-bloques.md) | mundo | Estructuras por bloques (tipo 2): patrón en el `.tres` y ruina de prueba |
| [T-0076](tickets/resueltos/T-0076-bloques-rompibles.md) | mundo | Bloques rompibles con drop y estado persistido |
| [T-0079](tickets/resueltos/T-0079-interior-explorable.md) | mundo | Interior explorable del castillo: entrada, pisos y salida |
| [T-0080](tickets/resueltos/T-0080-persistencia-por-piso.md) | guardado | Guardar y cargar dentro de la mazmorra: planta, posición y punto de vuelta |
| [T-0087](tickets/resueltos/T-0087-entrada-mazmorra.md) | mundo | Entrada a la mazmorra desde el mundo: bloque negro de la puerta y F |
| [T-0088](tickets/resueltos/T-0088-fusion-estructuras.md) | repo | Fusión de las ramas de estructuras y del arte de la mazmorra |
| [T-0089](tickets/resueltos/T-0089-salida-mazmorra-lenta.md) | mundo | Salida de la mazmorra sin regenerar el mapa entero (49 → 5 chunks medidos) |
| [T-0090](tickets/resueltos/T-0090-interior-castillo-tileset.md) | mundo | Interior del castillo con el tileset de `map.zip`: piedra, ladrillo, ventanas y estandartes |
| [T-0091](tickets/resueltos/T-0091-arreglar-tilemap-castillo.md) | mundo | Arreglar el tilemap del interior del castillo: remates, salas, ventanas y vigas |
| [T-0093](tickets/resueltos/T-0093-rediseno-plataformas-castillo.md) | mundo | Mazmorra del castillo como sala de referencia: tres bloques, fosas y plataformas |
| [T-0093 (VFX)](tickets/resueltos/T-0093-vfx-ambiente-spritefusion.md) | fx | VFX ambientales de Sprite Fusion (hojas y nieve) anclados al mundo |
| [T-0094](tickets/resueltos/T-0094-vfx-sangre-spritefusion.md) | fx | Sangre de Sprite Fusion: hebras, gotas, niebla y costras en la muerte |
| [T-0095](tickets/resueltos/T-0095-castillo-plantas-y-subida.md) | mundo | Castillo de 3 a 10 plantas: la puerta sube una planta y la última vuelve al mundo |
| [T-0096](tickets/resueltos/T-0096-hojas-interactivas-y-ajustes-vfx.md) | fx / UI | Hojas interactivas, disolución por píxeles y ajustes de partículas/físicas VFX |
| [T-0097](tickets/resueltos/T-0097-subida-automatica-y-borde-nieve.md) | player / mundo | Subida automática fiable y borde del manto de nieve por terreno llano |
| [T-0098](tickets/resueltos/T-0098-rects-negativos-ataque.md) | player / enemigos / fx | Rectángulos de ataque espejados sin tamaño negativo y sin errores de `_lift_rect` |

## Ideas sin ticket

El catálogo completo, con estado y dudas abiertas, está en [ideas.md](ideas.md).
No empezar ninguna sin abrir ticket y acordarlo en la bitácora:

- Coleccionables pendientes (arquero, esqueleto, fantasma, demonio).
- Sistema común de efectos: veneno, quemadura, pena, sangrado, blind, cadena eléctrica…
- Huecos de inventario obtenibles más allá de los 3 de serie.
- Desierto (momia) y cementerio (fantasma/demonio).
- Jefe de zona y salas especiales.
- Progresión: nivel, subida de stats, elección de coleccionables.
- Sonido y música.
