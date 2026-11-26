# T-0090 · Interior del castillo con el tileset de `map.zip`

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0079, T-0088 |

## Problema

El interior explorable seguía pintado con el atlas de ruinas; Ruben entrega `map.zip`
con un tileset de castillo (atlas 8×6 de 32 px, más capas de muros, fondo, ventanas,
estandartes y plataformas) y pide cambiar toda la estructura del castillo por ese arte.

## Plan

1. Copiar `tileset.png` como `assets/map/structures/castle_tiles.png` (el `.tres` del
   pack no tiene colisión; el TileSet se sigue construyendo en código).
2. Rehacer `DungeonGenerator` con celdas de 32 px: losas de piedra en `Back`, ladrillo
   naranja en muros/techo y piedra en el suelo, con la física de cuadro completo.
3. Añadir la capa `Decor` (sin colisión) con ventanas 2×2 y estandartes 1×3 repartidos
   por las salas.
4. Ajustar medidas (75 tiles de ancho, interior 6, puerta 4) y la salida de 32×64 px.
5. Actualizar `docs/dungeon.md` y el vault.

## Criterios de aceptación

- [x] El interior usa el atlas del pack (ni `ruin_tiles*.png` ni `ground_tile.png`).
- [x] Muros, techo y suelo tienen colisión; `Back`/`Decor` no.
- [x] La puerta deja pasar al jugador (4 tiles = 128 px) y no se puede saltar el muro.
- [x] `docs/dungeon.md` actualizado.
- [x] Entrada en `changelog.md`, `bitacora.md` y `estado.md`.

## Resultado

Hecho el 2026-11-24 (`buffy`) en `test/fusion-structure`.

- `assets/map/structures/castle_tiles.png` (atlas 8×6 de 32 px) + `scripts/world/dungeon_generator.gd`:
  `TILE_SIZE` 32, `Back` con losas de piedra (31/32-35/40-43) oscurecido, `Walls` y techo
  con ladrillo (20 arriba, 25/26/30 cuerpo), `Floor` con piedra (32-37) y relleno (40-43),
  y `Decor` con ventanas (0..7 de la fila 0) y estandartes (8..10).
- `scenes/structures/dungeon.tscn`: nodo `Decor` (z −3, `Walls` −2, `Floor` −1) y pad de
  salida de 32×64 px.
- Comprobado en headless (`_dungeon_bench.gd`, borrado después): 2 plantas, 0 tiles de
  muro/suelo sin colisión, 42 celdas de decor, 9 ms por las dos plantas.
- Falta el F5/F6 de Ruben para validar el aspecto; la sesión no tiene pantalla.
