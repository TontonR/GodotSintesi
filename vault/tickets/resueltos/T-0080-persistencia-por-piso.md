# T-0080 · Persistencia por piso: guardar y cargar dentro de la mazmorra

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | world / save |
| Creado | 2026-11-25 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0079, T-0087, T-0093, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

Guardar dentro de la mazmorra escribe la posición del jugador en coordenadas de la
mazmorra como si fueran del mundo (`scripts/save_game.gd:126-131`). Al cargar, el jugador
aparece en esas coordenadas del mundo (junto al origen), los metros salen mal y la
mazmorra no existe: se pierde la partida en la práctica. Además, al volver a entrar por
una puerta siempre se empieza en la planta 0, aunque `DungeonGenerator.save_state()`
(`{seed, floor}`) ya exista y nadie lo llame.

## Causa / contexto

`DungeonLayer` descarga el mundo y teletransporta al jugador a la mazmorra sin dejar
rastro fuera. El guardado no pregunta si el jugador está dentro: `save_run()` solo ve
`world` y `player`. La solución no necesita fichero propio de mazmorra: la partida ya
tiene un `seed` global y el castillo se reconstruye desde `seed + floor`.

## Plan

1. `DungeonLayer.save_state()`: `{}` fuera; dentro, `{seed, floor, position, world_position}`
   (posición del jugador en la mazmorra y punto del mundo al que se vuelve).
2. `scripts/save_game.gd`: con el jugador dentro, `run/position` y `run/meters` usan
   `world_position` y se añade `[dungeon] state` con el diccionario. Sin subir `VERSION`:
   una partida vieja lee `{}`.
3. `request_load()`: lee `[dungeon] state` en `SaveGame.data["dungeon"]`.
4. `scripts/game.gd`: tras recolocar al jugador y refrescar chunks, si hay estado de
   mazmorra llama a `DungeonLayer.restore_from_save(state)`, que descarga el mundo, genera
   la planta guardada y teletransporta al jugador a su posición dentro.
5. `docs/dungeon.md` actualizado (y recortado a ~30 líneas).

## Criterios de aceptación

- [x] Guardar dentro de la mazmorra y continuar devuelve al jugador a la misma planta y
      posición, con vida, monedas, inventario y pasivas.
- [x] Al pisar el pad de salida se vuelve al punto del mundo donde estaba la puerta.
- [x] `run/position` y los metros guardados son del mundo, no de la mazmorra.
- [x] Entrar por una puerta (sin cargar partida) sigue empezando en la planta 0.
- [x] Una partida vieja sin sección `dungeon` carga como antes.
- [ ] F5 de Ruben: guardar dentro del castillo, continuar y salir por el pad.
- [x] `docs/dungeon.md` actualizado, más `changelog.md` y `estado.md` al cerrar.

## Resultado

Hecho el 2026-11-25 (`opencode-jorge`); queda F5 de Ruben.

- `DungeonLayer.save_state()`: `{}` en el mundo o `{seed, floor, position,
  world_position}` dentro del castillo. `restore_from_save(state)` descarga el mundo,
  genera la planta guardada y teletransporta al jugador a su posición; `enter()` y la
  carga comparten `_open_dungeon()`, así que un fallo deja el mundo utilizable.
- `scripts/save_game.gd`: con el jugador dentro, `run/position` y `run/meters` se
  escriben con `world_position` (metros reales del mundo) y se añade `[dungeon] state`.
  `request_load()` lo lee en `SaveGame.data["dungeon"]`. `VERSION` sigue en 1: una
  partida vieja no tiene la sección y lee `{}`.
- `scripts/game.gd`: tras recolocar al jugador y `refresh_chunks()`, si hay estado de
  mazmorra llama a `DungeonLayer.restore_from_save()`.
- Reglas: entrar por una puerta siempre empieza en la planta 0; solo cargar una partida
  devuelve a la planta guardada. El castillo no tiene aún estado propio por planta
  (cajas/enemigos), así que no hay nada más que persistir.
- `docs/dungeon.md` con el apartado de guardado y recortado.

Comprobado en headless con Godot 4.7.2 (`_probe_save.gd` desechable, slot 3, borrado al
acabar): guardar fuera no escribe sección `dungeon`; dentro, `run/position` = punto del
mundo de la puerta y metros del mundo; al continuar se recuperan semilla `12345` y planta
1, el jugador cae en el `spawn_point` guardado y los chunks del mundo siguen descargados;
al pisar la salida vuelve a `(808, 539)` con la puerta en `(808, 518)` y la mazmorra se
libera. `game.tscn` y `dungeon_test.tscn`, 180/90 frames sin errores.

