# T-0023 · Transición de biomas por bloque y más bosque rojo

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `feat` + `balance` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0013 (chunks), T-0020 (dificultad) |

## Petición

1. La transición de biomas no va por chunks, sino por bloques (tiles).
2. La transición debe durar tantos bloques como los que tiene un chunk.
3. Hay muy poco bosque rojo y demasiado bosque normal.
4. Explicar qué determina un bioma.

## Causa / contexto

- El bioma se elegía por chunk (`_biome_for_chunk(chunk_x)`) y solo el color se
  promediaba entre chunks vecinos (`biome_transition_chunks = 1`): el resultado eran
  2–3 chunks de tonos intermedios, con la costura visible en el borde del chunk.
- Poco bosque rojo: `bosque_rojo` pesaba 0.25 y, como los pesos son umbrales sobre el
  ruido (`clamp(noise × 2 + 0.5)`), el rojo solo entraba con ruido > 0.125. Además,
  `biome_frequency` 0.04 sobre índice de chunk hacía biomas de ~25 chunks: si el primer
  tramo caía en pradera, no aparecía rojo en toda la partida. El promedio de color de 3
  chunks diluía aún más los tramos rojos cortos.

## Plan

1. `_biome_index_at_tile()`: repartir el ruido por bloque; frecuencia exportada en
   unidades de chunk dividida por `chunk_width_tiles`.
2. `_biome_for_chunk()`: enemigos por chunk con el bioma del bloque central.
3. `biome_transition_tiles` (0 = un chunk): media móvil de la ventana para el color.
4. `_grass_tints_for_chunk()`: 257 colores por chunk con ventana deslizante y
   `GrassPaint` en `WorldChunk` para dibujar el césped teñido por bloque.
5. Bosques de fondo y césped: tinte recalculado al cambiar de bloque.
6. Subir el peso del bosque rojo a 0.4 y acortar los biomas (`biome_frequency` 0.12).

## Criterios de aceptación

- [x] El color del césped cambia bloque a bloque, con un degradado de ~256 bloques.
- [x] El bioma no cambia de golpe en el borde del chunk.
- [x] El bosque rojo aparece con más frecuencia y sin quedar deslavado.
- [x] `docs/world.md` explica qué determina el bioma.
- [ ] F5 en editor: color, costuras y frecuencia de bosque rojo.

## Resultado

- `scripts/world_generator.gd`: bioma por bloque, ventana de transición deslizante,
  bosques teñidos por bloque, `biome_frequency` 0.12, `biome_transition_tiles` 0/256.
- `scripts/world/chunk.gd` + `scenes/world/chunk.tscn`: fuera el `TileMapLayer` de
  césped; `GrassPaint` dibuja cada columna con su color (el `TileMapLayer` no permite
  teñir por celda).
- `resources/world/biomes/*.tres`: pesos 0.6 / 0.4.
- `docs/world.md` actualizado (biomas, césped y bosques).

Verificado por inspección; no se ha ejecutado Godot (regla de `AGENTS.md`).
