# T-0091 · Arreglar el tilemap del interior del castillo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0090, T-0088 |

## Problema

T-0090 cambió el arte del interior explorable al atlas del castillo de `map.zip`
(`assets/map/structures/castle_tiles.png`, 32 px), pero el tilemap resultante es una
composición improvisada: hay que revisarlo en el editor y arreglarlo. Puntos conocidos
(no verificados visualmente: falta el F5/F6 de Ruben):

- El `Back` es un relleno plano de losas: no usa las filas de borde del propio pack
  (`Walls_4` / `Background_walls_5`), así que la sala lee como una textura y no como un
  interior cerrado.
- El cuerpo del muro repite un pool pequeño (20 arriba, 25/26/30 de cuerpo) y deja sin usar
  los remates y vigas del atlas (18/19/21/22/23, 27/28).
- La última sala se lleva el resto del ancho y puede salir de **20 tiles** (medido en el
  bench), rompiendo el ritmo de 4–11.
- Ventanas (2×2) y estandartes (1×3) se colocan con una tirada por sala y `_decor_free()`,
  pero pueden quedar a alturas raras, pegados a la salida o repetidos.
- Sin usar los tiles de plataforma/viga del pack (fila 1: 3–6; fila 2: 0–2), que darían
  profundidad a las salas.
- Falta comprobar que el margen del `Back` cubre la cámara en todos los zooms/ajustes.
- La salida sigue siendo el polígono ámbar; se podría integrar la puerta del atlas
  (0,1 / 1,1) sin perder el `Area2D`.

## Causa

T-0090 se centró en cambiar el atlas y la escala (32 px), no en componer la sala con las
piezas del pack. El generador elige tiles por hash, así que los remates no dependen de la
posición.

## Plan

1. F6 de `scenes/structures/dungeon_test.tscn` (seed 20261124, pisos 0 y 1) y captura de
   los puntos raros.
2. Limitar la última sala a `room_width_max` (o repartir el resto) para recuperar el ritmo.
3. Usar el atlas por posición: remates de fila superior/inferior y bordes laterales en el
   `Back`, tapas de muro en las columnas y vigas de plataforma como decor sin colisión.
4. Colocar ventanas y estandartes sobre la retícula del pack (pares 2×2 y columnas 1×3),
   lejos de la puerta de salida y sin solaparse.
5. Revisar que el relleno del fondo cubra la vista con el zoom máximo y el spawn.
6. F5 entrando desde la puerta del mundo y saliendo con el pad.

## Criterios de aceptación

- [x] El interior se lee como el castillo del pack: sin tiles sueltos ni remates fuera de
      sitio, sin decor flotando ni ventanas cortadas.
- [ ] Las salas mantienen el ancho previsto y la puerta deja pasar al jugador.
- [ ] Muros y suelo conservan la colisión de cuadro completo (`Walls`/`Floor`), y
      `Back`/`Decor` siguen sin física.
- [x] `docs/dungeon.md` actualizado con los pools/reglas definitivos.
- [ ] F5/F6 de Ruben y entrada en `changelog.md`/`estado.md` al cerrar.

## Resultado

Corregido el 2026-11-24 en `scripts/world/dungeon_generator.gd`:

- `Back` usa solo la losa completa `41`; los muros y el techo usan cuerpo `41` y
  remate `31`. Las celdas de ladrillo naranja no son continuas: `20/25/26/30`
  arrastran el interior morado y abren huecos, así que quedan fuera del cuerpo.
- `_build_rooms()` reparte todas las salas en 4–11 tiles y corrige el total; la
  última ya no se lleva el resto (20 medido).
- Las ventanas 2×2 dejan un tile antes de la partición siguiente; ventanas y
  estandartes no se colocan sobre el pad de salida.

Verificado con un harness de renderizado propio (`game.tscn`, semilla
`20261124`, KP3 → F, plantas 0 y 1): sin huecos morados, suelo continuo y salas
4–11. Capturas en `vault/estructuras/castle_after_*.png`. Falta el F5/F6 de
Ruben; si el problema real es el patrón de las ruinas del mundo
(`scripts/world/block_structure.gd`), abrir un ticket aparte.

> Rediseño posterior: T-0093 sustituye esta sala plana por una sala de referencia
> con plataformas. La composición y el remate del suelo ya no son los de este ticket;
> el generador vive ahora en `scripts/structures/castle/dungeon_generator.gd` y el
> historial del tilemap se conserva arriba.
