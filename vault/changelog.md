# Changelog — lo que ya está hecho

_Append-only: se añade arriba lo nuevo, no se reescribe lo viejo._

## 2026-11-26 · `buffy` · Hojas: más pequeñas, precargadas y bajo los árboles (T-0093 ronda 5)

- 108 hojas a 0,75 px por píxel de arte (antes 80 a 1 px) y cada una con su propia
  dirección y velocidad de deriva, en vez de todas hacia la derecha.
- Se generan y se reciclan a ±260 px fuera de la vista, con el suelo y la cuota de
  bioma muestreados también en ese margen: al correr ya están cayendo en el tramo que
  va a entrar, sin montones que aparecen de golpe.
- Los árboles vivos entran en el grupo `decor_tree`; el 55 % de las hojas nacen bajo
  una copa visible con el `tint_color` de ese árbol, así que el bosque rojo llueve
  hojas rojas/naranjas bajo sus propios árboles.

## 2026-11-26 · `buffy` · VFX: suelo por tile, transición por densidad y sangre de Sprite Fusion (T-0093 ronda 4, T-0094)

- El suelo se lee y se dibuja por tile de 16 px: el ventisquero de nieve pinta bandas
  completas y las hojas y copos se posan en la fila del bloque, así que dos alturas nunca
  forman una diagonal.
- Fuera el tween de alfa: `ambient_share_at_world_x()` da la cuota 0..1 de cada tile con la
  misma ventana ±`biome_transition_tiles` que tiñe el terreno, y cada partícula se genera
  (o no) contra esa probabilidad; el clima se aclara bloque a bloque, sin transparencias.
- `scripts/fx/spritefusion_blood.gd` porta la receta MIT `blood` de Sprite Fusion: hebras,
  chorro, niebla, gotas, costras que secan 6 s y rampa derivada de `blood_color`; sustituye
  las 4 capas de `CPUParticles2D` en `enemy_death()`.

## 2026-11-25 · `buffy` · VFX anclados al mundo con litter y ventisquero (T-0093)

- La capa de ambiente copia la transformada de cámara: las partículas pasan a
  coordenadas de mundo y se generan/reciclan alrededor del rect visible, no del jugador.
  Al caminar hacen scroll con el terreno en vez de moverse con él.
- Portados los suelos de las recetas: litter de hojas determinista cada 18 px y
  ventisquero de nieve por ruido; los copos cercanos se derriten con fundido.
- `ground_y_at()` por columna de mundo cada 0,1 s; en mazmorra se usa el fondo de vista.

## 2026-11-25 · `buffy` · VFX: escala, suelo y crossfade (T-0093)

- Partículas a 1 px por píxel de arte (`pixel_scale`), la mitad de tamaño.
- `ground_y_at()` muestreado por la transformada de cámara: hojas y nieve se posan,
  descansan con fundido y renacen; sin generador el fondo de pantalla es el suelo.
- `WorldGenerator.ambient_weight_at_world_x()` da la cuota del blend de ±32 tiles y
  los efectos la persiguen, así que hojas y nieve se funden a lo largo de ~64 tiles.

## 2026-11-25 · `buffy` · VFX ambientales de Sprite Fusion (T-0093)

- `scripts/world/spritefusion_ambient.gd` porta `falling-leaves` y `snow` de la
  librería VFX gratuita (MIT) de Sprite Fusion: 80 hojas con 3 siluetas y 4 paletas
  de otoño, y 440 copos en tres profundidades con cristales animados y viento.
- `biome_particles.gd` cambia sus `CPUParticles2D` por estos emisores `Sprite2D`;
  el contrato del bioma (`ambient`) y el fundido de 0,4 s no cambian.
- Fuentes y licencia en `assets/vfx/spritefusion/`; validado en headless, falta F5.

## 2026-11-25 · `test/fusion-structure` — pisos aleatorios por semilla (T-0093)

- `DungeonGenerator` reemplaza `@export var floors` por `min_floors` (3) y `max_floors` (6) como exports.
- `floor_count()` es ahora determinista y derivado de la semilla: garantiza `min_floors` y luego intenta añadir pisos con una tirada del 50 % encadenada (cada piso extra requiere que el anterior también saliera exitoso) hasta `max_floors`.
- `_compute_floor_count(seed)` usa salt `0xDEAD_F100R` para no colisionar con las semillas por planta.
- La identidad seed → número de pisos es reproducible: la misma semilla siempre produce el mismo castillo con el mismo número de plantas.

## 2026-11-25 · `test/fusion-structure` — pasillo procedural continuo, autotiling 8-vecinos y salida diferida (T-0093)

- `DungeonGenerator._on_exit_body_entered()` emite `exit_requested.emit.call_deferred()` para evitar el error de físicas (`flushing queries`) al reconstruir chunks al salir.
- `CastleTiles` añade `SOLID_FILL` (`25`, `#423a51`) a `build_walls()`; `CastlePainter._paint_solid_grid()` construye un grid booleano `solid[x, y]` (marco + bloques) y resuelve bordes, esquinas exteriores e interiores (`27`–`30`) por sus 8 vecinos, eliminando huecos, bordes dobles y recortes negros.
- `CastleLayout` amplía el hall a `64` tiles, baja el techo (`TOP_ROW = 6`) con ventanas/estandartes en `y = 8`, sustituye las fosas por un suelo continuo escalonado (alternando escalones de piedra y subidas de 2–3 tiles con plataformas mínimas) y verifica alcanzabilidad por BFS (`tested_layouts=20 failed=0`).

## 2026-11-25 · `opencode-jorge` · T-0080 guardado y carga dentro de la mazmorra

- `DungeonLayer.save_state()` (`{}` en el mundo o `{seed, floor, position,
  world_position}`) y `restore_from_save()`: la carga descarga el mundo, genera la planta
  guardada y teletransporta al jugador. `enter()` y la carga comparten `_open_dungeon()`.
- `scripts/save_game.gd`: guardar dentro escribe `run/position`/`run/meters` del mundo y
  añade `[dungeon] state`; `request_load()` lo lee en `SaveGame.data["dungeon"]`. Sin
  subir `VERSION`: las partidas viejas leen `{}`.
- `scripts/game.gd` llama a `restore_from_save()` tras `refresh_chunks()`.
- Entrar por una puerta sigue empezando en la planta 0; solo cargar restaura otra planta.
- Verificado en headless (Godot 4.7.2): guardar dentro, continuar en la planta 1, salir al
  punto de la puerta y liberar la mazmorra; `game.tscn`/`dungeon_test.tscn` sin errores.
  Falta F5 de Ruben.
- Revisión de T-0093 (de `buffy`) en la misma sesión: probe del hall, comentario muerto de
  `CastleTiles` y `UILayer` en `dungeon_test.tscn` para que F6 no suelte errores.

## 2026-11-24 · `buffy` · T-0093 fondo original sin shader

- Eliminado el shader de recorte y sus materiales: el PNG del atlas nunca se
  modificó; su púrpura `#423a51` es el fondo original y los bordes de ladrillo
  terminan contra él sin el degradado inventado.
- `DungeonVoid` es ahora un `Polygon2D` opaco del mismo púrpura en `z=-5`, por
  encima del parallax del mundo y debajo de `Back`. El interior de los bordes
  usa otra vez el fondo original, como el borde del mapa.
- Probe con fondo falso magenta: no aparece dentro del hall. F5/F6 pendientes.

## 2026-11-24 · `buffy` · T-0093 orientación del marco y fondo del dungeon

- Solo el marco que rodea la sala vuelve a la orientación interior: borde
  `24/20/22/19` y esquinas `28/29/27/30`; los bloques de suelo conservan
  `20/24/19/22` con esquinas `18/21/26/23`.
- El fondo normal del mundo se colaba porque el parallax está en `z = -100` y el
  `CanvasLayer -10` quedaba detrás. `DungeonVoid` pasa a ser un `Polygon2D`
  oscuro en `z = -5`: tapa el parallax, queda debajo de `Back` y mantiene el
  negro del exterior y de las fosas.
- Chequeo visual con fondo falso magenta: no debe verse dentro del hall. F5/F6
  pendientes.

## 2026-11-24 · `buffy` · T-0093 corrección de paredes/suelo

- El atlas tiene esquinas reales: marco y suelo usan bordes `20/24/19/22` y
  esquinas `18/21/26/23`; el canto claro queda fuera del ladrillo. Las piezas
  interiores `27–30` no se usan.
- El púrpura `#423a51` pasa a ser clave de color con
  `resources/shaders/castle_cutout.gdshader`; `Back` deja de pintar `25` y
  `DungeonVoid` (CanvasLayer oscuro) da el negro exterior y de las fosas.
- Chequeo headless: marco/esquinas correctos, fosas/exterior sin celdas de
  fondo y materiales activos; F5/F6 pendientes.

## 2026-11-24 · `buffy` · T-0093 rework: sala de referencia por capas

- La mazmorra pasa de cadena de salas a **una sala de 34 × 22**: tres bloques de
  suelo, dos fosas, ocho ventanas 2×2, dos estandartes y tres plataformas de madera.
- El fondo deja de estar oscurecido; las fosas tienen repisa de madera one-way.
- Separación por responsabilidades en `scripts/structures/castle/`: `CastleLayout`
  (datos), `CastleTiles` (atlas/colisión), `CastlePainter` (capas) y
  `DungeonGenerator` (ciclo de vida). `WorldGenerator`/`WorldStructure` no se tocan.
- La capa `Floor` se renombra a `Platforms`; `Walls` conserva la colisión completa.
  Verificado con probe headless KP3 → F (semilla `20261124`, plantas 0/1); faltan F5/F6.

## 2026-11-24 · `buffy` · Mazmorra del castillo como hall de plataformas (T-0093)

- `dungeon_generator.gd`: el castillo pasa de sala plana a hall abierto con 7/9
tramos en filas 32–34, huecos de 2–3 tiles, repisa inferior con escalón de
recuperación, losas sobre huecos anchos y ruta alta con escalera en la sala central.
- El fondo de piedra `41` llega hasta el marco inferior y solo se recorta a vacío en
las fosas; las plataformas usan el remate `18` (claro arriba) en vez del `24` de techo.
- Ventanas cada 5 tiles y estandartes al 25/50/75 % del ancho. Capturas finales en
`vault/estructuras/platform_f0_*.png` y `platform_f1_*.png`.
- Verificado con harness headless (KP3 → F, semilla `20261124`, plantas 0/1): sin
errores de script. Falta F5/F6 de Ruben.

## 2026-11-24 · `buffy` · Tilemap del castillo sin huecos (T-0091)

- `dungeon_generator.gd`: el atlas no tiene un ladrillo continuo (las celdas
  `20/25/26/30` llevan el interior morado), así que `Back`, muros y techo usan la
  losa completa `41` y el remate `31`; `Floor` fija `32`/`40`.
- `_build_rooms()` reparte las salas en 4–11 tiles y la última ya no se lleva el
  resto (20 medidos con la semilla de prueba).
- Ventanas 2×2 dejan un tile antes de la partición; ventanas y estandartes no se
  colocan sobre la salida.
- Verificado con harness de renderizado (KP3 → F, plantas 0/1); falta F5/F6 de
  Ruben. `docs/dungeon.md` actualizado.

## 2026-11-24 · `buffy` · Interior de castillo y salida sin tirón (T-0089, T-0090)

- T-0090: el interior explorable usa `assets/map/structures/castle_tiles.png` (atlas 8×6
  de 32 px de `map.zip`): losas de piedra en `Back`, ladrillo naranja en `Walls`/techo,
  piedra en `Floor` y ventanas/estandartes en la nueva capa `Decor`. Celdas de 32 px,
  salas de 75×6 tiles, puerta de 4 tiles y pad de salida de 32×64 px.
- T-0089: `WorldGenerator._update_chunks()` usa la X del jugador si la cámara suavizada
  está a más de media vista + margen; la salida de la mazmorra ya no genera todos los
  chunks hasta el origen (medido a 200 000 px: 49 chunks → 5, 140 ms).
- `docs/dungeon.md` y `docs/world.md` actualizados; validado en headless, falta F5/F6.

## 2026-11-24 · `buffy` · Bugs de la fusión (T-0088)

- `DungeonLayer` coloca la mazmorra en `WORLD_OFFSET` (y −10000): ocultar/pausar `map` no desactiva la colisión de sus tiles y una montaña podía atrapar al jugador.
- `ruin_tileset.tres`: la piedra clara 8 ya tiene polígono de cuadro completo, así que las piedras del frente son sólidas; un patrón sin `tileset` se descarta y las piedras del frente se dibujan detrás del decor.
- `docs/world.md`/`docs/dungeon.md` corregidos (campo `weight` inexistente, física real del atlas, offset).

## 2026-11-24 · `buffy` · Fusión de estructuras + arte de la mazmorra (T-0088)

- `test/fusion-structure`: merge de `feat/bloques-rompibles` (T-0074/T-0075/T-0076) y
  `feat/estructura-explorable` (T-0079/T-0087); se conservan estructuras, cajas y puertas.
- La mazmorra deja `ground_tile.png` y pinta con el atlas de ruinas: ladrillo oscuro
  (`ruin_tiles_dark.png`) en fondo, techo y muros; piedra clara (`ruin_tiles.png`) en el
  suelo, con relleno oscuro debajo y física de cuadro completo.
- `docs/dungeon.md`, T-0079 y T-0088 actualizados.

## 2026-11-24 · `buffy` · Entrada a la mazmorra desde el mundo (T-0087)

- `scenes/structures/dungeon_entrance.tscn` + `scripts/world/dungeon_entrance.gd`:
  bloque negro placeholder con `Area2D`; F entra en la mazmorra.
- `WorldGenerator` coloca una puerta fija en el chunk 0 y una tirada por chunk, sin
  mover enemigos, monedas ni decor; `DungeonLayer` (`scenes/game.tscn`) oculta y pausa
  el mundo, instancia `dungeon.tscn` y la salida devuelve al jugador al mismo punto.
- `docs/dungeon.md`; pendiente F5 de Ruben y la persistencia por piso (T-0080).

## 2026-11-24 · `buffy` · Interior explorable MVP (T-0079)

- `scenes/structures/dungeon.tscn` + `scripts/world/dungeon_generator.gd`: mazmorra de 2
  pisos con semilla, salas separadas por muros con puerta, arte de ruinas
  (`ruin_tiles_dark.png` para fondo/muros y `ruin_tiles.png` para el suelo),
  `spawn_point`, `exit_requested` y `save_state()`/`load_state()` puros.
- `scenes/structures/dungeon_test.tscn` + `scripts/world/dungeon_test.gd` (F6; teclas 1/2).
- `docs/dungeon.md` nuevo + fila en el índice de `AGENTS.md`. Pendiente F6 de Ruben.
- La puerta desde el mundo se añadió en T-0087; el estado por piso sigue en T-0080.

## 2026-11-24 · `feat/bloques-rompibles` — cajas rompibles en las ruinas

| Qué | Dónde | Ticket |
|---|---|---|
| `BreakableBlock` (40 de vida, 1–3 monedas al romperse, "ya roto" persistido) colocado por `crates_per_ruin` dentro de las ruinas; clave `world/broken` en el guardado | `scripts/world/breakable_block.gd`, `scenes/world/breakable_block.tscn`, `scripts/world_generator.gd`, `scripts/save_game.gd`, `docs/world.md` | [T-0076](tickets/T-0076-bloques-rompibles.md) |

## 2026-11-18 · `opencode-jorge` · Estructuras por chunk (T-0074)

- `WorldStructure` (`scripts/world/structure.gd`) y 2 `.tres` de prueba con PNG
  placeholder: el bioma decide cuántas y cuáles, el generador las coloca por chunk con la
  semilla, apoyadas en el suelo, con márgenes y sin pisar la X de los enemigos.
- Sin colisión ni parallax; detrás del decor y de `Solid`/`GrassPaint`.
- Ficheros: `scripts/world/structure.gd` (nuevo), `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/structures/`, `assets/map/structures/`,
  `resources/world/biomes/{pradera,bosque_rojo}.tres`, `docs/world.md`, `docs/biomes.md`.
- Pendiente de F5 (rama `feat/estructuras-chunk`).

## 2026-11-17 · `buffy` · Merge de T-0054 y limpieza de ramas

| Qué | Dónde | Ticket |
|---|---|---|
| PR #8: `fix-items.icons` (Jorge) mergeada en `main` con **commit de merge** (no squash, para no perder sus commits `0860fd8`, `2477e74`, `5075d31`) | `main` `a16c11f` | [T-0054](tickets/T-0054-nuevos-objetos-ideas.md) |

- Conflictos de 7 ficheros resueltos conservando los dos lados; `items.md` y
  `colgante_hierro.md` se quedan en `en proceso` a propósito (T-0073).
- Ramas borradas (locales y en `origin`) tras el merge: todas las de features ya
  integradas. Solo queda `main`.
- Trazabilidad: `feat/enemigos-demon-toad-werewolf` (punta `a5b95d9`, 2026-11-03) se
  borra porque su código entró en T-0019; lo único que no estaba en `main` eran packs
  de arte sin adoptar (`assets/enemies/Slime_*`, `ArcherHero`, `PixelRats`) y docs
  viejos que sustituye `docs/enemies.md`.

## 2026-11-17 · `opencode-jorge` · Editor: caché y servidor viejo (T-0073)

- `Cache-Control: no-store` en HTML/CSS/JS/API, `?v=5` en las URLs y comprobación de
  versión: si el servidor en marcha es antiguo, la página avisa de que hay que reiniciarlo.
- La ficha `colgante_hierro` quedó a medias por un guardado con el servidor viejo (el
  catálogo decía `icono asignado` y la ficha `en proceso`); se deja `en proceso` en los dos
  para que `pendientes.py` la siga listando.

## 2026-11-17 · `opencode-jorge` · Editor: alta, borrado y estado editable + `pendientes.py` (T-0073)

- Estado editable otra vez, cargando el real de la ficha; si cambias contenido y no tocas
  el estado, se guarda `en proceso`.
- `+ Nuevo` crea ficha desde plantilla (consumible/pasiva) y su fila de catálogo en orden;
  `Borrar objeto` elimina ficha y fila. Los `.tres` no se tocan en ningún caso.
- `vault/items-editor/pendientes.py`: lista las fichas `en proceso` y sus diferencias con
  el `.tres` (nombre, descripción, icono, valores) o avisa de que falta el recurso.
- Arreglado el parseo de fichas con tablas alineadas (`colgante_hierro` salía vacía).

## 2026-11-17 · `opencode-jorge` · Editor de objetos: estado real y valores en avanzadas (T-0073)

- El estado ya no sale siempre `en proceso`: se muestra el estado real de la ficha y el
  servidor fuerza `en proceso` al guardar (el `.tres` no se toca).
- Los valores del recurso se mueven a un desplegable de opciones avanzadas, aclarando que
  salen de la ficha y no del `.tres`.

## 2026-11-17 · `opencode-jorge` · Editor de objetos: CSS, iconos y fuente `.md` (T-0073)

- El servidor servía `style.css`/`app.js` como `text/plain` y el navegador los ignoraba:
  ahora se manda el MIME correcto y las rutas son relativas.
- Los iconos de la lista pedían `/items/*.png` (404); ahora `/assets/*.png`. Los 44 cargan.
- La lista se construye desde `vault/items/*.md` (el catálogo solo rellena huecos); el
  editor añade `?slug=` y un visor del `.md` guardado, y el estado arranca en `en proceso`.

## 2026-11-17 · `opencode-jorge` · Editor web de objetos (T-0073)

- `vault/items-editor/`: servidor Python (stdlib) + página que lista los 44 objetos con
  buscador y filtros por estado, y edita nombre, textura, estado, habilidad y valores del
  recurso. Guarda en la ficha y en su fila de `vault/items.md`, y deja el objeto
  `en proceso` con el pendiente "aplicar en el `.tres` y en el juego" (no toca los `.tres`).
- Arranque: `python3 vault/items-editor/server.py` → http://127.0.0.1:8765.
- Probado con `--root` sobre una copia del vault; la UI no se ha abierto en navegador.

## 2026-11-17 · `opencode-jorge` · Inventario legible y slots fijos (T-0072)

- Fuentes del panel derecho del inventario a 15 (nombre) y 12 (stats/descripción);
  cabeceras 13, contador 11 y preview 96 px.
- `ItemDescription.clip_text`: con nombre/stats/descripción largos la ventana ya no crece
  (mínimo 248 px en vez de 404).
- `InventorySlot.expand_icon = true` en la escena: el slot manda (18×18 HUD, 40×40
  inventario) y el icono se adapta; los 4 iconos de 32×32 ya no estiran la barra.
- Las 44 fichas de `vault/items/` regeneradas desde los `.tres` (valores, icono y estado).

## 2026-11-17 · `opencode-jorge` · Sincronizar el vault tras el F5 (T-0068)

- Ruben confirmó que todo lo que estaba en `revision` funciona probado en el editor:
  **52 tickets cerrados en bloque** (T-0001, T-0002, T-0017–T-0029, T-0030–T-0049,
  T-0051–T-0067) con sus casillas de F5 marcadas. T-0001 queda absorbido por T-0019.
- **T-0002 descartado**: no hay skills y no las habrá.
- Diseño de objetos confirmado: solo consumibles (huecos 1/2/3, ampliables) y
  coleccionables con una habilidad pasiva, siempre activa o condicional (taparrabos =
  siempre). **Sin armas, nunca.** `ideas.md` §4.1 y las decisiones 14-16 reescritas;
  `docs/items.md` con la nota de taxonomía; `docs/passives.md` y `vault/items.md` con
  "coleccionable" como nombre de diseño; `roadmap.md` sin skills/armas ni cerrados.
- `estado.md` reescrito: `main` en `3001492` con PR #1 y #3 mergeados, árbol limpio y
  siguiente paso T-0003 + coleccionables del arquero.
- Árbol: `mutant_toad.tscn` revertido (el editor borraba `node_paths`, el script ya tiene
  `get_node_or_null`) y `.obsidian/` añadido a `.gitignore`.

## 2026-11-17 · `fix-items.icons` — nuevos objetos de `ideas.md`

| Qué | Dónde | Ticket |
|---|---|---|
| 14 objetos nuevos (arquero, esqueleto, fantasma y demonio), arco cargado, invulnerabilidad, teleport, rata, DOT de quemadura y loot en cuatro enemigos; `Fragmento` queda fuera | `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/collectables/*.gd`, `resources/*.tres`, `scenes/collectables/player_arrow.tscn`, `scenes/enemies/*.tscn`, `docs/items.md`, `docs/player.md`, `docs/enemies.md`, `vault/ideas.md`, `vault/pasivas/arquero.md` | [T-0054](tickets/T-0054-nuevos-objetos-ideas.md) |

## 2026-11-13 · `main` — correcciones de iconos de pasivas

| Qué | Dónde | Ticket |
|---|---|---|
| Ajustes de sprites pedidos y renombrados `Hunter's Faith` y `Sanguine Ruby`; preview de cambios | `resources/armadura_*.tres`, `resources/cazador.tres`, `resources/codicia.tres`, `resources/colmillo_lobo.tres`, `resources/corazon_hierro.tres`, `resources/garras_lobo.tres`, `resources/moco.tres`, `resources/piel_lobo.tres`, `resources/pies_ligeros.tres`, `resources/pulso_vampirico.tres`, `assets/items/sanguine_ruby.png`, `docs/items.md` | [T-0071](tickets/T-0071-ajustes-iconos-pasivas.md) |

## 2026-11-13 · `main` — iconos de pasivas pendientes

| Qué | Dónde | Ticket |
|---|---|---|
| 34 pasivas con un `item###.png` distinto y adecuado (amuletos, anillo, armaduras, garras, botas...); `Focus` excluido; preview antes/despues | `resources/adn_hombre_lobo.tres`, `resources/amuleto_*.tres`, `resources/anillo_vigor.tres`, `resources/armadura_*.tres`, `resources/*.tres`, `docs/items.md`, `docs/pasivas-antes-despues.png` | [T-0070](tickets/T-0070-iconos-pasivas-pendientes.md) |

## 2026-11-13 · `main` — iconos de consumibles y tiers de pociones

| Qué | Dónde | Ticket |
|---|---|---|
| Vida/estamina en tiers 20/50/100 con sus iconos; `Vital Essence` -> `Vigorizing Pie`; `Mucus Heart` -> `Mucus Essence`; preview antes/despues | `resources/pocion_*.tres`, `resources/elixir_vida.tres`, `resources/bebida_tonificante.tres`, `resources/esencia_vital.tres`, `resources/corazon_mucosil.tres`, `docs/items.md`, `docs/pociones-antes-despues.png` | [T-0069](tickets/T-0069-iconos-consumibles-y-pociones.md) |

## 2026-11-12 · `main` — tope de pendiente en el terreno

| Qué | Dónde | Ticket |
|---|---|---|
| `max_step_tiles` (1) acota cada columna a ±1 fila de la anterior, con cadena cacheada por chunk y costuras exactas; fuera `_terrain_at_tile()` | `scripts/world_generator.gd`, `docs/world.md` | [T-0049](tickets/T-0049-barreras-verticales-en-el-terreno.md) |

## 2026-11-10 · `main` — coords y seed en el debug, semilla al crear mundo

| Qué | Dónde | Ticket |
|---|---|---|
| El overlay de debug añade `pos`, `tile` y la seed de la partida; Nueva partida pide semilla (vacío = aleatoria) y se pasa al generador por `SaveGame.pending_seed` | `scripts/debug_tools.gd`, `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/save_game.gd`, `scripts/world_generator.gd` | [T-0048](tickets/T-0048-coords-seed-en-debug-y-semilla-al-crear-mundo.md) |

## 2026-11-10 · `main` — fondo del menú igual que el del spawn

| Qué | Dónde | Ticket |
|---|---|---|
| La `Camera2D` del menú pasa a la posición del spawn (808, 773): las capas de pinos dejan de separarse y el menú encaja con el juego | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd` | [T-0047](tickets/T-0047-fondo-del-menu-igual-al-spawn.md) |

## 2026-11-10 · `main` — pantalla completa sin bandas (viewport adaptativo)

| Qué | Dónde | Ticket |
|---|---|---|
| Fuera las bandas sin volver al factor fraccional: la escala es entera y el viewport crece a `ventana / factor` (más mundo visible); lista ampliada a 18 resoluciones | `scripts/ui/settings_panel.gd` | [T-0046](tickets/T-0046-pantalla-completa-sin-bandas.md) |

## 2026-11-10 · `main` — parallax sin tirones: escala entera también en fullscreen

| Qué | Dónde | Ticket |
|---|---|---|
| Fuera `STRETCH_FRACTIONAL`: la escala es siempre entera (fullscreen 1080p = 2× con bandas), lo que elimina el tirón de las montañas; la lista de resoluciones pasa a ser solo múltiplos exactos del viewport | `scripts/ui/settings_panel.gd` | [T-0045](tickets/T-0045-parallax-a-tirones-escala-fraccional.md) |

## 2026-11-10 · `main` — biomas por tramos y sangre por enemigo

| Qué | Dónde | Ticket |
|---|---|---|
| Biomas por tramos con duración mínima/máxima (sin microbiomas ni gigabiomas), desbloqueo por distancia y mundo generado solo hacia la derecha con tope en el borde izquierdo | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/biomes/nieve.tres` | [T-0044](tickets/T-0044-biomas-por-tramos-y-solo-derecha.md) |
| `blood_color` por enemigo en el estallido de muerte (por defecto, el rojo de siempre) | `scripts/enemies/enemy_base.gd`, `scripts/fx.gd` | [T-0043](tickets/T-0043-sangre-por-enemigo.md) |

## 2026-11-10 · `main` — pausa, ajustes compartidos y guardado

| Qué | Dónde | Ticket |
|---|---|---|
| Pausa con Esc (Reanudar / Ajustes / Guardar y salir), panel de ajustes reutilizado por menú y pausa, fullscreen y resoluciones no múltiplo a pantalla completa con `STRETCH_FRACTIONAL`, y guardado mínimo en `user://savegame.cfg` que Continúa donde se dejó | `scenes/ui/pause_menu.tscn`, `scenes/ui/settings_panel.tscn`, `scripts/ui/pause_menu.gd`, `scripts/ui/settings_panel.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scripts/player.gd`, `scenes/inventory/inventory.gd`, `scripts/collectables/player_passive.gd`, `scripts/world_generator.gd`, `scripts/world/fall_intro.gd` | [T-0042](tickets/T-0042-menu-de-pausa-y-guardado.md) |

## 2026-11-10 · `main` — menú principal con ajustes

| Qué | Dónde | Ticket |
|---|---|---|
| Menú con Nueva partida, Continuar (solo si hay `user://savegame.cfg`), Ajustes y Salir; panel de ajustes con modo de ventana y resoluciones múltiplo del viewport guardadas en `user://settings.cfg` | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `docs/ui.md` | [T-0041](tickets/T-0041-menu-principal-y-ajustes.md) |

## 2026-11-10 · `main` — banda de montaña con el color del bioma

| Qué | Dónde | Ticket |
|---|---|---|
| `MountainBase` pasa a teñirse con el `forest_color` del bioma oscurecido 0.35 (la pradera reproduce el `#283D43`), con la misma transición por bloque que pinos y roca | `scripts/world_generator.gd`, `docs/world.md`, `docs/ui.md` | [T-0040](tickets/T-0040-mountainbase-color-de-bioma.md) |

## 2026-11-10 · `main` — caída inicial más corta

| Qué | Dónde | Ticket |
|---|---|---|
| Caída de entrada de 520→260 px y 300→620 px/s (~0,7 s en total con los 6 tiles del generador); red de seguridad de 6→3 s | `scripts/world/fall_intro.gd`, `docs/player.md` | [T-0039](tickets/T-0039-caida-inicial-mas-corta.md) |

## 2026-11-10 · `main` — fuera skills, 3 consumibles

| Qué | Dónde | Ticket |
|---|---|---|
| Inventario de 3 consumibles con teclas 1-3; `Skills` eliminado y `docs/items.md` convertido en catálogo completo | `scenes/inventory/inventory.gd`, `inventory_ui.gd`, `inventory_screen.gd`, `inventory_screen.tscn`, `scripts/collectables/Skills.gd`, `project.godot`, `docs/items.md` | [T-0038](tickets/T-0038-quitar-skills-3-consumibles.md) |

## 2026-11-09 · `main` — loot por enemigo, sin presets

| Qué | Dónde | Ticket |
|---|---|---|
| `item_drops` por escena con `LootEntry`; una sola tirada de objetos que suma probabilidades y elige ponderado, y monedas en tirada aparte (varias posibles) | `scripts/enemies/enemy_base.gd`, `scripts/resources/loot_entry.gd`, `scenes/enemies/{orc,werewolf,mutant_toad,slime}.tscn` | [T-0037](tickets/T-0037-loot-por-enemigo-sin-presets.md) |

## 2026-11-09 · `main` — slimes en el bosque y menos lobos

| Qué | Dónde | Ticket |
|---|---|---|
| Bosque rojo: 2 slimes nuevos y lobos de 2 a 1 por chunk | `resources/world/biomes/bosque_rojo.tres` | [T-0036](tickets/T-0036-slime-y-lobo-en-bosque.md) |

## 2026-11-09 · `main` — lobo menos agresivo

| Qué | Dónde | Ticket |
|---|---|---|
| Embestida a 150 px/s, 40 % del diámetro de detección y 1,5 s parado en el destino antes de repetir | `scripts/enemies/werewolf.gd` | [T-0035](tickets/T-0035-lobo-menos-agresivo.md) |

## 2026-11-06 · `main` — inventario al doble

| Qué | Dónde | Ticket |
|---|---|---|
| Ventana 744×380, paneles 168/272/232, fuentes 16-20, huecos 40×40 y coleccionables 32×32 con el icono expandido; el HUD no cambia | `scenes/inventory/inventory_screen.tscn`, `scenes/inventory/inventory_screen.gd` | [T-0034](tickets/T-0034-inventario-al-doble.md) |

## 2026-11-06 · `main` — la sacudida respeta el encuadre de cámara

| Qué | Dónde | Ticket |
|---|---|---|
| La sacudida se suma al `offset` base de la `Camera2D` (60, −70) y lo restaura al terminar, en vez de dejarlo a cero y recentrar la vista para siempre | `scripts/fx.gd` | [T-0033](tickets/T-0033-sacudida-camara-offset-base.md) |

## 2026-11-05 · `main` — daño en el panel y ambiente más ancho

| Qué | Dónde | Ticket |
|---|---|---|
| Fila `Daño` en el panel de stats y panel bajado a (5, 82) para no pisar las monedas | `scripts/player.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |
| Emisión de hojas/copos al doble de ancho (extents X ×1,2) y al doble de cantidad (56 hojas, 440 copos) | `scripts/world/biome_particles.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |

## 2026-11-05 · `main` — parry retocado y estadísticas del jugador

| Qué | Dónde | Ticket |
|---|---|---|
| Parry de 0,2 s con enfriamiento de 0,3 s, aviso dorado al abrir la ventana y +30 stamina al acertar; la guardia ya no empuja | `scripts/player.gd`, `scripts/fx.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Estadísticas base: `attack_speed`, `crit_chance`, `crit_damage`, `luck` (la velocidad es `move_speed`); crítico con FX propio | `scripts/player.gd`, `scripts/fx.gd`, `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Panel `UILayer/StatsPanel` a la izquierda, siempre visible y alpha 0,6 | `scripts/player.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| La suerte suma `luck × 0,01` a todas las probabilidades de drop | `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |

## 2026-11-05 · `main` — polvo del bioma, parry y física de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| Polvo teñido con el `grass_color` del bioma (verde en pradera) | `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Ventana de parry de 0,18 s con chispas, `¡PARRY!`, destello y sacudida | `scripts/player.gd`, `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Monedas con gravedad, rebote y vaivén; nacen 40 px sobre el suelo | `scripts/collectables/coin.gd`, `scripts/world_generator.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Objetos con salto inicial al dropearse (`drop_hop` 150 px/s) | `item_pickup.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |

## 2026-11-05 · `main` — polvo a los pies, sangre grande y moco por la hitbox

| Qué | Dónde | Ticket |
|---|---|---|
| El polvo de saltar/aterrizar/correr nace a ras de suelo (`_feet_offset()`) | `scripts/player.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Muerte de enemigo con reventón de sangre en 4 capas y sacudida leve | `scripts/fx.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Moco emitido en caja por toda la hitbox, no desde el centro | `scripts/collectables/moco_emitter.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |

## 2026-11-05 · `main` — efectos de combate y feedback de HUD

| Qué | Dónde | Ticket |
|---|---|---|
| Nodo `fx`: chispas, estallidos, polvo, chispas de pickups, números de daño, sacudida y flash rojo | `scripts/fx.gd`, `scenes/game.tscn` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Enganches de VFX en jugador, enemigos, monedas y pickups | `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/collectables/coin.gd`, `item_pickup.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Pop del contador de monedas y latido de la barra de vida con poca vida | `scripts/player.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Fundido y viento en hojas/copos | `scripts/world/biome_particles.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |

## 2026-11-05 · `main` — nieve separada, bioma de nieve y ambiente

| Qué | Dónde | Ticket |
|---|---|---|
| Overlay del bosque corregido (ya no incluye piedra ni nieve) y nieve extraída a `mountain2_snow.png`, dibujada encima y sin teñir | `assets/map/background/mountain2_gray.png`, `mountain2_snow.png`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| `Biome.rock_color` para la piedra; bioma de nieve con sus colores y enemigos; pesos 0.55/0.3/0.2 | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Bosque rojo 1.35/1.1 y pradera 0.95 de amplitud | `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Hojas rojas y copos de nieve por bioma (`Biome.ambient`) | `scripts/world/biome_particles.gd`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |

## 2026-11-05 · `main` — un tono por capa de fondo

| Qué | Dónde | Ticket |
|---|---|---|
| Gris calibrado por capa (cercano 92, lejano 116, montaña 172/211) para que los tres fondos no queden del mismo color | `assets/map/background/{pine1,pine2,mountain2}_gray.png` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |
| El tinte de cada bioma conserva los tres escalones de profundidad en pradera y bosque rojo | `resources/world/biomes/*.tres`, `docs/world.md` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |

## 2026-11-05 · `main` — gris medio y verde original en la pradera

| Qué | Dónde | Ticket |
|---|---|---|
| Fondos de vegetación con gris medio (~113–129) en vez del gris claro (~165) | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |
| `Biome.forest_color` separa el tinte de los fondos del césped; la pradera recupera `(27,45,45)` y el bosque rojo usa un rojo saturado | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |

## 2026-11-05 · `main` — fondos tintables y terreno por bioma

| Qué | Dónde | Ticket |
|---|---|---|
| Pinos y bosque de la montaña en gris claro; solo los píxeles verdes/teal se convierten y la punta de la montaña queda sin teñir | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png`, `scenes/game.tscn` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |
| Bosque rojo con relieve más marcado: amplitud ×1.7 y frecuencia ×1.25, mezcladas en la transición de 256 bloques | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/bosque_rojo.tres` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |

## 2026-11-05 · `main` — biomas por bloque y más bosque rojo

| Qué | Dónde | Ticket |
|---|---|---|
| Bioma y césped decididos por bloque, con transición de 256 bloques (1 chunk) en vez de por chunks | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `scenes/world/chunk.tscn` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Bosques de fondo teñidos al cambiar de bloque | `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Más bosque rojo: pesos 0.6/0.4 y biomas de ~8 chunks (`biome_frequency` 0.12) | `resources/world/biomes/*.tres`, `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |

## 2026-11-05 · `main` — KP5 inmortal, pasivas sin stack y caducidad de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| KP5 alterna la inmortalidad del jugador y el aviso de debug lo muestra | `scripts/debug_tools.gd`, `scripts/player.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Las pasivas equipadas no vuelven a recogerse ni a dropearse (`has_passive`/`add_passive` + pool filtrado) | `scripts/collectables/player_passive.gd`, `scripts/collectables/passive_items.gd`, `scripts/enemies/enemy_base.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Pickups: borrado a los 60 s desde el spawn; parpadeo a los 25 s y desaparición a los 30 s desde que se ven; monedas excluidas | `item_pickup.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |

## 2026-11-03 · `main` — voladores fuera, reparto y banda plana

| Qué | Dónde | Ticket |
|---|---|---|
| Fantasma y demonio desactivados (`DISABLED_ENEMY_SCENES`) y recuento base a `[4, 2, 1, 2, 2, 2]` | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Enemigos repartidos en huecos iguales a lo ancho del chunk (±25 % de ruido) | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Banda plana `#283D43` bajo las montañas en menú y partida | `scenes/main_menu.tscn`, `scenes/game.tscn` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Docs de todo el trabajo acumulado y primer commit de la tanda | `docs/`, `vault/` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) / [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |

## 2026-11-03 · `main` (local, sin commit) — arranque, drops y dificultad

| Qué | Dónde | Ticket |
|---|---|---|
| Caída inicial arreglada: sin parqueo de cámara (saltaba ~270 px al enganchar) y de 2200 → 520 px (~1,7 s) | `scripts/world/fall_intro.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Drops bastante más raros: moneda al 45 %, objeto al 30 %, `Raro` 0.25 y 2 monedas por chunk (antes 8) | `scripts/enemies/enemy_base.gd`, `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Desactivados los 6 objetos originales (loot, debug y los dos pickups de prueba de `game.tscn`) | `scripts/enemies/enemy_base.gd`, `scenes/inventory/inventory.gd`, `scenes/game.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Balance: `maza` +2, `colmillo_lobo` +3, `pies_ligeros` 10 %, `piedra_oro` 10 % | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Enemigos algo más fuertes (vida ×1.35, daño ×1.25) y slime más pequeño (×1.2) | `scripts/enemies/enemy_base.gd`, `scenes/enemies/slime.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Más enemigos por chunk con escalada: 3 en los chunks 0–1 y hasta 16 más adelante | `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Fix: los 11 objetos del compañero apuntaban a `assets/icons/`, que no existe | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |

## 2026-11-03 · `main` (local, sin commit)

| Qué | Dónde | Ticket |
|---|---|---|
| Fixes de prueba: relleno bajo las montañas, sin negro de transición, caída lenta (~7 s), enemigos al doble, iconos a 16 px y enemigos más cerca del spawn | `scenes/main_menu.tscn`, `scripts/world/fall_intro.gd`, `scenes/enemies/*.tscn`, `resources/*.tres`, `scripts/world_generator.gd` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) / [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Todo lo del compañero (demonio, sapo, lobo, slime, esqueleto, arquero + 11 objetos) y loot por enemigo según su tabla | `scenes/enemies/*.tscn`, `scripts/enemies/*.gd`, `scripts/collectables/*`, `resources/*.tres`, `scripts/player.gd`, `scripts/world_generator.gd` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| 8 pasivas nuevas de rana y slime + sección `vault/pasivas/` con un `.md` por enemigo | `resources/*.tres`, `scripts/collectables/`, `vault/pasivas/` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Nombre del juego **OffBeaten Path** + menú principal (cielo, nubes y montañas) y caída desde el cielo al empezar, como pantalla de carga | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `project.godot`, `scenes/game.tscn` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) |
| Ciclo día/noche: día 5 min, noche 3 min; la noche solo cambia el color del cielo | `scripts/world/day_night.gd`, `scenes/game.tscn` | [T-0014](tickets/T-0014-ciclo-dia-noche.md) |
| Debug: velocidad x1/x2/x4 (KP7/8/9) y viaje rápido KP4/KP6 | `scripts/debug_tools.gd`, `scripts/player.gd`, `scenes/game.tscn` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Noche: estrellas, montañas más oscuras y velo negro del 10% | `scripts/world/day_night.gd` | [T-0016](tickets/T-0016-noche-estrellas-y-velo.md) |
| Debug: las velocidades x2/x4 pasan a x5/x20 | `scripts/debug_tools.gd` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Pasivas de ogro y lobo (9): recursos, efectos y calidad | `resources/*.tres`, `scripts/collectables/*Passive.gd`, `scripts/enemies/enemy_base.gd` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |
| Fix: `day_night.gd` no parseaba (dos líneas comidas) y `NightBonusPassive` no infería `night_now`; UID obsoleto en `ghost_projectile.tscn` | `scripts/world/day_night.gd`, `scripts/collectables/NightBonusPassive.gd`, `scenes/enemies/ghost_projectile.tscn` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |

## 2026-10-29 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `a914593` | Loot de enemigos: parentar antes de `global_position` (el offset del chunk se sumaba dos veces) | [T-0011](tickets/T-0011-fix-loot-drops.md) |
| `47647cb` | Cámara: seguimiento sobre `player.global_position` (el lag era permanente) | [T-0009](tickets/T-0009-fix-camara.md) |
| `0e92787` | `stretch/scale_mode="integer"`: fullscreen a 2× exactos | [T-0010](tickets/T-0010-fix-escala-entera.md) |
| `09d1679` | Saltos de 1 tile repartidos en 3 frames (máx. 6 px/frame) | [T-0009](tickets/T-0009-fix-camara.md) |
| `932d79b` | Cámara redondeada a píxel entero; 2 chunks extra cargados | T-0009 / T-0013 |
| `6f79135` | Escala 2× entera, subida de escalón sin frenar, primer chunk seguro | T-0009 / T-0010 |

## 2026-10-25 → 2026-10-27 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `30b45de` | Más holgura de spawn (el fantasma atacaba al aparecer); cámara en física | T-0009 |
| `b9204c9` | Subida de escalones sin tirones; montañas más suaves | T-0009 |
| `bea8591` | Costuras de chunk, chunks de 256 tiles y menos enemigos | T-0013 |
| `e201ecd` | BIG REFACTOR de escala de pantalla | T-0010 |
| `19d7363` | Mundo procedural con montañas, chunks dinámicos y persistencia | T-0013 |

## 2026-10-22 → 2026-10-23 · `main`

- Pasivas paginadas en HUD (10 filas) e inventario (6 filas): `37fd815`.
- Inventario movido a `scenes/inventory/`, `InventorySlot` reutilizable en HUD: `7dfdd41`, `dbff31f` (T-0012).

## 2026-10-14 → 2026-10-15 · `main`

- Sistema de objetos: inventario de 5 huecos, consumibles, pasivas y loot enemigo (`2530489`, `8e52811`, `4c7f595`, `58c4a0f`) (T-0012).
- Recogida automática al tocar y física de drops (T-0011).

## 2026-09-17 → 2026-10-13 · base

- Movimiento, suelo y tilemaps; parallax y assets (Jorge: `7dd0e62`, `317c66a`, `60f4808`).
- Enemigo base, fantasma con TP y proyectil; orcos 2.0 (Jorge: `9aac4dc`, `1dba7bd`).
- Monedas, stamina y barra de vida.

## Rama del compañero (NO integrada)


**`origin/feat/enemigos-demon-toad-werewolf`** · `685bc30` (2026-10-27, Jorge) · base `58c4a0f` (2026-10-15) · 1 commit sobre su base.

Aporta tres enemigos completos (escena + script + doc) y assets:

| Enemigo | Scripts | Escenas | Doc de la rama |
|---|---|---|---|
| Demonio volador | `demon.gd`, `demon_fire.gd` | `demon.tscn`, `demon_fire.tscn` | `docs/enemigo_demon.md` |
| Sapo mutante | `mutant_toad.gd`, `toad_projectile.gd` | `mutant_toad.tscn`, `toad_projectile.tscn` | `docs/enemigo_mutant_toad.md` |
| Lobo | `werewolf.gd` | `werewolf.tscn` (+ `werewolf.tscn` y `plantilla_enemy.tscn` en la raíz) | `docs/enemigo_werewolf.md` |

También toca `scripts/player.gd` (knockback/knockup/`is_guarding`) y `scripts/world_generator.gd` (zonas). Detalle y plan de integración: [T-0001](tickets/T-0001-integrar-enemigos-companero.md).

## 2026-11-13 · `feat/decor` — el lobo vuelve a moverse y elige salida tras el stun

| Qué | Dónde | Ticket |
|---|---|---|
| Arreglo: faltaba la rama `RECOVER` en el `match` del lobo, así que tras su primera embestida se quedaba quieto para siempre; ahora retoma el ataque o vuelve a vagar | `scripts/enemies/werewolf.gd`, `docs/enemies.md` | [T-0064](tickets/T-0064-lobo-recuperacion-y-stun.md) |
| Al salir del stun el lobo elige al azar entre embestir y saltar (`stun_jump_chance` 0.5) en vez de repetir siempre embestida | `scripts/enemies/werewolf.gd` | [T-0064](tickets/T-0064-lobo-recuperacion-y-stun.md) |

## 2026-11-13 · `feat/decor` — la cima mantiene su color original fuera de la nieve

| Qué | Dónde | Ticket |
|---|---|---|
| El canal `snow` se usa en todos los biomas: por defecto `(0.72, 0.66, 0.65)` devuelve el color original de la cima (±5 % medido), prado añade `(0.715, 0.675, 0.625)` y bosque rojo `(0.74, 0.65, 0.625)` como mini toque, y la nieve sigue en blanco | `scripts/world/biome.gd`, `resources/world/biomes/{pradera,bosque_rojo}.tres`, `docs/biomes.md` | [T-0063](tickets/T-0063-cimas-blancas-nieve.md) |

## 2026-11-13 · `feat/decor` — la capa de nieve cubre toda la cima

| Qué | Dónde | Ticket |
|---|---|---|
| `mountain2_snow.png` solo recogía el tono de brillo (5.944 px) y dejaba la cara iluminada y la de sombra como roca teñida: se regenera con los tres tonos de la roca (blanco puro / `222, 230, 242` / `150, 162, 180`, 39.554 px) y la capa pasa a mostrarse solo en el bioma nevado (`snow_color` con alpha 0 por defecto) | `assets/map/background/mountain2_snow.png`, `scripts/world/biome.gd`, `resources/world/biomes/nieve.tres`, `docs/biomes.md` | [T-0063](tickets/T-0063-cimas-blancas-nieve.md) |

## 2026-11-13 · `feat/decor` — cimas blancas en la nieve

| Qué | Dónde | Ticket |
|---|---|---|
| La capa de nieve de la montaña de fondo (`mountains/Sprite2DSnow`) gana su propio canal (`Biome.snow_color`, `snow_tint_paths`): el bioma nevado la empuja por encima de blanco (`1.55, 1.6, 1.65`) para que la cima quede blanca pura, y su `rock_color` sube a `(0.92, 0.94, 0.98)` | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/nieve.tres`, `docs/biomes.md` | [T-0063](tickets/T-0063-cimas-blancas-nieve.md) |

## 2026-11-13 · `feat/decor` — el parry perfecto aturde al lobo

| Qué | Dónde | Ticket |
|---|---|---|
| `Player.parried(attacker)` avisa al enemigo del parry: el lobo corta la embestida y se queda en `STUN` 0.8 s (`parry_stun_time`, destello azulado) antes de volver al aviso. Su `charge_speed` baja a 140 (sigue por encima del paseo, 130) y `uses_custom_contact_damage()` evita que el daño de contacto genérico se sume a su hitbox | `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/enemies/werewolf.gd`, `docs/enemies.md`, `docs/player.md` | [T-0062](tickets/T-0062-lobo-parry-aturdimiento.md) |

## 2026-11-13 · `feat/decor` — contador de metros arriba al centro

| Qué | Dónde | Ticket |
|---|---|---|
| `UILayer/Meters` muestra los bloques recorridos desde el spawn arriba al centro (`0 m` al empezar, negativos detrás del inicio) con `WorldGenerator.meters_at()` y refresco solo al cambiar de bloque; el guardado escribe `[run] meters` y Load lo enseña junto a las monedas | `scenes/game.tscn`, `scripts/game.gd`, `scripts/world_generator.gd`, `scripts/save_game.gd`, `scripts/ui/main_menu.gd`, `docs/ui.md` | [T-0061](tickets/T-0061-contador-de-metros.md) |

## 2026-11-13 · `feat/decor` — aviso al guardar sin hueco libre

| Qué | Dónde | Ticket |
|---|---|---|
| New Game ya no borra la run más antigua en silencio: con los tres slots llenos, Start abre `LoadDialog` en modo sobrescritura (`No free slots — overwrite which run?`) para elegir qué partida se reemplaza; las filas muestran metros y monedas | `scripts/save_game.gd`, `scripts/ui/main_menu.gd`, `docs/ui.md` | [T-0060](tickets/T-0060-guardado-en-tres-slots.md) |

## 2026-11-13 · `feat/decor` — arreglo: la pantalla de muerte no aparecía

| Qué | Dónde | Ticket |
|---|---|---|
| El editor abierto había reserializado `game.tscn` y borrado el nodo `DeathScreen`, así que al morir no se mostraba nada; vuelve el nodo a la escena y `Game._ensure_death_screen()` instancia `death_screen.tscn` si falta (comprobado headless: `screen_visible=true`, `paused=true`) | `scenes/game.tscn`, `scripts/game.gd`, `docs/ui.md` | [T-0059](tickets/T-0059-pantalla-de-muerte-y-fin-de-run.md) |

## 2026-11-13 · `feat/decor` — menú con New Game, Continue y Load

| Qué | Dónde | Ticket |
|---|---|---|
| Vuelve el menú de New Game/Continue: Continue carga `latest_slot()` (el slot escrito más recientemente, la última run cerrada) y un botón Load abre `LoadDialog` con los tres slots (`Play` para cargar, `Erase` para liberar, `Back`/Esc); New Game escribe en el primer slot libre o, si los tres están llenos, en el más antiguo | `scripts/ui/main_menu.gd`, `scenes/main_menu.tscn`, `scripts/save_game.gd`, `docs/ui.md` | [T-0060](tickets/T-0060-guardado-en-tres-slots.md) |

## 2026-11-13 · `feat/decor` — tres slots de guardado

| Qué | Dónde | Ticket |
|---|---|---|
| El guardado único pasa a tres runs en `user://run_slot_N.cfg` con `SaveGame.current_slot`: el menú estrena tres filas de slot (`Play` continúa o empieza una run nueva, `Erase` libera el slot) y "Guardar y salir" escribe en el slot en curso; empezar en un slot ocupado borra el guardado viejo al instante | `scripts/save_game.gd`, `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/ui/pause_menu.gd`, `docs/ui.md` | [T-0060](tickets/T-0060-guardado-en-tres-slots.md) |

## 2026-11-13 · `feat/decor` — pantalla de muerte y fin de la run

| Qué | Dónde | Ticket |
|---|---|---|
| Morir ya no deja la partida abierta: `player.died` llega a `Game._on_player_died()`, que borra el slot de la run, espera 1.4 s y muestra `DeathScreen` (`You died` + seed/monedas + Menú principal/Salir) con el árbol pausado; una run muerta no se guarda ni se puede continuar | `scripts/player.gd`, `scripts/game.gd`, `scripts/save_game.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/death_screen.gd`, `scenes/ui/death_screen.tscn`, `scenes/game.tscn`, `docs/player.md`, `docs/ui.md` | [T-0059](tickets/T-0059-pantalla-de-muerte-y-fin-de-run.md) |

## 2026-11-13 · `feat/decor` — atravesar enemigos cuesta vida

| Qué | Dónde | Ticket |
|---|---|---|
| El jugador ya no empuja a los enemigos al andar: slime, esqueleto y arquero bajan a `collision_mask` 1 (como el resto) y, al cruzar un cuerpo enemigo, recibe `body_contact_damage` (5) con `body_contact_cooldown` (1 s) por enemigo, vía `take_damage_from()` para que el guardia frontal lo pare | `scripts/player.gd`, `scenes/enemies/{slime,skeleton,archer}.tscn`, `docs/player.md`, `docs/enemies.md` | [T-0058](tickets/T-0058-atravesar-enemigos-con-dano.md) |

## 2026-11-13 · `feat/decor` — vegetación nevada casi blanca

| Qué | Dónde | Ticket |
|---|---|---|
| La nieve estrena tintes de vegetación casi blancos (`0.98/0.88/0.78` con 3/3/2) para que arbustos y árboles vivos se lean escarchados en vez de grises | `resources/world/biomes/nieve.tres`, `docs/decor.md`, `docs/biomes.md` | [T-0057](tickets/T-0057-decoraciones.md) |

## 2026-11-12 · `feat/decor` — tercera pasada de decoraciones

| Qué | Dónde | Ticket |
|---|---|---|
| Troncos ya no se tiñen: la copia tintada se genera por píxel en runtime y solo recolorea las hojas verdes, con `modulate` en blanco; separación mínima de 3 tiles mediante slots estratificados; densidad baja a 20/26/10 por chunk (pradera/bosque rojo/nieve); la nieve deja el 40% de sus árboles muertos con `decor_dead_tree_ratio` | `scripts/world_generator.gd`, `scripts/world/decor_prop.gd`, `scripts/world/biome.gd`, `resources/world/biomes/*.tres`, `docs/decor.md` | [T-0057](tickets/T-0057-decoraciones.md) |

## 2026-11-12 · `feat/decor` — segunda pasada de decoraciones

| Qué | Dónde | Ticket |
|---|---|---|
| Decoración más grande (×1.7–1.9) y decidida por bioma: 32 por chunk en pradera (~13 árboles), 52 en bosque rojo (~35 árboles) y 24 en nieve, con tipos y pesos propios; tintes ponderados (rojo 6 / naranja 3 / amarillo 1 en bosque rojo); rocas a `z_index` −1 detrás de árboles y arbustos; arbustos se inclinan al pasar y sueltan 7 hojas vía `fx.leaves()` | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `scripts/fx.gd`, `resources/world/biomes/`, `docs/decor.md`, `docs/biomes.md`, `docs/world.md`, `docs/fx.md` | [T-0057](tickets/T-0057-decoraciones.md) |

## 2026-11-12 · `feat/decor` — decoraciones de bioma

| Qué | Dónde | Ticket |
|---|---|---|
| Arbustos, árboles y rocas de `assets/map/decor` se spawnean por chunk detrás del suelo, apoyados en la superficie, sin colisión ni parallax; arbustos y árbol vivo usan copias grises y cada decorado tinta con un color aleatorio del array `decor_colors` del bioma (3 verdes, 3 rojos/naranjas, 3 verdes fríos) | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/biomes/`, `assets/map/decor/`, `docs/decor.md`, `docs/biomes.md`, `docs/world.md`, `AGENTS.md` | [T-0057](tickets/T-0057-decoraciones.md) |

## 2026-11-12 · `main` — auditoría de documentación

| Qué | Dónde | Ticket |
|---|---|---|
| Docs de enemigos e items reescritos con datos verificados; nuevos `biomes`, `loot` y `passives`; corregidos mundo (ventana, biomas, caída), UI (debug), jugador (stats), historial y README; el vault estrena mapa de documentación con los huecos reales | `docs/`, `README.md`, `AGENTS.md`, `vault/documentacion.md`, `vault/pasivas/` | [T-0056](tickets/T-0056-auditoria-documentacion.md) |

## 2026-11-12 · `main` — monedas arriba a la izquierda con icono

| Qué | Dónde | Ticket |
|---|---|---|
| `UILayer/coins` deja de ser un label de pantalla completa (en viewports grandes caía sobre el panel de stats) y pasa a rect fijo (26, 26)–(120, 42) con un `coin_icon` de 16×16 (primer frame de `MonedaD.png`) al lado | `scenes/game.tscn`, `scripts/player.gd`, `docs/ui.md` | [T-0055](tickets/T-0055-monedas-arriba-a-la-izquierda-con-icono.md) |

## 2026-11-12 · `main` — viaje rápido sobre el terreno

| Qué | Dónde | Ticket |
|---|---|---|
| KP4/KP6 aterrizan `teleport_above_ground_tiles` (4) por encima del suelo del destino en vez de 10 tiles sobre la posición actual, y refrescan los chunks en el mismo frame | `scripts/debug_tools.gd`, `scripts/world_generator.gd`, `README.md`, `docs/player.md` | [T-0054](tickets/T-0054-viaje-rapido-sobre-el-terreno.md) |

## 2026-11-12 · `main` — montaña en la barrera izquierda y debug de velocidad nuevo

| Qué | Dónde | Ticket |
|---|---|---|
| El borde izquierdo deja de ser un corte al vacío: 56 columnas pintadas como montaña, 2 escalones de 1 tile escalables andando y luego paredes de 4 filas (64 px, más que el salto) hasta `min_height`, con cresta plana; el tope del jugador pasa a la última columna pintada | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `docs/world.md` | [T-0052](tickets/T-0052-montana-en-la-barrera-izquierda.md) |
| Debug de velocidad: KP7 parte a la mitad, KP9 duplica sin tope y KP8 resetea a x1 (antes x1/x5/x20); `game_speed` pasa a `start_speed` y la etiqueta muestra el factor | `scripts/debug_tools.gd`, `README.md`, `docs/player.md` | [T-0053](tickets/T-0053-debug-velocidad-mitad-doble.md) |

## 2026-11-12 · `main` — fuera las elevaciones exageradas del bosque rojo

| Qué | Dónde | Ticket |
|---|---|---|
| Bosque rojo a 0.95/1.0 (como la pradera): su ×1.35 de amplitud y ×1.1 de frecuencia creaban montañas de 30–40 tiles con tramos de hasta 123 escalones; el peor relieve baja de 36 a 26 tiles y los tramos a 11–14 | `resources/world/biomes/bosque_rojo.tres`, `docs/world.md` | [T-0051](tickets/T-0051-elevaciones-exageradas-del-bosque-rojo.md) |
| Revertido el terreno con losas de T-0050 (suelos de 2 tiles demasiado frecuentes): vuelve el tope de ±1 de T-0049 | `scripts/world_generator.gd` | [T-0050](tickets/T-0050-terreno-redondeado-en-vez-de-escalera.md) |

## 2026-11-12 · `main` — terreno redondeado en vez de escalera

| Qué | Dónde | Ticket |
|---|---|---|
| Fuera el tope de ±1: `_shaped_step()` mantiene losas y pega paredes de 2 tiles (3 muy rara) para que las laderas no sean diagonales de un escalón por columna | `scripts/world_generator.gd`, `docs/world.md` | [T-0050](tickets/T-0050-terreno-redondeado-en-vez-de-escalera.md) |

## 2026-11-12 · `main` — tope de pendiente en el terreno

| Qué | Dónde | Ticket |
|---|---|---|
| `max_step_tiles` (1) acota cada columna a ±1 fila de la anterior, con cadena cacheada por chunk y costuras exactas; fuera `_terrain_at_tile()` | `scripts/world_generator.gd`, `docs/world.md` | [T-0049](tickets/T-0049-barreras-verticales-en-el-terreno.md) |

## 2026-11-10 · `main` — coords y seed en el debug, semilla al crear mundo

| Qué | Dónde | Ticket |
|---|---|---|
| El overlay de debug añade `pos`, `tile` y la seed de la partida; Nueva partida pide semilla (vacío = aleatoria) y se pasa al generador por `SaveGame.pending_seed` | `scripts/debug_tools.gd`, `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/save_game.gd`, `scripts/world_generator.gd` | [T-0048](tickets/T-0048-coords-seed-en-debug-y-semilla-al-crear-mundo.md) |

## 2026-11-10 · `main` — fondo del menú igual que el del spawn

| Qué | Dónde | Ticket |
|---|---|---|
| La `Camera2D` del menú pasa a la posición del spawn (808, 773): las capas de pinos dejan de separarse y el menú encaja con el juego | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd` | [T-0047](tickets/T-0047-fondo-del-menu-igual-al-spawn.md) |

## 2026-11-10 · `main` — pantalla completa sin bandas (viewport adaptativo)

| Qué | Dónde | Ticket |
|---|---|---|
| Fuera las bandas sin volver al factor fraccional: la escala es entera y el viewport crece a `ventana / factor` (más mundo visible); lista ampliada a 18 resoluciones | `scripts/ui/settings_panel.gd` | [T-0046](tickets/T-0046-pantalla-completa-sin-bandas.md) |

## 2026-11-10 · `main` — parallax sin tirones: escala entera también en fullscreen

| Qué | Dónde | Ticket |
|---|---|---|
| Fuera `STRETCH_FRACTIONAL`: la escala es siempre entera (fullscreen 1080p = 2× con bandas), lo que elimina el tirón de las montañas; la lista de resoluciones pasa a ser solo múltiplos exactos del viewport | `scripts/ui/settings_panel.gd` | [T-0045](tickets/T-0045-parallax-a-tirones-escala-fraccional.md) |

## 2026-11-10 · `main` — biomas por tramos y sangre por enemigo

| Qué | Dónde | Ticket |
|---|---|---|
| Biomas por tramos con duración mínima/máxima (sin microbiomas ni gigabiomas), desbloqueo por distancia y mundo generado solo hacia la derecha con tope en el borde izquierdo | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/biomes/nieve.tres` | [T-0044](tickets/T-0044-biomas-por-tramos-y-solo-derecha.md) |
| `blood_color` por enemigo en el estallido de muerte (por defecto, el rojo de siempre) | `scripts/enemies/enemy_base.gd`, `scripts/fx.gd` | [T-0043](tickets/T-0043-sangre-por-enemigo.md) |

## 2026-11-10 · `main` — pausa, ajustes compartidos y guardado

| Qué | Dónde | Ticket |
|---|---|---|
| Pausa con Esc (Reanudar / Ajustes / Guardar y salir), panel de ajustes reutilizado por menú y pausa, fullscreen y resoluciones no múltiplo a pantalla completa con `STRETCH_FRACTIONAL`, y guardado mínimo en `user://savegame.cfg` que Continúa donde se dejó | `scenes/ui/pause_menu.tscn`, `scenes/ui/settings_panel.tscn`, `scripts/ui/pause_menu.gd`, `scripts/ui/settings_panel.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scripts/player.gd`, `scenes/inventory/inventory.gd`, `scripts/collectables/player_passive.gd`, `scripts/world_generator.gd`, `scripts/world/fall_intro.gd` | [T-0042](tickets/T-0042-menu-de-pausa-y-guardado.md) |

## 2026-11-10 · `main` — menú principal con ajustes

| Qué | Dónde | Ticket |
|---|---|---|
| Menú con Nueva partida, Continuar (solo si hay `user://savegame.cfg`), Ajustes y Salir; panel de ajustes con modo de ventana y resoluciones múltiplo del viewport guardadas en `user://settings.cfg` | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `docs/ui.md` | [T-0041](tickets/T-0041-menu-principal-y-ajustes.md) |

## 2026-11-10 · `main` — banda de montaña con el color del bioma

| Qué | Dónde | Ticket |
|---|---|---|
| `MountainBase` pasa a teñirse con el `forest_color` del bioma oscurecido 0.35 (la pradera reproduce el `#283D43`), con la misma transición por bloque que pinos y roca | `scripts/world_generator.gd`, `docs/world.md`, `docs/ui.md` | [T-0040](tickets/T-0040-mountainbase-color-de-bioma.md) |

## 2026-11-10 · `main` — caída inicial más corta

| Qué | Dónde | Ticket |
|---|---|---|
| Caída de entrada de 520→260 px y 300→620 px/s (~0,7 s en total con los 6 tiles del generador); red de seguridad de 6→3 s | `scripts/world/fall_intro.gd`, `docs/player.md` | [T-0039](tickets/T-0039-caida-inicial-mas-corta.md) |

## 2026-11-10 · `main` — fuera skills, 3 consumibles

| Qué | Dónde | Ticket |
|---|---|---|
| Inventario de 3 consumibles con teclas 1-3; `Skills` eliminado y `docs/items.md` convertido en catálogo completo | `scenes/inventory/inventory.gd`, `inventory_ui.gd`, `inventory_screen.gd`, `inventory_screen.tscn`, `scripts/collectables/Skills.gd`, `project.godot`, `docs/items.md` | [T-0038](tickets/T-0038-quitar-skills-3-consumibles.md) |

## 2026-11-09 · `main` — loot por enemigo, sin presets

| Qué | Dónde | Ticket |
|---|---|---|
| `item_drops` por escena con `LootEntry`; una sola tirada de objetos que suma probabilidades y elige ponderado, y monedas en tirada aparte (varias posibles) | `scripts/enemies/enemy_base.gd`, `scripts/resources/loot_entry.gd`, `scenes/enemies/{orc,werewolf,mutant_toad,slime}.tscn` | [T-0037](tickets/T-0037-loot-por-enemigo-sin-presets.md) |

## 2026-11-09 · `main` — slimes en el bosque y menos lobos

| Qué | Dónde | Ticket |
|---|---|---|
| Bosque rojo: 2 slimes nuevos y lobos de 2 a 1 por chunk | `resources/world/biomes/bosque_rojo.tres` | [T-0036](tickets/T-0036-slime-y-lobo-en-bosque.md) |

## 2026-11-09 · `main` — lobo menos agresivo

| Qué | Dónde | Ticket |
|---|---|---|
| Embestida a 150 px/s, 40 % del diámetro de detección y 1,5 s parado en el destino antes de repetir | `scripts/enemies/werewolf.gd` | [T-0035](tickets/T-0035-lobo-menos-agresivo.md) |

## 2026-11-06 · `main` — inventario al doble

| Qué | Dónde | Ticket |
|---|---|---|
| Ventana 744×380, paneles 168/272/232, fuentes 16-20, huecos 40×40 y coleccionables 32×32 con el icono expandido; el HUD no cambia | `scenes/inventory/inventory_screen.tscn`, `scenes/inventory/inventory_screen.gd` | [T-0034](tickets/T-0034-inventario-al-doble.md) |

## 2026-11-06 · `main` — la sacudida respeta el encuadre de cámara

| Qué | Dónde | Ticket |
|---|---|---|
| La sacudida se suma al `offset` base de la `Camera2D` (60, −70) y lo restaura al terminar, en vez de dejarlo a cero y recentrar la vista para siempre | `scripts/fx.gd` | [T-0033](tickets/T-0033-sacudida-camara-offset-base.md) |

## 2026-11-05 · `main` — daño en el panel y ambiente más ancho

| Qué | Dónde | Ticket |
|---|---|---|
| Fila `Daño` en el panel de stats y panel bajado a (5, 82) para no pisar las monedas | `scripts/player.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |
| Emisión de hojas/copos al doble de ancho (extents X ×1,2) y al doble de cantidad (56 hojas, 440 copos) | `scripts/world/biome_particles.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |

## 2026-11-05 · `main` — parry retocado y estadísticas del jugador

| Qué | Dónde | Ticket |
|---|---|---|
| Parry de 0,2 s con enfriamiento de 0,3 s, aviso dorado al abrir la ventana y +30 stamina al acertar; la guardia ya no empuja | `scripts/player.gd`, `scripts/fx.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Estadísticas base: `attack_speed`, `crit_chance`, `crit_damage`, `luck` (la velocidad es `move_speed`); crítico con FX propio | `scripts/player.gd`, `scripts/fx.gd`, `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Panel `UILayer/StatsPanel` a la izquierda, siempre visible y alpha 0,6 | `scripts/player.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| La suerte suma `luck × 0,01` a todas las probabilidades de drop | `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |

## 2026-11-05 · `main` — polvo del bioma, parry y física de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| Polvo teñido con el `grass_color` del bioma (verde en pradera) | `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Ventana de parry de 0,18 s con chispas, `¡PARRY!`, destello y sacudida | `scripts/player.gd`, `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Monedas con gravedad, rebote y vaivén; nacen 40 px sobre el suelo | `scripts/collectables/coin.gd`, `scripts/world_generator.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Objetos con salto inicial al dropearse (`drop_hop` 150 px/s) | `item_pickup.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |

## 2026-11-05 · `main` — polvo a los pies, sangre grande y moco por la hitbox

| Qué | Dónde | Ticket |
|---|---|---|
| El polvo de saltar/aterrizar/correr nace a ras de suelo (`_feet_offset()`) | `scripts/player.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Muerte de enemigo con reventón de sangre en 4 capas y sacudida leve | `scripts/fx.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Moco emitido en caja por toda la hitbox, no desde el centro | `scripts/collectables/moco_emitter.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |

## 2026-11-05 · `main` — efectos de combate y feedback de HUD

| Qué | Dónde | Ticket |
|---|---|---|
| Nodo `fx`: chispas, estallidos, polvo, chispas de pickups, números de daño, sacudida y flash rojo | `scripts/fx.gd`, `scenes/game.tscn` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Enganches de VFX en jugador, enemigos, monedas y pickups | `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/collectables/coin.gd`, `item_pickup.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Pop del contador de monedas y latido de la barra de vida con poca vida | `scripts/player.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Fundido y viento en hojas/copos | `scripts/world/biome_particles.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |

## 2026-11-05 · `main` — nieve separada, bioma de nieve y ambiente

| Qué | Dónde | Ticket |
|---|---|---|
| Overlay del bosque corregido (ya no incluye piedra ni nieve) y nieve extraída a `mountain2_snow.png`, dibujada encima y sin teñir | `assets/map/background/mountain2_gray.png`, `mountain2_snow.png`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| `Biome.rock_color` para la piedra; bioma de nieve con sus colores y enemigos; pesos 0.55/0.3/0.2 | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Bosque rojo 1.35/1.1 y pradera 0.95 de amplitud | `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Hojas rojas y copos de nieve por bioma (`Biome.ambient`) | `scripts/world/biome_particles.gd`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |

## 2026-11-05 · `main` — un tono por capa de fondo

| Qué | Dónde | Ticket |
|---|---|---|
| Gris calibrado por capa (cercano 92, lejano 116, montaña 172/211) para que los tres fondos no queden del mismo color | `assets/map/background/{pine1,pine2,mountain2}_gray.png` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |
| El tinte de cada bioma conserva los tres escalones de profundidad en pradera y bosque rojo | `resources/world/biomes/*.tres`, `docs/world.md` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |

## 2026-11-05 · `main` — gris medio y verde original en la pradera

| Qué | Dónde | Ticket |
|---|---|---|
| Fondos de vegetación con gris medio (~113–129) en vez del gris claro (~165) | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |
| `Biome.forest_color` separa el tinte de los fondos del césped; la pradera recupera `(27,45,45)` y el bosque rojo usa un rojo saturado | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |

## 2026-11-05 · `main` — fondos tintables y terreno por bioma

| Qué | Dónde | Ticket |
|---|---|---|
| Pinos y bosque de la montaña en gris claro; solo los píxeles verdes/teal se convierten y la punta de la montaña queda sin teñir | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png`, `scenes/game.tscn` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |
| Bosque rojo con relieve más marcado: amplitud ×1.7 y frecuencia ×1.25, mezcladas en la transición de 256 bloques | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/bosque_rojo.tres` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |

## 2026-11-05 · `main` — biomas por bloque y más bosque rojo

| Qué | Dónde | Ticket |
|---|---|---|
| Bioma y césped decididos por bloque, con transición de 256 bloques (1 chunk) en vez de por chunks | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `scenes/world/chunk.tscn` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Bosques de fondo teñidos al cambiar de bloque | `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Más bosque rojo: pesos 0.6/0.4 y biomas de ~8 chunks (`biome_frequency` 0.12) | `resources/world/biomes/*.tres`, `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |

## 2026-11-05 · `main` — KP5 inmortal, pasivas sin stack y caducidad de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| KP5 alterna la inmortalidad del jugador y el aviso de debug lo muestra | `scripts/debug_tools.gd`, `scripts/player.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Las pasivas equipadas no vuelven a recogerse ni a dropearse (`has_passive`/`add_passive` + pool filtrado) | `scripts/collectables/player_passive.gd`, `scripts/collectables/passive_items.gd`, `scripts/enemies/enemy_base.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Pickups: borrado a los 60 s desde el spawn; parpadeo a los 25 s y desaparición a los 30 s desde que se ven; monedas excluidas | `item_pickup.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |

## 2026-11-03 · `main` — voladores fuera, reparto y banda plana

| Qué | Dónde | Ticket |
|---|---|---|
| Fantasma y demonio desactivados (`DISABLED_ENEMY_SCENES`) y recuento base a `[4, 2, 1, 2, 2, 2]` | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Enemigos repartidos en huecos iguales a lo ancho del chunk (±25 % de ruido) | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Banda plana `#283D43` bajo las montañas en menú y partida | `scenes/main_menu.tscn`, `scenes/game.tscn` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Docs de todo el trabajo acumulado y primer commit de la tanda | `docs/`, `vault/` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) / [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |

## 2026-11-03 · `main` (local, sin commit) — arranque, drops y dificultad

| Qué | Dónde | Ticket |
|---|---|---|
| Caída inicial arreglada: sin parqueo de cámara (saltaba ~270 px al enganchar) y de 2200 → 520 px (~1,7 s) | `scripts/world/fall_intro.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Drops bastante más raros: moneda al 45 %, objeto al 30 %, `Raro` 0.25 y 2 monedas por chunk (antes 8) | `scripts/enemies/enemy_base.gd`, `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Desactivados los 6 objetos originales (loot, debug y los dos pickups de prueba de `game.tscn`) | `scripts/enemies/enemy_base.gd`, `scenes/inventory/inventory.gd`, `scenes/game.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Balance: `maza` +2, `colmillo_lobo` +3, `pies_ligeros` 10 %, `piedra_oro` 10 % | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Enemigos algo más fuertes (vida ×1.35, daño ×1.25) y slime más pequeño (×1.2) | `scripts/enemies/enemy_base.gd`, `scenes/enemies/slime.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Más enemigos por chunk con escalada: 3 en los chunks 0–1 y hasta 16 más adelante | `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Fix: los 11 objetos del compañero apuntaban a `assets/icons/`, que no existe | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |

## 2026-11-03 · `main` (local, sin commit)

| Qué | Dónde | Ticket |
|---|---|---|
| Fixes de prueba: relleno bajo las montañas, sin negro de transición, caída lenta (~7 s), enemigos al doble, iconos a 16 px y enemigos más cerca del spawn | `scenes/main_menu.tscn`, `scripts/world/fall_intro.gd`, `scenes/enemies/*.tscn`, `resources/*.tres`, `scripts/world_generator.gd` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) / [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Todo lo del compañero (demonio, sapo, lobo, slime, esqueleto, arquero + 11 objetos) y loot por enemigo según su tabla | `scenes/enemies/*.tscn`, `scripts/enemies/*.gd`, `scripts/collectables/*`, `resources/*.tres`, `scripts/player.gd`, `scripts/world_generator.gd` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| 8 pasivas nuevas de rana y slime + sección `vault/pasivas/` con un `.md` por enemigo | `resources/*.tres`, `scripts/collectables/`, `vault/pasivas/` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Nombre del juego **OffBeaten Path** + menú principal (cielo, nubes y montañas) y caída desde el cielo al empezar, como pantalla de carga | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `project.godot`, `scenes/game.tscn` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) |
| Ciclo día/noche: día 5 min, noche 3 min; la noche solo cambia el color del cielo | `scripts/world/day_night.gd`, `scenes/game.tscn` | [T-0014](tickets/T-0014-ciclo-dia-noche.md) |
| Debug: velocidad x1/x2/x4 (KP7/8/9) y viaje rápido KP4/KP6 | `scripts/debug_tools.gd`, `scripts/player.gd`, `scenes/game.tscn` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Noche: estrellas, montañas más oscuras y velo negro del 10% | `scripts/world/day_night.gd` | [T-0016](tickets/T-0016-noche-estrellas-y-velo.md) |
| Debug: las velocidades x2/x4 pasan a x5/x20 | `scripts/debug_tools.gd` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Pasivas de ogro y lobo (9): recursos, efectos y calidad | `resources/*.tres`, `scripts/collectables/*Passive.gd`, `scripts/enemies/enemy_base.gd` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |
| Fix: `day_night.gd` no parseaba (dos líneas comidas) y `NightBonusPassive` no infería `night_now`; UID obsoleto en `ghost_projectile.tscn` | `scripts/world/day_night.gd`, `scripts/collectables/NightBonusPassive.gd`, `scenes/enemies/ghost_projectile.tscn` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |

## 2026-10-29 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `a914593` | Loot de enemigos: parentar antes de `global_position` (el offset del chunk se sumaba dos veces) | [T-0011](tickets/T-0011-fix-loot-drops.md) |
| `47647cb` | Cámara: seguimiento sobre `player.global_position` (el lag era permanente) | [T-0009](tickets/T-0009-fix-camara.md) |
| `0e92787` | `stretch/scale_mode="integer"`: fullscreen a 2× exactos | [T-0010](tickets/T-0010-fix-escala-entera.md) |
| `09d1679` | Saltos de 1 tile repartidos en 3 frames (máx. 6 px/frame) | [T-0009](tickets/T-0009-fix-camara.md) |
| `932d79b` | Cámara redondeada a píxel entero; 2 chunks extra cargados | T-0009 / T-0013 |
| `6f79135` | Escala 2× entera, subida de escalón sin frenar, primer chunk seguro | T-0009 / T-0010 |

## 2026-10-25 → 2026-10-27 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `30b45de` | Más holgura de spawn (el fantasma atacaba al aparecer); cámara en física | T-0009 |
| `b9204c9` | Subida de escalones sin tirones; montañas más suaves | T-0009 |
| `bea8591` | Costuras de chunk, chunks de 256 tiles y menos enemigos | T-0013 |
| `e201ecd` | BIG REFACTOR de escala de pantalla | T-0010 |
| `19d7363` | Mundo procedural con montañas, chunks dinámicos y persistencia | T-0013 |

## 2026-10-22 → 2026-10-23 · `main`

- Pasivas paginadas en HUD (10 filas) e inventario (6 filas): `37fd815`.
- Inventario movido a `scenes/inventory/`, `InventorySlot` reutilizable en HUD: `7dfdd41`, `dbff31f` (T-0012).

## 2026-10-14 → 2026-10-15 · `main`

- Sistema de objetos: inventario de 5 huecos, consumibles, pasivas y loot enemigo (`2530489`, `8e52811`, `4c7f595`, `58c4a0f`) (T-0012).
- Recogida automática al tocar y física de drops (T-0011).

## 2026-09-17 → 2026-10-13 · base

- Movimiento, suelo y tilemaps; parallax y assets (Jorge: `7dd0e62`, `317c66a`, `60f4808`).
- Enemigo base, fantasma con TP y proyectil; orcos 2.0 (Jorge: `9aac4dc`, `1dba7bd`).
- Monedas, stamina y barra de vida.

## Rama del compañero (NO integrada)


**`origin/feat/enemigos-demon-toad-werewolf`** · `685bc30` (2026-10-27, Jorge) · base `58c4a0f` (2026-10-15) · 1 commit sobre su base.

Aporta tres enemigos completos (escena + script + doc) y assets:

| Enemigo | Scripts | Escenas | Doc de la rama |
|---|---|---|---|
| Demonio volador | `demon.gd`, `demon_fire.gd` | `demon.tscn`, `demon_fire.tscn` | `docs/enemigo_demon.md` |
| Sapo mutante | `mutant_toad.gd`, `toad_projectile.gd` | `mutant_toad.tscn`, `toad_projectile.tscn` | `docs/enemigo_mutant_toad.md` |
| Lobo | `werewolf.gd` | `werewolf.tscn` (+ `werewolf.tscn` y `plantilla_enemy.tscn` en la raíz) | `docs/enemigo_werewolf.md` |

También toca `scripts/player.gd` (knockback/knockup/`is_guarding`) y `scripts/world_generator.gd` (zonas). Detalle y plan de integración: [T-0001](tickets/T-0001-integrar-enemigos-companero.md).
