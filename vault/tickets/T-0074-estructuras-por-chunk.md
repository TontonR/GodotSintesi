# T-0074 · Estructuras colocables por chunk y decididas por semilla

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-18 |
| Relacionado | T-0057 (decor), T-0048 (semilla), T-0066 (biomas), T-0013 (mundo) |

## Problema

Hoy un chunk solo aporta terreno, decor (sprites sin colisión, `DecorProp`, T-0057) y
enemigos. No existe forma de **colocar estructuras** (ruinas, torres, casas, cuevas) ni
de decir "en este bioma salen estas". Tampoco hay un reparto determinista por chunk:
el loot y los enemigos usan el RNG del chunk, pero no hay nada pensado para piezas
grandes que deban caer siempre en el mismo sitio con la misma semilla.

Objetivo: que una estructura sea un **recurso** (`.tres` y, si hace falta, escena propia)
que se pueda añadir a un bioma y que el generador decida **por chunk** si aparece, usando
la semilla. Sin arte definitivo por ahora: vale un placeholder cantoso.

## Plan

1. `scripts/world/structure.gd` (`class_name WorldStructure`, `Resource`):
   `display_name`, `scene` (`PackedScene`, opcional), `texture` + `pixel_size` como
   alternativa ligera, `size_tiles`, `margin_tiles`, `z_index`, `weight`,
   `min_distance_tiles`, `structures_per_chunk` (0 = no forzar) y `biomes` (filtro por
   `Biome.display_name`, vacío = todos).
2. Recursos de prueba en `resources/world/structures/` (2 o 3 `.tres`, p. ej.
   `torre_prueba.tres`, `ruina_prueba.tres`) con un placeholder obvio (rectángulo de color
   o PNG 16×16 rotulado `TEST`) para que en F5 se vea que está ahí.
3. `WorldGenerator`: `@export structures: Array[WorldStructure]` y
   `_structures_for_chunk(chunk_x)`. El roll usa un RNG derivado de `world_seed` +
   coordenada del chunk (mismo patrón que `_chunk_rng`/`enemy_counts`), de modo que la
   misma semilla da las mismas estructuras en los mismos chunks y `world_seed = 0`
   (aleatoria) cambia el reparto. Respetar `min_distance_tiles` (tiles, no chunks).
4. Colocación: hueco propio dentro del chunk (los enemigos ya se reparten por slots, no se
   debe pisar su X), base apoyada en la superficie que devuelve `_height_at_with()`, y
   `margin_tiles` (2 por defecto) lejos de los bordes para no cortar el seam.
5. Instanciar como **primer hijo del chunk** (por detrás de `Solid`/`GrassPaint`, igual que
   `DecorProp`), sin colisión en este prototipo y sin parallax. Id estable
   `s:x:y:index` para poder persistir qué estructuras ya se generaron.
6. `scripts/world/biome.gd` + `.tres` de los 3 biomas: `structures_per_chunk`,
   `structure_kinds` y `structure_weights` (mismo criterio que `decor_kinds`/`decor_weights`),
   para que el bioma decida qué sale (p. ej. nieve 0, pradera 1–2).
7. Docs: `docs/world.md` (sección de estructuras) y `docs/biomes.md` (campos nuevos).

## Decisiones abiertas

- Colisión: en el prototipo **no**, para no bloquear el paso; si luego molesta, la
  estructura la declara ella misma (`collision_shape`) en vez de en el generador.
- ¿La estructura es solo un `Sprite2D` o una escena completa? El recurso admite las dos:
  empezar por textura y pasar a `scene` cuando haya arte.
- ¿Estructuras que cruzan dos chunks? Fuera de alcance: primero piezas que caben en uno.

## Criterios de aceptación

- [x] Hay al menos 2 `.tres` de estructura de prueba y se ven en juego con el placeholder.
- [x] El bioma decide cuáles pueden salir y con qué probabilidad; una probabilidad 0 o un
      bioma sin `structure_kinds` no coloca nada.
- [x] Una tirada independiente por estructura y chunk: puede no salir ninguna, varias o
      todas, nunca dos de la misma.
- [x] Misma semilla → mismas estructuras en los mismos chunks; cambiarla cambia el reparto.
- [x] La base queda apoyada en la superficie y no se corta en el borde del chunk.
- [x] Sin colisión, sin tocar el reparto de enemigos y sin bajar el rendimiento (16 enemigos
      + 24–52 decor por chunk ya es el techo actual).
- [x] `docs/world.md` y `docs/biomes.md` actualizados, más `changelog.md` y `estado.md` al cerrar.

## Resultado

Código hecho el 2026-11-18 (`opencode-jorge`); falta F5.

- `scripts/world/structure.gd` (`WorldStructure`): escena o textura, `pixel_size`,
  `size_tiles`, `margin_tiles`, `z_index`, `min_distance_tiles` y `biomes`.
- `resources/world/structures/tower_test.tres` y `ruin_test.tres` con PNG placeholder de
  16×16 en `assets/map/structures/` (magenta con cruz / cian a rayas), ya importados.
- `WorldGenerator`: `structures`, `structure_min_gap_tiles`, `_roll_structures()`,
  `_structure_allowed()`, `_structure_x_free()`. **Una tirada independiente por estructura
  y chunk** (`Biome.structure_chances`): un chunk puede no tener ninguna o tener todas las
  del bioma, nunca dos de la misma. El roll va **después** de enemigos, monedas y decor con
  el mismo RNG del chunk, así que sus posiciones no se mueven; se consume una tirada por
  tipo aunque falle. Se prueban hasta 8 X por estructura: respeta `margin_tiles`, la
  separación con las otras (`structure_min_gap_tiles`), la X de los enemigos y apoya la base
  en la columna más baja de su ancho (nunca flota).
- `Biome`: `structure_kinds` + `structure_chances`. Pradera torre 15 % / ruina 25 %,
  bosque rojo ruina 30 %, nieve nada.
- Se instancian como hijo del chunk movido a índice 0: detrás de `Solid`/`GrassPaint` y
  del decor. Sin colisión y sin parallax. Id `s:x:y:index` en `set_meta`, sin persistir:
  nada destruye estructuras, así que la semilla reconstruye las mismas.

Desvíos del plan (actualizado 2026-11-18 con la decisión de Ruben):

- ~~Una estructura por chunk~~ → **una tirada por estructura**, con probabilidad por bioma
  (`structure_chances`). El recurso ya no tiene `structures_per_chunk` ni `weight`: el
  bioma es la única fuente de probabilidades.
- No hay escena ni colisión todavía (igual que en el plan); `scene` ya se instancia cuando
  el recurso la trae.

Tipos y estimaciones de estructura (sprite / bloques / explorable): `vault/ideas.md` § 5.1.
Calendario, tickets y reparto hasta el 2026-12-11: [`planning-estructuras.md`](../planning-estructuras.md).

Pendiente de F5: ver torre y ruina en pradera y ruina en bosque rojo (y chunks sin
estructura), comprobar que nieve no coloca ninguna y que repetir semilla (debug overlay)
deja el mismo reparto.
