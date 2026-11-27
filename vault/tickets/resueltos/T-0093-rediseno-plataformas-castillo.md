# T-0093 · Mazmorra del castillo: sala de referencia por capas

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0090, T-0091 |

## Problema

La primera pasada pintaba tiles 1×1 sobre una sala de 75 tiles: no usaba las piezas
compuestas del atlas y el resultado se leía como una tira de suelo con huecos raros.
Además, layout, atlas, pintado y ciclo de vida estaban concentrados en un solo script,
y el interior seguía viviendo bajo `scripts/world`.

La referencia pide **una sola sala**: marco de ladrillo, muro de piedra claro,
8 ventanas, 2 estandartes, tres grandes bloques de suelo con fosas y plataformas
de madera finas entre ellos.

## Plan

- Sustituir la cadena de salas por un hall de 34 × 22 tiles.
- Separar responsabilidades en `CastleLayout` (datos), `CastleTiles` (atlas y
  colisión), `CastlePainter` (pintado) y `DungeonGenerator` (ciclo de vida), bajo
  `scripts/structures/castle/`.
- Usar las piezas del atlas por grupos: ventanas/estandartes/plataformas arriba,
  bordes de ladrillo en medio y piedra de fondo abajo.
- Dar a las plataformas de madera colisión fina de un solo sentido; el suelo de
  los bloques y el marco siguen en la capa sólida.
- Mantener `start`, `spawn_point`, `exit_requested`, `save_state` y `load_state`.
- No tocar `WorldGenerator`, `WorldStructure` ni `BlockStructure`: la integración
  con el mundo sigue en `DungeonLayer`/`DungeonEntrance`.

## Criterios de aceptación

- [x] Una sola sala con tres bloques de suelo, dos fosas, 8 ventanas y 2 estandartes.
- [x] Plataformas de madera finas con colisión de un solo sentido y repisas de
  recuperación dentro de las fosas.
- [x] Muro y suelo comparten el mismo valor claro; el vacío solo se ve fuera del
  marco y en las fosas.
- [x] Esquinas de marco y suelo conectadas con las piezas del atlas; vacío exterior visible.
- [x] Layout, atlas, pintado y ciclo de vida en scripts separados.
- [x] `docs/dungeon.md` actualizado con la arquitectura y las trampas.
- [ ] F5/F6 de Ruben y cambio de estado al merge.

## Resultado

Rehecho el 2026-11-24:

- `CastleLayout` genera los tres bloques (filas 12–17), dos fosas de 3 tiles, tres
  plataformas de madera y las anclas de decoración; varía alturas/anchuras con la
  semilla.
- `CastleTiles` construye dos TileSets: `Walls` con colisión de cuadro completo y
  `Platforms` con colisión fina de 10 px para las losas de madera (`11/12/13/14`).
- `CastlePainter` pinta `Back` (piedra `41`, sin tile de vacío), `Decor`
  (ventanas 2×2 y estandartes 1×3), `Walls` (bloques con borde `20/24/19/22`
  y esquinas `18/21/26/23`; marco con borde `24/20/22/19`, esquinas interiores
  `28/29/27/30` y cuerpo `41`) y `Platforms`. El marco lleva el canto claro hacia
  dentro; solo los bloques de suelo lo llevan hacia fuera.
- El púrpura `#423a51` es el fondo original del atlas y se conserva: no hay
  shader ni transición inventada. `DungeonGenerator` añade un `Polygon2D` opaco
  `DungeonVoid` de ese mismo color en `z=-5`, encima del parallax y debajo de
  `Back`; las fosas borran sus celdas, así que el exterior no necesita el tile `25`.
- `DungeonGenerator` queda como orquestador; `Floor` pasa a llamarse `Platforms`
  para no confundir las losas de madera con el suelo sólido.

## Verificación

Chequeo del castillo, semilla `20261124`: marco `24/20/22/19` con esquinas
`28/29/27/30`, suelo `20/24/19/22` con esquinas `18/21/26/23`, tres bloques,
dos fosas, fosas/exterior de `Back` en `-1`, sin material en las capas y
`DungeonVoid` (`Polygon2D`, `z=-5`) usando el púrpura original; exit 0. Falta
F5/F6 de Ruben.

**Revisión 2026-11-25 (`opencode-jorge`)** con Godot 4.7.2 headless, semilla
`20261124`, plantas 0/1:

- 270 celdas de `Walls` todas con colisión completa, 25 de `Platforms` one-way,
  572 de `Back` y 38 de `Decor`; layout idéntico para el mismo `seed + floor` y
  distinto entre plantas 0 y 1; `spawn_point` en el bloque izquierdo y pinche de
  salida en el derecho.
- `game.tscn` y `dungeon_test.tscn` arrancan 180/90 frames sin errores.
- Corregido el comentario de `CastleTiles.build_plain()`, que seguía citando el
  shader de recorte ya eliminado.
- `dungeon_test.tscn` gana un nodo `UILayer`: sin él el jugador creaba el suyo
  mientras el padre montaba hijos y F6 soltaba errores de `add_child`.


## Ronda 5 · 2026-11-26 — hojas: tamaño, precarga y lluvia bajo los árboles

Pedido de Ruben: las hojas se ven demasiado grandes, al correr no hay hojas delante y
aparecen todas de golpe, y bajo los árboles deberían caer hojas de su color de forma
constante.

- 108 hojas (antes 80) a `LEAF_SCALE` 0,75; el litter usa la misma escala.
- Margen de generación y reciclado de ±260 px (`LEAF_SPAWN_MARGIN`), con
  `GROUND_MARGIN` 360 para que suelo y cuota de bioma se lean también fuera de la vista.
- `Leaf.drift` aleatorio por partícula (±`LEAF_DRIFT`): dirección y velocidad propias.
- Los árboles vivos (`tree`) entran en el grupo `decor_tree`; el 55 % de las hojas nacen
  bajo una copa visible, con textura derivada de `DecorProp.tint_color`.
- Sin Godot en esta sesión: F5 pendiente de tamaño, precarga y lluvia bajo copas.

## Ronda 6 · 2026-11-26 — vuelta al hall de tres bloques y hojas estables

Pedido de Ruben: los bloques escalonados tipo Minecraft hicieron más mal que bien;
volver al hall anterior, sin diagonales y con el borde solo en las caras de arriba.
Las hojas aparecían en masa al hacer TP y los árboles soltaban montones irregulares.

- `CastleLayout` vuelve a 34×22 con tres bloques (filas 12–17), dos fosas de 3 tiles,
  repisas de madera, 8 ventanas y 2 estandartes; fuera el suelo continuo, el BFS de
  alcanzabilidad y el ancho 64.
- `CastlePainter` pinta marco y bloques de forma explícita, sin autotiling de 8 vecinos:
  el ladrillo queda solo en la cara superior del bloque (`20/24/19/22` y esquinas
  `18/21`); laterales y fondo son piedra `41`. `DungeonGenerator.width_tiles` vuelve a 34.
- Hojas: cada una tira una X uniforme y **una sola** probabilidad contra la cuota de su
  tile; si falla queda oculta 5–9 s (un ciclo completo), así el 0..1 refleja la cantidad
  de partículas en vez de rellenarse con reintentos; tras un
  teletransporte se reparte toda la vista a alturas aleatorias (sin oleada desde
  arriba), la siembra inicial no usa copas y las copas se turnan para que ningún árbol
  suelte un montón.
- Sin Godot en esta sesión: F5 pendiente del hall, la lluvia bajo copas y el TP.

## Ronda 9 · 2026-11-26 — rollback descartado

El working tree había vuelto a la sala de 34×22 de la ronda 6, pero Ruben reportó que el
castillo se veía fatal. Se restauró el layout de **64×22** de HEAD (T-0095) con suelo
escalonado continuo, BFS y autotiling. La ronda 6 deja de ser el estado actual; el hall
válido es el de T-0095.
