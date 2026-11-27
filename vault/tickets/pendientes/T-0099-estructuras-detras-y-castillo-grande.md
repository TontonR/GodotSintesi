# T-0099 · Estructuras de sprite detrás del jugador y castillo más grande

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0074 |

## Problema

Las estructuras de sprite (tienda `tent_test.tres` y puerta del castillo `tower_test.tres`)
se pintan **delante del jugador**: `game.tscn` coloca el nodo `player` (línea 271) antes
que `map` (línea 276), así que a `z_index` 0 el orden del árbol decide y todo lo que vive
dentro del chunk sale por encima. Las ruinas ya se libraban porque su `ruin_test.tres` fija
`z_index = -1`.

Además la tienda se veía poco asentada (3 px de hundido) y la puerta del castillo, que es
un `scene` (`dungeon_entrance.tscn`), nunca se escalaba: se quedaba en los 64 px nativos
(4 tiles) porque el factor de `size_tiles`/`pixel_size` solo se aplicaba a los sprites.

## Causa / contexto

`WorldGenerator._spawn_chunk_entities()` crea la estructura, la mete en el chunk y la mueve
al índice 0, lo que la deja detrás de `Solid` **dentro** del chunk, pero no frente al
jugador: son hermanos distintos y a igual `z_index` manda el orden del árbol. La única vía
robusta es un `z_index` negativo.

Para la escala, el sprite calculaba `size_tiles * 16 / pixel_size` en su rama, y la rama de
`scene` instanciaba el nodo tal cual. `dungeon_entrance.tscn` mantiene el `Visual` con su
base en y = 0, así que escalar el nodo raíz conserva el anclaje en el suelo.

## Plan

1. `WorldStructure.z_index` por defecto a `-1` (`scripts/world/structure.gd`).
2. Escalar los `scene` con `pixel_size`/`size_tiles` en `_spawn_chunk_entities()`.
3. Tienda: `y_offset_px` 3 → 6.
4. Castillo: `pixel_size = 64`, `size_tiles = 8` (×2 → 128 px), `y_offset_px = 2` y
   `flatten_ground = true` para que 8 tiles de ancho no floten en una pendiente.

## Criterios de aceptación

- [ ] En F5, el jugador pasa **por delante** de la tienda y de la puerta del castillo.
- [ ] La base de la tienda queda tapada por la hierba (hundida, no flotando).
- [ ] La puerta del castillo mide 8 tiles de ancho y su base sigue apoyada en el suelo.
- [x] `docs/world.md` y `docs/dungeon.md` actualizados.
- [x] Entrada en `changelog.md`, `estado.md` y `roadmap.md` al abrir el ticket.

## Resultado

Hecho el 2026-11-27 por `buffy`. `z_index` por defecto `-1` en `WorldStructure`; escalado
de los `scene` con `size_tiles`/`pixel_size`; tienda hundida 6 px; castillo a 8 tiles
(128 px) con `flatten_ground` y 2 px de hundido. **F5 pendiente**: ni el orden de dibujo ni
la escala se han visto en el editor.
