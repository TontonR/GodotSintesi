# Mundo — generación procedural por chunks

_2026-10-23 · rama `feat/world_generation_2`_

## Qué hace y dónde vive

- `scripts/world_generator.gd` crea `scenes/world/chunk.tscn` bajo demanda; cada chunk pinta sus propias capas `Solid`/`Grass` (`scripts/world/chunk.gd`).
- `scenes/game.tscn` conserva `solid_map_layer`/`grass_map_layer` con el parche de ejemplo: sirven de plantilla de tiles y de fuente de `TileSet`; los chunks nuevos no reutilizan su `tile_map_data`.
- Terreno con `FastNoiseLite` Perlin 1D sobre la X global. Altura base 25, amplitud 10, frecuencia 0.025: montañas suaves pero visibles.
- Inicio plano en los tiles 0–14 y transición de 8 tiles; el jugador aparece en `x=248`, sobre `base_height`.

## Tiles del terreno

- Fila 0 del atlas = superficie; fila 1 = relleno; fila 2 = plataformas voladoras. Por eso `ground_fill_coords` es `(1,1)`, no `(1,2)`.
- La superficie elige tile izquierdo `(0,0)`, centro `(1,0)` o derecho `(2,0)` según si el vecino baja. Se miran las alturas del chunk y las de los chunks vecinos (`edge_left`/`edge_right`).
- `ground_fill_depth` = 4: 5 tiles de grosor visibles, sin el efecto de mapa flotante.
- Sin rampas; los escalones son de 1 tile y se suben automáticamente.

## Chunks y carga

- Chunks de 32×48 tiles. Carga según cámara + `load_margin_px` 32: normalmente 1 chunk, 2 cerca de una costura. El chunk del jugador nunca se descarga.
- Antes de instanciar se generan los datos del chunk y del siguiente a la derecha. Al alejarse se borran datos y nodos.
- Semilla: `world_seed` 0 = aleatoria; cualquier otro valor la fija. El RNG de cada chunk usa semilla + coordenada.

## Spawns y persistencia

- Por chunk: `enemy_counts_per_chunk` [3 orcos, 1 fantasma] y 4 monedas. Márgenes de 2 tiles; en el chunk 0 no se genera antes de `safe_start_tiles`.
- Cada spawn tiene un id estable (`e:x:y:índice`, `c:x:y:índice`). `EnemyBase` emite `died` y `coin.gd` emite `collected`; el generador guarda esos ids y no los vuelve a instanciar.
- Los enemigos vivos que se descargan reaparecen; las bajas y monedas recogidas no.

## Subida automática

- Jugador y enemigos terrestres detectan una pared de 1 tile con un raycast y comprueban que hay hueco 16px arriba.
- La subida se interpola durante `step_duration` (0.15s), sin teletransporte. No se aplica a enemigos voladores.
- Si la subida es demasiado lenta/rápida, ajustar `step_duration` en el inspector.

## Capas y cámara

- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 384×216.
- `enemy_scenes` y `enemy_counts_per_chunk` deben tener el mismo orden. Para biomas futuros, elegir configuración en `_generate_chunk` y pasar sus tiles/spawns a `WorldChunk.paint`.

## Trampas

- Lo colocado a y=0 queda fuera de cámara: el suelo está cerca de y=400.
- Si tocas `chunk_width_tiles`, revisa también `safe_start_tiles`, `load_margin_px` y los arrays de spawns.
