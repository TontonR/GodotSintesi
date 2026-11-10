# T-0042 · Menú de pausa, ajustes compartidos y guardado

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui / repo |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0041 |

## Problema

- Con **Esc** no había pausa: hacía falta un menú in-game con **Volver al juego**,
  **Ajustes** y **Guardar y salir**.
- La pantalla completa no rellenaba la pantalla y faltaban resoluciones normales
  (1920×1080 entre ellas).
- `Continuar` no tenía nada que cargar porque no existe guardado.

## Causa / contexto

`window/stretch/scale_mode="integer"` con el viewport 768×432 deja bandas negras en
cualquier tamaño que no sea múltiplo exacto. En pantalla completa (1920×1080 = 2,5×) eso
se veía como un marco negro. La solución no toca el viewport: se cambia solo
`Window.content_scale_stretch` a `fractional` cuando el tamaño no es múltiplo o cuando se
juega a pantalla completa, y se mantiene `integer` en los múltiplos exactos. Ruben pidió
explícitamente no cambiar las dimensiones del juego.

## Plan

1. `scenes/ui/settings_panel.tscn` + `SettingsPanel`: panel reutilizable (modo de ventana y
   resolución), lista de resoluciones 16:9 + múltiplos exactos y `content_scale_stretch`
   según el caso.
2. `scenes/ui/pause_menu.tscn` + `PauseMenu`: Esc pausa, Reanudar / Ajustes / Guardar y salir.
3. `scripts/save_game.gd` (`SaveGame`, estático) + `scripts/game.gd`: guardado mínimo de la
   partida (semilla, posición, vida/stamina/monedas, inventario, pasivas y spawns ya
   consumidos) y su restauración sin caída inicial.
4. `Inventory.restore_from_save()`, `PlayerPassives.restore_from_save()`,
   `Player.restore_run_state()`, `WorldGenerator.current_seed()`/`save_persistent_state()`.
5. `docs/ui.md` y `docs/world.md`.

## Criterios de aceptación

- [ ] Esc abre y cierra la pausa sin pisar el inventario (que también usa Esc).
- [ ] Ajustes funciona igual desde el menú y desde la pausa.
- [ ] 1920×1080 y el resto de resoluciones están disponibles y rellenan la ventana.
- [ ] Pantalla completa usa la resolución del monitor y rellena.
- [ ] Guardar y salir deja una partida que Continúa con semilla, posición, stats,
      inventario, pasivas y bajas/objetos ya recogidos.
- [x] `docs/ui.md` y `docs/world.md` actualizados.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

Pausa con Esc y ajustes compartidos; fullscreen y resoluciones no múltiplo con
`STRETCH_FRACTIONAL` (múltiplos exactos siguen `STRETCH_INTEGER`); guardado mínimo en
`user://savegame.cfg` y restauración en `scripts/game.gd`. No se guardan el estado interno
de las pasivas, la hora del ciclo día/noche ni los enemigos vivos no matados. F5 pendiente.
