# T-0044 · Biomas por tramos y mundo solo hacia la derecha

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0013, T-0027 |

## Problema

Con el bioma decidido bloque a bloque por ruido:

- **Microbiomas**: un bosque rojo podía quedar partido y aparecer una transición al
  nevado dentro de la propia transición del bosque.
- **Gigabiomas**: la pradera (peso 0.55 y umbral sobre el ruido) se comía a veces tramos
  enormes.
- **Orden**: no había forma de impedir que la nieve saliera en el minuto uno.
- **Izquierda**: el mundo se generaba a los dos lados aunque el juego solo avanza a la
  derecha, gastando la mitad del terreno en algo que nunca se ve.

## Causa / contexto

`_biome_index_at_tile()` convertía el ruido en un umbral acumulado: el peso no era una
probabilidad sino el ancho de un tramo. El tamaño del bioma era, por tanto, el que el ruido
quisiera, y la ventana de mezcla de 256 bloques (±128) podía solaparse consigo misma si el
bioma duraba menos que la ventana.

## Plan

1. Tramos (`_biome_runs`): lista `{start, index, length}` construida de izquierda a
   derecha y cacheada; `_biome_index_at_tile()` devuelve el tramo que contiene el bloque.
2. Duración acotada: longitud entre `min_biome_tiles` (1024) y `max_biome_tiles` (4096),
   redondeada a `biome_sector_tiles`. La ventana de mezcla queda por debajo del mínimo, así
   que dos transiciones nunca se pisan.
3. Orden: `Biome.min_distance_tiles` (nieve 4096) y `_roll_biome_at()` sin repetir el
   bioma anterior; `spawn_weight` solo sesga la elección.
4. Solo derecha: `_update_chunks()` acota a 0, `_height_at_with()` aplana los bloques
   negativos y `_keep_player_inside_world()` frena al jugador en el borde.
5. Documentar en `docs/world.md`.

## Criterios de aceptación

- [x] Un bioma dura siempre entre 4 y 16 chunks.
- [x] Dos transiciones no pueden solaparse.
- [x] La nieve no puede salir antes de 4096 bloques.
- [x] No se generan chunks con x < 0.
- [ ] F5: recorrer pradera → bosque → nieve sin ver un bioma diminuto ni una pradera eterna.
- [x] `docs/world.md` actualizado.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

`scripts/world_generator.gd`, `scripts/world/biome.gd` (`min_distance_tiles`) y
`resources/world/biomes/nieve.tres`. El ruido ya no decide tamaños, solo el orden, y el
mundo no reserva nada a la izquierda del inicio. F5 pendiente.
