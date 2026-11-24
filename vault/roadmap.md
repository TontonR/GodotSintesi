# Roadmap — lo que queda por hacer

_2026-11-03 · reescrito 2026-11-17 sobre `main` `3001492` (todo lo anterior verificado en F5)_

Estados: `abierto` · `en-curso` · `bloqueado` · `revision` · `cerrado` (los cerrados se van al `changelog.md`).

## P0 — En revisión

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0074](tickets/T-0074-estructuras-por-chunk.md) | mundo | Estructuras por chunk: un `.tres` por tipo y una tirada independiente por estructura (probabilidad por bioma) | `revision` |
| [T-0073](tickets/T-0073-editor-web-de-objetos.md) | vault | Editor web local de objetos: lista, filtros por estado y edición de fichas | `revision` |
| [T-0072](tickets/T-0072-inventario-texto-y-slots.md) | inventario | Texto del inventario más pequeño, slots de tamaño fijo y fichas de items al día | `revision` |
| [T-0069](tickets/T-0069-iconos-consumibles-y-pociones.md) | inventario | Iconos de consumibles y tiers de poción 20/50/100 | `revision` |
| [T-0070](tickets/T-0070-iconos-pasivas-pendientes.md) | inventario | Iconos de las 34 pasivas que seguían provisionales | `revision` |
| [T-0071](tickets/T-0071-ajustes-iconos-pasivas.md) | inventario | Correcciones de iconos y renombres (`Hunter's Faith`, `Sanguine Ruby`) | `revision` |

## P1 — Huecos funcionales del juego

**Estructuras y tienda al 2026-12-11**: calendario, tipos, estimaciones y reparto en
[`planning-estructuras.md`](planning-estructuras.md). Tickets previstos T-0075…T-0085.

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0075](tickets/T-0075-estructuras-bloques.md) | mundo | Estructuras por bloques (tipo 2) con bloque gris de prueba: patrón en el `.tres` y ruina de prueba | `revision` |
| [T-0091](tickets/T-0091-arreglar-tilemap-castillo.md) | mundo | Arreglar el tilemap del interior del castillo: remates, salas, ventanas y vigas del pack | `abierto` |
| [T-0092](tickets/T-0092-investigar-sprite-fusion.md) | docs | Investigar Sprite Fusion: export a Godot, MCP/API de pixel art, coste y claves | `abierto` |
| `T-0076` | mundo | Bloques rompibles con drop y estado persistido (previsto) | `abierto` |
| `T-0077` | mundo | Enemigos exclusivos y loot table por estructura simple (previsto) | `abierto` |
| `T-0078` | mundo/UI | Tienda: zona segura, stock, precios y UI (previsto; bloqueado por decisiones) | `bloqueado` |
| `T-0079` | mundo | Interior explorable: entrada, pisos y salida (previsto) | `abierto` |
| `T-0080` | guardado | Persistencia y reglas por piso (previsto) | `abierto` |
| `T-0081` | enemigos | Boss, arena y loot exclusivo (previsto) | `abierto` |
| `T-0082` | docs | F5 en bloque y documentación (previsto) | `abierto` |
| `T-0083` | enemigos | Enemigos exclusivos de estructura y boss (Jorge; previsto) | `abierto` |
| `T-0084` | objetos | Objetos exclusivos/rotos de estructuras (Jorge; previsto) | `abierto` |
| `T-0085` | assets | Texturas de estructuras y sonidos (Jorge; previsto) | `abierto` |
| [T-0003](tickets/T-0003-inventario-lleno-intercambio.md) | inventario | Intercambio/rechazo cuando la barra está llena (hoy el drop se queda en el suelo) | `abierto` |
| [T-0007](tickets/T-0007-pulido-enemigos-nuevos.md) | enemigos | Balance, capas y muerte de los enemigos integrados | `abierto` |

## P2 — Deuda y limpieza

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0004](tickets/T-0004-legado-raiz-y-docs-obsoletos.md) | repo | Borrar legado real (`player.tscn`, `orc.tscn`, `coin` de `game.tscn`) y corregir docs falsos | `abierto` |
| [T-0005](tickets/T-0005-quitar-debug-numpad.md) | inventario | Retirar el debug del numpad cuando acabe la fase de pruebas | `abierto` |
| [T-0006](tickets/T-0006-converger-docs-enemigos.md) | docs | Converger los docs del compañero con `docs/enemies.md` (la rama se portó a mano en T-0019) | `abierto` |

## P3 — Contenido

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0008](tickets/T-0008-mundo-biomas-y-densidad.md) | mundo | Biomas/zonas y densidad con 5 tipos de enemigo | `abierto` |

- **Coleccionables del arquero**: las 4 filas de `vault/pasivas/arquero.md` ya tienen
  diseño en `ideas.md` §4.2; falta decidir calidad de cada una y abrir ticket.
- **Coleccionables de esqueleto, fantasma y demonio**: diseñados, sin ticket.

## Ideas sin ticket

El catálogo completo, con estado y dudas abiertas, está en [ideas.md](ideas.md).
No empezar ninguna sin abrir ticket y acordarlo en la bitácora:

- Coleccionables pendientes (arquero, esqueleto, fantasma, demonio).
- Sistema común de efectos: veneno, quemadura, pena, sangrado, blind, cadena eléctrica…
- Huecos de inventario obtenibles más allá de los 3 de serie.
- Tienda y estructuras.
- Desierto (momia) y cementerio (fantasma/demonio).
- Jefe de zona y salas especiales.
- Progresión: nivel, subida de stats, elección de coleccionables.
- Sonido y música.
