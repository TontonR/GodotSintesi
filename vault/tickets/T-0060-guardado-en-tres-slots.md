# T-0060 · Guardado en tres slots de run

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0042, T-0059 |

## Problema

El guardado era un único `user://savegame.cfg`: solo cabía una run y el menú
tenía un botón **Continue** que aparecía o desaparecía. Ruben quiere hasta tres
runs guardadas en slots, con posibilidad de sobrescribirlas.

## Plan

1. `SaveGame`: `SLOT_COUNT` 3, `slot_path(n)` (`user://run_slot_N.cfg`),
   `current_slot`, `slot_exists()`, `slot_summary()` para el menú,
   `start_new_run()`, `delete_slot()` y `save_run()` sobre el slot actual.
2. Menú principal: fuera **New Game / Continue**; tres filas de slot con
   `Play` (continuar si está ocupado, run nueva si está vacío) y `Erase` para
   liberar un slot ocupado y poder reutilizarlo.
3. El diálogo de semilla pasa a abrirse desde el slot elegido
   (`New world — slot N`); `start_new_run()` borra el guardado anterior antes
   de generar el mundo.
4. Pausa: "Guardar y salir" escribe en `current_slot`; si no hay slot (run
   lanzada desde el editor) cae al primer slot libre.
5. Documentar en `docs/ui.md` y `docs/player.md`.
6. Revisión de UX (Ruben): volver al menú New Game/Continue + Load.
   Continue = `latest_slot()` (la run cerrada más reciente) y Load abre un
   diálogo con los tres slots; New Game usa el primer hueco o, si están los
   tres llenos, el más antiguo (sustituido después por el aviso de
   sobrescritura).
7. Revisión (13-11): si los tres slots están llenos, New Game ya no borra el
   más antiguo en silencio; Start abre `LoadDialog` en modo sobrescritura y el
   jugador elige qué run reemplaza. Las filas de Load muestran metros y monedas
   en vez de la semilla.

## Criterios de aceptación

- [x] Tres slots independientes y persistidos en `user://`.
- [x] Un slot ocupado continúa su run; `Erase` lo libera y se puede reutilizar
      (sobrescribir = borrar + empezar de nuevo).
- [x] Al empezar en un slot ocupado, el guardado viejo desaparece en el acto.
- [x] "Guardar y salir" escribe en el slot de la run en curso.
- [x] Una run muerta no deja slot continuable (ver T-0059).
- [x] Continue carga la run cerrada más recientemente y New Game no pregunta
      slot (primer hueco o el más antiguo).
- [x] Load lista los tres slots con seed/monedas y permite borrarlos.
- [x] Sin hueco libre, New Game avisa y pide qué run sobrescribir.
- [x] Load muestra metros y monedas de cada run (sin semilla).
- [ ] F5: crear tres runs, borrar una, sobrescribir, Continue y cargar cada slot.

## Resultado

- `scripts/save_game.gd`: API por slots (`SLOT_COUNT`, `slot_path`,
  `slot_exists`, `first_free_slot`, `slot_summary`, `start_new_run`,
  `delete_slot`, `current_slot` en `request_load`/`save_run`) y rechazo de
  guardados con salud 0. Desaparecen `SAVE_PATH` y `has_save()`.
- `scenes/main_menu.tscn`: `Menu/Layout/Slots/Slot1…3`, cada uno con `Play`
  (300×40) y `Erase` (90×40); fuera `NewGame` y `Continue`.
- `scripts/ui/main_menu.gd`: refresco de filas (`Slot N — seed S · C coins` /
  `Slot N — Empty`), continuar, borrar, run nueva con semilla y foco inicial en
  el primer slot.
- `scripts/ui/pause_menu.gd` y `scripts/game.gd`: guardado en el slot actual.
- Revisión de UX: `scenes/main_menu.tscn` recupera NewGame/Continue, añade
  `Load` y mueve las tres filas (Play/Erase) a `Menu/LoadDialog` con `Back` y
  Esc; `main_menu.gd` reescribe el flujo y `SaveGame.latest_slot()` /
  `slot_for_new_run()` resuelven Continue y el destino de New Game por mtime.
- Revisión de UX 2: `has_free_slot()`/`first_free_slot()` (-1 si no queda
  hueco) sustituyen a `slot_for_new_run()`; `_confirm_new_game()` arranca en el
  primer hueco o abre `LoadDialog` en modo sobrescritura (todo habilitado,
  `Erase` oculto, `Back` vuelve al diálogo de semilla). `slot_summary()`
  devuelve `meters` y las filas de Load muestran `M m · C coins`.
- Comprobado por inspección y con Godot headless (parse `--check-only` y carga
  de `game.tscn`); F5 pendiente.
