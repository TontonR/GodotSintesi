# Mundo — generación procedural por chunks

_2026-10-23 · 2026-10-25 · rama `feat/world_generation_2`_

## Qué hace y dónde vive

- `scripts/world_generator.gd` crea `scenes/world/chunk.tscn` bajo demanda; cada chunk pinta su capa `Solid` y su capa `Grass` con `scripts/world/chunk.gd`.
- `scenes/game.tscn` conserva `solid_map_layer`/`grass_map_layer` con el parche de ejemplo: sirven de plantilla de tiles y de fuente de `TileSet`; los chunks nuevos no reutilizan su `tile_map_data`.
- Terreno con `FastNoiseLite` Perlin 1D sobre la X global. `base_height` 60 (escena: 50), amplitud 20, frecuencia 0.007: colinas suaves. Con `world_seed` 12345 el rango medido es 43–59 (16 tiles) y el salto máximo entre tiles contiguos es 1.
- Inicio plano en los tiles 0–49 y transición de 24 tiles (escena `safe_start_tiles=50`); el jugador aparece en `x=808`, 6 tiles sobre el suelo.

## Tiles del terreno

- Atlas de 3 columnas: fila 0 = superficie, fila 1 = relleno. La fila 2 no se usa.
- La superficie elige tile izquierdo `(0,0)`, centro `(1,0)` o derecho `(2,0)` según si el vecino baja. Se miran las alturas del chunk y las de los chunks vecinos (`edge_left`/`edge_right`).
- La capa `Grass` repite esa misma columna en la fila de superficie, encima de `Solid`; su `TileSet` se toma de `grass_map_layer`.
- El relleno llega hasta `chunk_height_tiles` (140): no hay efecto de mapa flotante.
- Cada chunk pinta una columna extra a la derecha, idéntica a la primera del siguiente: tapa la grieta de 1 px al unir dos `TileMapLayer`.
- Sin rampas; los escalones son de 1 tile y se suben automáticamente.

## Escala de pantalla (2026-10-29)

- Viewport 768×432 y ventana 1536×864 = exactamente 2×. Con 1280×720 el factor era 1.667 y el pixel-art temblaba al desplazarse (las texturas con filtro nearest cambian de tamaño de texel cada frame). Si se cambia la ventana, usar múltiplos enteros: 768×432, 1536×864.
- `window/stretch/scale_mode="integer"`: en pantalla completa (1920×1080) el contenido se dibuja a 2× exactos (1536×864) centrado, con bandas negras; sin esto el factor era 2.5 y el temblor volvía. Medido: `screen_scale=(2.0, 2.0)` en ventana y en fullscreen.
- `snap_2d_transforms_to_pixel` sigue activo; con escala entera no produce temblor.

## Chunks y carga

- Chunks de 256×140 tiles. Carga según cámara + `load_margin_px` 96 y se mantienen `KEEP_CHUNKS_SIDE` = 2 chunks extra a cada lado: los enemigos y monedas solo desaparecen cuando su chunk queda 2 chunks atrás (se liberan con el nodo, no antes).
- Antes de instanciar se generan los datos del chunk y del siguiente a la derecha. Al alejarse se borran datos y nodos.
- Semilla: `world_seed` 0 = aleatoria; cualquier otro valor la fija. El RNG de cada chunk usa semilla + coordenada.

## Spawns y persistencia

- Por chunk: `enemy_counts_per_chunk` [4 orcos, 1 fantasma] y 8 monedas. Con 256 tiles de ancho la densidad es la mitad que con 128; para más o menos, tocar los contadores (la densidad no cambia con el alto). Márgenes de 2 tiles; en el chunk 0 no se genera hasta `safe_start_tiles + 6` (88 px de hueco con el spawn del jugador).
- La base del collider del enemigo se apoya en el suelo (`_body_bottom`), no el origen: los enemigos están escalados ×2.
- Cada spawn tiene un id estable (`e:x:y:índice`, `c:x:y:índice`). `EnemyBase` emite `died` y `coin.gd` emite `collected`; el generador guarda esos ids y no los vuelve a instanciar.
- Los enemigos vivos que se descargan reaparecen; las bajas y monedas recogidas no.

## Subida automática

- Jugador y enemigos terrestres suben 1 tile (16 px) de golpe al llegar a un escalón, usando `test_move` sobre la forma real del cuerpo. Prueban 1 px por delante y suben 17 px: suben antes de chocar (sin perder la X) y no encadenan dos subidas.
- 2+ tiles no se suben: hay que saltar. No se aplica a enemigos voladores.
- El primer chunk (x=0) no genera enemigos: zona segura para spawnear.

## Capas y cámara

- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 768×432 (ventana 1280×720).
- `enemy_scenes` y `enemy_counts_per_chunk` deben tener el mismo orden. Para biomas futuros, elegir configuración en `_generate_chunk` y pasar sus tiles/spawns a `WorldChunk.paint`.

## Trampas

- Lo colocado a y=0 queda fuera de cámara: el suelo está cerca de y=800 (base 50 en la escena).
- Si tocas `chunk_width_tiles`, revisa también `safe_start_tiles`, `load_margin_px` y los arrays de spawns.
