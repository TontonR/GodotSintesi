# T-0013 · Mundo procedural por chunks con persistencia de spawns

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-10-25) |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | world |
| Creado | 2026-11-03 (registro retroactivo) |
| Actualizado | 2026-10-25 |
| Ficheros | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `scenes/world/chunk.tscn`, `scenes/game.tscn`, `docs/world.md` |

## Qué se hizo

- Generación por chunks de 256×140 tiles bajo demanda, con `FastNoiseLite` Perlin 1D sobre la X global (`base_height` 60, amplitud 20, frecuencia 0.007): colinas suaves donde el salto entre tiles es 1.
- Inicio plano en los primeros 50 tiles + 24 de transición; spawn del jugador en `x=808`, 6 tiles sobre el suelo.
- Dos capas (`Solid` y `Grass`) pintadas por `WorldChunk.paint`; superficie en 3 variantes (izquierdo/centro/derecho) y relleno hasta 140 tiles.
- Columna extra a la derecha de cada chunk copiando la primera del siguiente: tapa la grieta de 1 px al unir `TileMapLayer`.
- Carga según cámara + `load_margin_px` 96 y `KEEP_CHUNKS_SIDE = 2` (los enemigos solo se liberan 2 chunks atrás).
- Spawns por chunk: 4 orcos + 1 fantasma + 8 monedas, con ids estables (`e:x:y:índice`, `c:x:y:índice`) y persistencia: bajas y monedas recogidas no reaparecen; los enemigos vivos que se descargan sí.
- Chunk 0 sin enemigos (zona segura) y margen de 2 tiles.
- Enemigos apoyados por la base del collider (`_body_bottom`), porque están escalados ×2.

## Trampas registradas

- Lo colocado a `y=0` queda fuera de cámara: el suelo está cerca de `y=800`.
- Si se toca `chunk_width_tiles`, revisar `safe_start_tiles`, `load_margin_px` y los arrays de spawns.
- `enemy_scenes` y `enemy_counts_per_chunk` deben ir en el mismo orden.

Commits: `19d7363`, `55a10cd`, `297d504`, `bea8591`, `932d79b`. Doc: `docs/world.md`.

## Resultado

Mundo procedural cerrado. La variedad de biomas y la densidad con 5 tipos de enemigo quedan en T-0008.
