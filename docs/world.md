# Mundo — generación procedural por chunks

_2026-10-22 · rama `main`_

## Qué hace y dónde vive

- `scripts/world_generator.gd` crea `scenes/world/chunk.tscn` bajo demanda; cada chunk pinta sus propias capas `Solid`/`Grass` (`scripts/world/chunk.gd`).
- `scenes/game.tscn` conserva `solid_map_layer`/`grass_map_layer` vacías: sus `TileSet` se usan como plantilla para los chunks nuevos.
- Terreno con `FastNoiseLite` Perlin 1D sobre la X global, para que las costuras entre chunks coincidan. Altura base 25, amplitud 2, frecuencia 0.01.
- Inicio plano en los tiles 0–14 y transición de 8 tiles; el jugador aparece en `x=248`, sobre `base_height`.
- Sin rampas: la variación es suave y los escalones son de 1 tile como mucho.

## Chunks y carga

- Chunks de 32×48 tiles (`chunk_width_tiles`, `chunk_height_tiles`). El alto cubre fondo de sobra; el relleno llega hasta el fondo del chunk.
- Carga según la cámara + `load_margin_px` 32: normalmente 1 chunk, 2 cerca de una costura. El chunk del jugador nunca se descarga.
- Antes de instanciar se generan los datos del chunk y de un chunk extra a cada lado (`_chunk_data`). Al alejarse se borran los datos y los nodos.

## Spawns y persistencia

- Semilla: `world_seed` 0 = aleatoria; cualquier otro valor la fija para depurar. El RNG de cada chunk usa esa semilla + coordenada.
- Por chunk: `enemy_counts_per_chunk` [3 orcos, 1 fantasma] y 4 monedas. Márgenes de 2 tiles; en el chunk 0 no se genera antes de `safe_start_tiles`.
- Cada spawn tiene un id estable (`e:x:y:índice`, `c:x:y:índice`). `EnemyBase` emite `died` y `coin.gd` emite `collected`; el generador guarda esos ids en memoria y no los vuelve a instanciar al recargar el chunk.
- Los enemigos vivos que se descargan sí reaparecen en su posición original; las bajas y monedas recogidas no.

## Capas y cámara

- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 384×216.
- `enemy_scenes` y `enemy_counts_per_chunk` deben tener el mismo orden. Para biomas futuros, elegir configuración en `_generate_chunk` y pasar sus tiles/spawns a `WorldChunk.paint`.

## Trampas

- Lo colocado a y=0 queda fuera de cámara: el suelo está cerca de y=400.
- Si tocas `chunk_width_tiles`, revisa también `safe_start_tiles`, `load_margin_px` y los arrays de spawns.
