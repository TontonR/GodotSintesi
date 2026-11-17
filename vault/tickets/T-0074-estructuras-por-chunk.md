# T-0074 · Estructuras colocables por chunk y decididas por semilla

| Campo | Valor |
|---|---|
| Estado | `en-curso` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-17 |
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

- [ ] Hay al menos 2 `.tres` de estructura de prueba y se ven en juego con el placeholder.
- [ ] El bioma decide cuántas y cuáles; un bioma con `structures_per_chunk = 0` no coloca.
- [ ] Misma semilla → mismas estructuras en los mismos chunks; cambiarla cambia el reparto.
- [ ] La base queda apoyada en la superficie y no se corta en el borde del chunk.
- [ ] Sin colisión, sin tocar el reparto de enemigos y sin bajar el rendimiento (16 enemigos
      + 24–52 decor por chunk ya es el techo actual).
- [ ] `docs/world.md` y `docs/biomes.md` actualizados, más `changelog.md` y `estado.md` al cerrar.

## Resultado

Pendiente. Rama `feat/estructuras-chunk` creada el 2026-11-17 y solo con este ticket:
no hay código todavía.
