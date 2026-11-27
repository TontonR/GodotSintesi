# T-0075 · Estructuras por bloques (tipo 2): ruinas con muro oscuro y bloques sólidos

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | world |
| Creado | 2026-11-19 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0074, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

T-0074 solo sabe colocar una textura o una escena. El tipo 2 del planning (ruinas,
muros, estructuras por bloques) necesita que el recurso describa una rejilla de bloques y
que el generador la pinte en el chunk: detrás del decor, sin colisión y siguiendo el
terreno. El arte no existe todavía, así que el bloque es un cuadrado gris de prueba.

## Plan

1. `WorldStructure`: `pattern` (una cadena por fila de arriba a abajo, `#` = bloque),
   `block_width()`.
2. `scripts/world/block_structure.gd` (`BlockStructure`, `Node2D`): pinta cada celda de
   16 px con `_draw()`, relleno + contorno 1 px más oscuro. Sin colisión.
3. `WorldGenerator`: aceptar `pattern` en `_structure_allowed`, usar `block_width()` para
   el hueco (mitad, separación) y `_blocks_structure()` para construir las celdas: cada
   columna apoya en su propia fila de suelo, así la ruina sigue el terreno.
4. `ruin_test.tres` pasa a patrón 8×5 (deja de usar su PNG placeholder).
5. `docs/world.md` § Structures.

## Criterios de aceptación

- [x] Hay una estructura por bloques en un `.tres` y sale en juego (pradera 25 %, bosque
      rojo 30 %).
- [x] El muro oscuro va detrás del decor y de `Solid`/`GrassPaint`, sin parallax.
- [x] La versión clara es la sólida (capa 1) y la oscura el fondo; todos los bloques
      sólidos están en la fila de suelo (piedras sueltas saltables y vigas en los huecos).
- [x] Arte propio: `ruin_tiles.png` (claro) y `ruin_tiles_dark.png` (oscuro, mismo layout),
      con variedad de tono y remates de musgo.
- [x] Cada columna apoya en su suelo: ni flota ni se entierra.
- [x] Una estructura por bloques respeta márgenes, separación y la X de los enemigos.
- [x] `docs/world.md` actualizado.

## Resultado

Hecho el 2026-11-19 (`opencode-jorge`); falta F5.

- `scripts/world/structure.gd`: `pattern`, `block_width()`, `min_length_tiles`/`max_length_tiles`,
  `tileset` y `front_chance`/`support_chance`.
- `scripts/world/block_structure.gd`: pinta cada celda desde un atlas de 16 px (índice por
  hash de la celda y pool de arriba con musgo) y, si `solid`, añade un `StaticBody2D` en la
  capa 1 con una caja por tramo horizontal.
- `scripts/world_generator.gd`: `_blocks_cells()` repite el patrón hasta la longitud tirada
  (20–50 columnas) y coloca cada fila sobre `heights[tile_x] - (rows - row)`. Devuelve
  `cells` (muro de ladrillos de fondo) y `front`/`front_tiles` (sólidos **solo en la fila
  de suelo**: piedras con `front_chance` 0.25 y vigas de soporte en los huecos bajo el
  muro con `support_chance` 0.6). El muro va en `ZERO` y detrás; los sólidos son un nodo
  aparte en `z_index` 0, delante del muro y detrás del decor grande.
- `assets/map/structures/ruin_tiles.png` y `ruin_tiles_dark.png`: 8×2 tiles de 16 px, mismo
  layout: ladrillo teal oscuro (6 claro / 7 apagado, 14–15 con musgo) y piedra pizarra
  chunky en grande/largo/pequeño × claro/oscuro, con musgo. El fondo es **solo ladrillo**; los bloques de piedra (8-13) quedan únicamente en
  la capa de delante, con colisión. Generador:
  `vault/estructuras/make_tiles.py`.
- `resources/world/structures/ruin_test.tres`: patrón `##   ### / ###  ## / ##### # /
  ##### ## / ###### #`, longitudes 20–50, `z_index` −1, `front_chance` 0.12.
- Decoración: el decor que cae dentro del ancho de una estructura (`x ± half`) se
  descarta, así no salen arbustos dentro de la ruina.
- Musgo por bioma: cada estructura recibe el `tint` de `_decor_tint_at()` (los
  `decor_colors` del bioma) y sus atlas se recolorean con `_tinted_texture(..., 24, 12)`:
  solo cambian los píxeles claramente verdes, así la junta teal del ladrillo no se tiñe.
- Pendiente de F5: ver la ruina en pradera y bosque rojo, comprobar relieve y que el muro
  oscuro no se lee como un agujero; subirse a los bloques claros y comprobar que se puede
  saltar (un bloque sólido mal puesto puede tapar el paso). Los PNG los importa Godot al
  abrir el editor: si el `.tres` no carga, revisar `assets/map/structures/*.import`.
