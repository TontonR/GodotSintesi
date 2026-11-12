# T-0057 · Decoraciones de bioma (arbustos, árboles y rocas)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Rama | `feat/decor` |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0057 |

## Problema

`assets/map/decor/` (2 arbustos, 2 árboles, 2 rocas) estaba sin usar: el mundo
solo tenía suelo, hierba y fondos. Además los biomas no tenían un color propio
para la vegetación.

## Plan

1. Añadir `decor_colors: Array[Color]` a `Biome` y rellenarlo en los tres `.tres`.
2. Generar copias grises de arbustos y árbol vivo (solo píxeles verdes).
3. Spawnear los decorados por chunk con pesos, detrás de `Solid`/`GrassPaint`,
   apoyados en la fila de superficie, sin colisión, escala ni parallax.
4. Elegir el tinte de cada decorado al azar del array del bioma de su tile.
5. Documentar en `docs/decor.md` y actualizar `docs/biomes.md`, `docs/world.md`
   y el índice de `AGENTS.md`.

## Criterios de aceptación

- [x] Salen arbustos, árboles y rocas en el mundo, detrás del suelo.
- [x] No colisionan, no se escalan y se mueven con el chunk (no parallax).
- [x] Arbustos y árbol vivo cambian de color con el bioma; rocas y árbol muerto no.
- [x] Cada decorado tinta con un color aleatorio del array del bioma.
- [x] `docs/decor.md` creado y enlazado desde `docs/world.md` y `AGENTS.md`.
- [ ] F5 visual con los tres biomas.

## Resultado

- `scripts/world/biome.gd`: nuevo `decor_colors`.
- `scripts/world_generator.gd`: grupo **Decor** (`decor_textures`,
  `decor_tinted`, `decor_weights`, `decor_per_chunk`, `decor_margin_tiles`),
  generación determinista en `_generate_chunk()` y `Sprite2D`s en
  `_spawn_chunk_entities()` movidos al índice 0 del chunk.
- `assets/map/decor/`: `bush_1_gray.png`, `bush_2_gray.png`, `tree_gray.png`.
- `resources/world/biomes/{pradera,bosque_rojo,nieve}.tres`: 3 tintes cada uno
  (verdes, rojos/naranjas y verdes fríos).
- Docs: `docs/decor.md` nuevo; `docs/biomes.md`, `docs/world.md` y `AGENTS.md`.
- Comprobado con script headless: chunks con `Decor_*` como primer hijo, sin
  colisión, apoyados en la superficie y con el tinte esperado por bioma.
- Queda el F5 visual (16 por chunk puede quedarse corto o largo).
