# Super planning — estructuras y tienda

_2026-11-18 · decidido por `humano-ruben` · base: T-0074 y `ideas.md` § 5.1_

**Fecha límite: 2026-12-11** (todo acabado, jugado en F5 y documentado).

## Objetivo

Tres tipos de estructura y la tienda, integrados en la generación por chunk, con el arte
de Jorge. Nada de esto puede dejar el mundo sin generar, el guardado roto ni `main` en rojo.

| Tipo | Dificultad | Estimación | Qué sigue costando de verdad |
|---|---|---|---|
| 1 · Sprite único | baja | ~1 h base + 20–30 min por estructura | Enemigos exclusivos y loot table por estructura; si es sprite + `.tres`, media hora |
| 2 · Bloques / complejo | media | 4–8 h | Tiles rompibles (vida del tile, drop, "ya roto" persistido) y encaje del patrón con el terreno de ±1 escalón |
| 3 · Explorable | muy alta | 15–30 h | Segundo mundo con su ciclo de vida: interiores, transición, persistencia por piso, boss con patrones propios y balance |

El rango alto solo se usa si F5 descubre algo estructural (estado de bloques rotos o pisos
del castillo obligando a tocar guardado). Si no, tira a la baja.

Orden de ejecución: **tipo 2 primero** (desbloquea el arte de estructuras y el 3 se apoya en
él); el tipo 1 se resuelve casi de paso mientras se añaden estructuras.

## Reparto

| Quién | Qué |
|---|---|
| **Rubén** (`humano-ruben`) | Estructuras (tipos 2 y 3), tienda, F5 y decisiones de diseño |
| **Jorge** (`opencode-jorge` / su agente) | Enemigos y objetos nuevos (exclusivos de estructura y del boss) y arte: texturas de estructuras, sonidos |
| Agentes (opencode) | Código de sistemas y docs por ticket; sin cambios fuera del ticket |

Regla: una rama por feature (`feat/estructuras-bloques`, `feat/tienda`,
`feat/estructura-explorable`, `feat/arte-estructuras`), PR a `main`, squash en el merge.

## Calendario

| Fecha | Hito | Qué debe estar cerrado |
|---|---|---|
| 2026-11-24 | **A · Bloques** | Patrones por bloques estampados en el chunk y tiles rompibles con drop y estado persistido (T-0075, T-0076) |
| 2026-12-01 | **B · Tienda y tipo 1** | Tienda jugable con stock y precios (T-0078) + extras de estructura simple (T-0077) con los objetos/enemigos de Jorge |
| 2026-12-08 | **C · Explorable MVP** | Entrada, 2–3 pisos procedurales, boss con loot exclusivo y persistencia por piso (T-0079 a T-0081) |
| 2026-12-11 | **D · Cierre** | F5 en bloque de estructuras + tienda, docs `world`/`biomes`/`loot`/`items`, tickets cerrados, changelog y estado |

Holgura: 9–11 dic son solo F5 + documentación + PRs. Si algo se retrasa, se recorta alcance
(ver § Recortes), no la fecha.

## Backlog propuesto

Ids desde T-0075 (T-0074 en `revision`). Los tickets se abren al arrancar cada fase, no
todos el día 1.

| Ticket | Sistema | Dueño | Estimación | Depende de | Fase |
|---|---|---|---|---|---|
| T-0075 · Estampar patrones de estructura por bloques | world | Rubén + agente | 2–4 h | T-0074 | A |
| T-0076 · Bloques rompibles (vida, drop y "ya roto") | world | Rubén + agente | 2–4 h | T-0075 | A |
| T-0077 · Extras de estructura simple (enemigos y loot table) | world / enemies | agente | 1 h + 20–30 min por estructura | T-0074, objetos de Jorge | B |
| T-0078 · Tienda: zona segura, stock, precios y UI | world / ui | Rubén + agente | 6–10 h | decisiones §, T-0077 | B |
| T-0079 · Interior explorable: entrada, pisos y salida | world | Rubén + agente | 8–12 h | T-0075 | C |
| T-0080 · Persistencia y reglas por piso | world / save | agente | 3–5 h | T-0079 | C |
| T-0081 · Boss, arena y loot exclusivo | enemies / world | Rubén + agente | 4–6 h | T-0079, Jorge | C |
| T-0082 · F5 en bloque y documentación | docs | Rubén + agentes | 4–6 h | todas | D |
| T-0083 · Enemigos exclusivos de estructura y boss | enemies | Jorge | 2–4 h | T-0077 / T-0081 | B–C |
| T-0084 · Objetos exclusivos/rotos de estructuras | items | Jorge | 4–6 h | T-0077 / T-0081 | B–C |
| T-0085 · Arte: texturas de estructuras y sonidos | assets | Jorge | 8–12 h | — | A–C, continuo |

Suma aproximada: Rubén ~27–43 h (incluye F5 y documentación), Jorge ~14–22 h y ~10–16 h
de agente repartidas en los tickets de Rubén.

## Ruta crítica y dependencias

1. **T-0075 → T-0076 → T-0079**: sin estampado no hay interiores; sin tiles rompibles no hay
   loot de bloque (T-0076 se puede solapar con T-0079 si aprieta).
2. **Jorge entrega arte en tandas** (24 nov / 1 dic / 8 dic) para que Rubén no se quede
   esperando: texturas de tienda y ruinas primero; interiores y boss después.
3. **Tienda espera decisiones** (abajo) y al menos un surtido de objetos de Jorge. Si el
   1 dic llega sin objetos nuevos, la tienda usa el catálogo actual y se cambia después.
4. **Boss depende de enemigo + arena**; si T-0083 no está, el boss sale con un enemigo
   existente escalado y se sustituye sin tocar la mazmorra.

## Decisiones pendientes (bloquean T-0078)

- Moneda de la tienda (¿`current_coins`?) y precios.
- Surtido: 3 garantizados y máximo 5, ¿con un objeto de cada rareza o uno solo alto?
- ¿Se puede comprar varias veces? ¿Y volver a una tienda ya vista?
- Confirmar que la tienda es zona segura y qué pasa al salir (enemigos se reactivan, etc.).
- Estructuras: ¿colisión al final? El prototipo no la tiene; los bloques sí bloquearán.

## Recortes si aprieta el 11 dic

1. Explorable: 2 pisos y un boss; sin reglas especiales por piso ni segundo tipo de interior.
2. Tipo 1: solo estructuras con sprite + `.tres`; extras solo en las 2 principales.
3. Tienda: sin recompra y con stock fijo de 3.

No se recorta: persistencia (bloques rotos, pisos, objetos recogidos), compatibilidad de
guardado, documentación y F5.

## Definition of done (11 dic)

- [ ] Los tres tipos colocados por semilla y verificados en F5; tier y probabilidades por
      bioma en los `.tres`.
- [ ] Tienda funcional con stock, precios y zona segura.
- [ ] `docs/world.md`, `docs/biomes.md`, `docs/loot.md`, `docs/items.md` y
      `docs/enemies.md` al día; sin `docs/` que contradiga el código.
- [ ] Ticket cerrado con `## Resultado`, línea en `changelog.md`, `estado.md` y roadmap.
- [ ] PRs mergeados en `main`; `main` genera mundo y guarda partida sin errores.
- [ ] F5 de Rubén anotado (fecha y qué se probó) en el ticket de cierre.
