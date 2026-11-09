# Mundo — generación procedural por chunks

_2026-10-23 · 2026-10-25 · 2026-11-05 · rama `feat/world_generation_2`_

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

## Biomas (2026-11-01 · transición por bloques 2026-11-05)

- `scripts/world/biome.gd` (`class_name Biome`, `Resource`): `display_name`, `grass_color`, `forest_color`, `rock_color`, `ambient`, `spawn_weight`, `terrain_amplitude_multiplier`, `terrain_frequency_multiplier`, `enemy_scenes`, `enemy_counts` (mismo orden que las escenas).
- Recursos (3): `pradera.tres` (verde, 4 orcos + 1 fantasma, peso 0.55), `bosque_rojo.tres` (rojo, 1 lobo + 1 sapo + 1 demonio + 2 slimes, peso 0.3) y `nieve.tres` (blanco-azul, 2 esqueletos + 2 arqueros + 1 lobo, peso 0.2).
- **El bioma se decide por bloque** (`_biome_index_at_tile()`): `_biome_noise` (Perlin 1D, semilla + 1000, `biome_frequency` 0.12 en unidades de chunk que se divide por `chunk_width_tiles`, `biome_contrast` 2) devuelve un valor 0..1 que se reparte por los `spawn_weight` acumulados: por debajo del peso de la pradera es pradera y el resto bosque rojo. Todo `tile_x < chunk_width_tiles` (incluidos los negativos) es el primer bioma: la zona segura del spawn.
- **Enemigos**: siguen siendo por chunk; `_biome_for_chunk()` toma el bioma del bloque central. Con `biome_frequency` 0.12 cada bioma dura ~8 chunks (con 0.04 eran ~25 chunks, por eso casi todo salía pradera). Los pesos son umbrales sobre el ruido, no porcentajes exactos del mapa.
- **Transición por bloques**: `biome_transition_tiles` (0 = `chunk_width_tiles`, o sea 256). Cada bloque usa la media móvil de los colores de los biomas de su ventana (±128 bloques), así que el cambio es un degradado a lo largo de ~256 bloques, no un escalón en la costura del chunk. La costura puede caer en mitad de un chunk: la lógica y el color ya no dependen de los bordes.
- **Terreno por bioma**: cada `Biome` tiene `terrain_amplitude_multiplier` y `terrain_frequency_multiplier`: bosque rojo 1.35 y 1.1 (con 1.7/1.25 se notaba demasiado), pradera 0.95 (aplana un poco) y nieve 1.0. `_chunk_biome_data()` mezcla ambos con la misma ventana de 256 bloques que el color, así el relieve se exagera poco a poco al entrar en el bosque rojo. `_height_at_with()` usa los modificadores ya mezclados y los bordes de dos chunks coinciden porque la mezcla se hace en orden fijo y en float64.

## Césped y bosques tintables

- El césped usa `assets/map/tile/grass_tile_gray.png` (gris = máx(R,G,B) del original, alfa intacto). El color lo pone el `modulate` del dibujado con el `grass_color` del bioma, así cualquier color vale (nieve: `Color(0.93, 0.96, 1)`).
- `WorldChunk.paint()` recibe `grass_tints` (un color por bloque, 257 por chunk) y `GrassPaint` dibuja cada tile de césped con su color; `Solid` (suelo marrón) no se tiñe. `_chunk_biome_data()` calcula colores y modificadores de terreno con una ventana deslizante, y el nodo `Grass` desapareció de `chunk.tscn` porque un `TileMapLayer` solo se puede teñir entero.
- Los bosques del fondo usan `assets/map/background/pine1_gray.png` / `pine2_gray.png`, con la misma regla de gris. `WorldGenerator.forest_tint_paths` apunta a los `Sprite2D` de `far_forest` y `near_forest`; su `modulate` se actualiza al cambiar de bloque con el `forest_color` del bioma.
- Para añadir un bioma basta con crear otro `.tres` y meterlo en `biomes` del generador.

## Fondos tintables (2026-11-05)

- Las capas de pino usan `assets/map/background/pine1_gray.png` y `pine2_gray.png`, generadas con un script de Python: solo los píxeles verdes/teal (hue 100–210°, saturación ≥ 0.12) pasan a gris; el resto no se toca. **Cada capa tiene su gris**: pino lejano 116, pino cercano 92 (más oscuro) y montaña 172/211 (la más clara). Así el tinte no iguala los tres fondos y se mantiene el escalón de profundidad de antes.
- **`Biome.forest_color`** tiñe solo los fondos, separado de `grass_color`: la pradera usa `(0.233, 0.388, 0.388)`, que sobre esos grises devuelve los tonos originales (lejano `(27, 45, 45)`, cercano `(21, 36, 36)`, montaña `(40, 67, 67)` y `(49, 82, 82)`); el bosque rojo usa `(1, 0.32, 0.28)` y conserva la misma diferencia entre capas. El césped sigue con `grass_color`.
- La montaña son tres capas bajo `mountains`: `Sprite2D` (piedra, `mountain2.png`), `Sprite2DGreen` (`mountain2_gray.png`, solo los dos tonos del bosque en gris 172/211 y transparencia en el resto) y `Sprite2DSnow` (`mountain2_snow.png`, solo los píxeles de nieve originales, dibujado encima). `forest_tint_paths` tiñe el bosque y `rock_tint_paths` la piedra con `rock_color`; la nieve no se tiñe nunca, así que es la misma en pradera y bosque rojo y sigue blanca en nieve, donde la piedra se pone gris.
- El césped ya usaba la idea (`grass_tile_gray.png`, gris = máx(R,G,B)); los fondos reutilizan la receta con un gris calibrado por capa para que el tinte recupere el tono original de cada una y el rojo del bosque siga viéndose.

## Ambiente por bioma (2026-11-05)

- `Biome.ambient`: `"none"`, `"leaves"` (hojas rojas) o `"snow"` (copos). El bosque rojo lleva hojas, nieve lleva copos y pradera nada.
- `scripts/world/biome_particles.gd` (nodo `biome_particles`, `CanvasLayer` layer 5 en `game.tscn`) crea dos `CPUParticles2D` a pantalla completa con texturas de píxeles generadas en código. Cada 0,25 s pide `WorldGenerator.biome_at_world_x()` en la X del jugador y enciende el emisor del `ambient` del bioma; al apagarlo, las partículas vivas terminan su vida.
- Cobertura horizontal (2026-11-05): el rectángulo de emisión mide `view.x × 1.2` a cada lado del centro (antes `0.6`), o sea el doble de ancho, y hay el doble de partículas (56 hojas, 440 copos). Así el viento lateral no descubre zonas vacías en los bordes.
- Hojas: 28 partículas, caída lenta con giro. Nieve: 220 copos, caída más lenta todavía. Al activarse el emisor la pantalla ya está llena (`preprocess`), y entra/sale con un fundido de 0,4 s y viento lateral.

## Spawns y persistencia

- Por chunk, según el bioma: 4 orcos + 1 fantasma (pradera) o 1 lobo + 1 sapo + 1 demonio + 2 slimes (bosque rojo). `enemy_counts_per_chunk` (`[4 orcos, 2 ranas, 1 lobo, 2 slimes, 2 esqueletos, 2 arqueros]`) queda como respaldo para biomas sin `enemy_scenes`. 2 monedas por chunk.
- Las monedas nacen `coin_spawn_height` (40 px) sobre el suelo y caen con su propia gravedad (`scripts/collectables/coin.gd`): buscan el suelo una vez por raycast, rebotan con `bounce` 0,4 mientras el impacto supere `min_bounce_speed` (40 px/s) y al asentarse hacen un vaivén de 1 px. Antes aparecían ya apoyadas (`coin_ground_offset`).
- Densidad por distancia (`_enemy_count_multiplier(chunk_x)`): chunks 0–1 al 50 % (`enemy_ramp_first_multiplier`), y de ahí +20 % por chunk (`enemy_ramp_per_chunk`) hasta ×1.8 (`enemy_ramp_max_multiplier`).
- **Reparto uniforme** (2026-11-03): se monta la lista de tipos del chunk y se parte `enemy_min_x..max_x` en un hueco por enemigo; cada uno cae en el centro de su hueco con ruido de ±25 % del hueco. Antes cada enemigo sacaba su X al azar y se apelotonaban.
- **Voladores**: el merge con `feat/biomas` los devuelve a los biomas (la pradera lleva fantasma y el bosque rojo demonio). `DISABLED_ENEMY_SCENES` sigue como lista de referencia sin uso.
- Márgenes de 2 tiles; en el chunk 0 los enemigos empiezan en `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles, ~320 px del spawn del jugador).
- La base del collider del enemigo se apoya en el suelo (`_body_bottom`), no el origen: los enemigos están escalados ×2.
- Cada spawn tiene un id estable (`e:x:y:índice`, `c:x:y:índice`). `EnemyBase` emite `died` y `coin.gd` emite `collected`; el generador guarda esos ids y no los vuelve a instanciar.
- Los enemigos vivos que se descargan reaparecen; las bajas y monedas recogidas no.

## Subida automática

- Jugador y enemigos terrestres suben 1 tile (16 px) de golpe al llegar a un escalón, usando `test_move` sobre la forma real del cuerpo. El jugador prueba 1 px por delante; los enemigos prueban lo que avanzan en el frame (`|vx| * delta`, mínimo 2 px) + 1, porque el lobo llega a 300 px/s. Suben 17 px: suben antes de chocar (sin perder la X) y no encadenan dos subidas.
- 2+ tiles no se suben: hay que saltar. No se aplica a enemigos voladores.
- Con el aumento de enemigos, un chunk maduro mete 16: si el rendimiento cae, bajar `enemy_ramp_max_multiplier` o `enemy_counts_per_chunk`.

## Ciclo día/noche (2026-11-03, ampliado)

- `scripts/world/day_night.gd` (`DayNightCycle`), nodo `day_night` en `scenes/game.tscn`. Día 300 s (5 min) y noche 180 s (3 min); ciclo total 480 s. Empieza de día.
- El cielo es el `RenderingServer.set_default_clear_color` del viewport; nada de `CanvasModulate`, así que tiles, sprites y HUD conservan su color.
- Colores por defecto: día `Color(0.5098, 0.7882, 0.9922)` (el `default_clear_color` de `project.godot`) y noche `Color(0.0431, 0.0627, 0.1647)`. Editables en el inspector.
- `fade_seconds` (12 s) funde el color en cada cambio de fase, recortado a la mitad de la fase más corta; poner 0 para el salto seco. El mismo factor 0→1 (`_night_factor_at`) mueve los otros tres efectos, así que entran y salen con el cielo.
- Estrellas: `StarField` (clase interna) en un `CanvasLayer` con `layer = -1`, por debajo del mundo; puntos fijos de `star_size` px, semilla fija 20261103, límite superior 90% de la pantalla. `star_count` 110; su alfa es el factor de noche.
- Montañas: el nodo `../mountains` recibe `modulate` = blanco → `mountain_night_tint` (`Color(0.33, 0.36, 0.52)`), bastante más oscuras de noche. El resto del parallax no cambia.
- Velo: `ColorRect` negro en un `CanvasLayer` con `layer = 11` (encima del HUD, que está en 10), alfa `night_veil_alpha` = 0.1 (10%) escalado por la noche. `mouse_filter` en `IGNORE` para no bloquear clics.
- Todos los valores son `@export`: se cambian desde la escena sin tocar código. El reloj es `fmod` sobre `_process`, así que no se guarda entre partidas.

## Caída inicial y pantalla de carga (2026-11-03, reescrita)

- `scripts/world/fall_intro.gd` (`FallIntro`), nodo `fall_intro` al final de `scenes/game.tscn`: coloca al jugador `fall_height_px` (520) por encima de su spawn y lo deja caer a `fall_speed` (300 px/s, ~1,7 s) con `player.fall_speed_cap`; el control sigue desactivado hasta aterrizar.
- La cámara **sigue al jugador desde el primer frame** (`camera_follow_enabled`). El parqueo anterior (`_park_camera`, `follow_after_px`) no podía funcionar: la `Camera2D` es hija del jugador, así que el parqueo viajaba con él y al enganchar la vista pegaba un salto de ~270 px. Fuera parqueo y fuera tirón.
- Con 2200 px el intro eran 7 s de cielo vacío: ahora son 520 px (~1,7 s) y el suelo entra enseguida en cámara. `max_seconds` (6 s) devuelve el control aunque el aterrizaje se atasque.
- El intro hace de **pantalla de carga**: si `WorldGenerator.is_ready_at(x)` (nuevo, mira `_loaded_chunks` del chunk que contiene X) dijera que no hay mundo, la caída se queda suspendida a 240 px del suelo en vez de aterrizar en el vacío. En la práctica la generación es síncrona en `_ready`, así que nunca se ve.
- Sin negro de transición (quitado el 2026-11-03): se entra directo al cielo. Al aterrizar se devuelve el control y se muestra el `UILayer` (oculto durante la caída).
- Todos los valores son `@export` en el nodo `fall_intro`.

## Capas y cámara

- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 768×432 (ventana 1280×720).

## Trampas

- Lo colocado a y=0 queda fuera de cámara: el suelo está cerca de y=800 (base 50 en la escena).
- Si tocas `chunk_width_tiles`, revisa también `safe_start_tiles`, `load_margin_px` y los arrays de spawns.
