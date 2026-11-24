# T-0088 · Fusión de ramas de estructuras y arte de la mazmorra

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0074, T-0075, T-0076, T-0079, T-0086, T-0087 |

## Problema

El trabajo de estructuras estaba repartido: `feat/estructuras-chunk` y
`feat/bloques-rompibles` (ruinas, patrones y cajas) no estaban en `main`, y
`feat/estructura-explorable` (mazmorra + puerta) salió de `main` sin ellos. Además, el
interior de la mazmorra usaba `ground_tile.png` tintado y no encajaba con el arte de ruinas.

## Plan

1. Crear `test/fusion-structure` desde `main` y fusionar con commits de merge
   `feat/bloques-rompibles` (incluye `feat/estructuras-chunk`) y `feat/estructura-explorable`.
2. Resolver `world_generator.gd` conservando estructuras, cajas y puertas; conservar las
   entradas de bitácora/changelog/estado de ambos lados.
3. Repintar la mazmorra con el atlas de ruinas: ladrillo oscuro en fondo/techo/muros y
   piedra clara en el suelo, con física de cuadro completo en suelo y muros.
4. Actualizar `docs/dungeon.md`, T-0079, changelog, bitácora y estado.

## Criterios de aceptación

- [x] `test/fusion-structure` contiene ruinas, cajas rompibles y mazmorra/puerta.
- [x] No quedan marcadores de conflicto; el generador reparte estructuras y entradas.
- [x] `dungeon.tscn` pinta con `ruin_tiles_dark.png`/`ruin_tiles.png` (sin `ground_tile.png`).
- [ ] F5 de Ruben: ruinas y cajas en el mundo, puerta con F, interior de ruinas y salida.
- [x] Docs y vault actualizados.

## Resultado

Hecho el 2026-11-24 (`buffy`) en `test/fusion-structure`.

- Merge `--no-ff` de `feat/bloques-rompibles` (`3484baf`) y
  `feat/estructura-explorable` (`419870e`); conflictos resueltos conservando ambos lados.
- La mazmorra usa el atlas 8x2 de ruinas: `Back` con ladrillos 6/7 (sin física y oscurecido),
  muros/techo con 6/7 (TileSet sólido en la capa 1) y suelo con piedras 8/11/3 y relleno
  oscuro debajo.
- **No hay Godot CLI en la sesión**: falta el F5/F6 de Ruben.
