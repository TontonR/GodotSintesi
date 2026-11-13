# T-0059 · Pantalla de muerte y fin de la run

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0060 |

## Problema

Al morir no pasaba nada: `player.gd::_die()` solo bloqueaba al jugador y
reproducía `death`. La partida seguía viva (se podía guardar y salir, y al
continuar se revivía), y no había ninguna pantalla que dijera que la run había
terminado.

## Plan

1. `Player.died` (señal) y `Player.is_dead()`; `_die()` la emite.
2. `Game._on_player_died()`: borra el slot de la run al instante (para que un
   Esc + "Guardar y salir" durante la animación no recargue un estado anterior),
   espera `DEATH_DELAY` (1.4 s) y muestra la pantalla.
3. `scenes/ui/death_screen.tscn` + `scripts/ui/death_screen.gd`: `You died`,
   `The run is over.`, seed y monedas, botones **Main menu** y **Quit**; pausa
   el árbol y `_exit_tree` lo despausa.
4. `SaveGame.save_run()` rechaza salud 0 y el menú de pausa no guarda si el
   jugador está muerto.

## Criterios de aceptación

- [x] Al morir no se revive: la run se acaba.
- [x] El slot de la run muerta desaparece del menú (no se puede continuar).
- [x] La pantalla solo ofrece menú principal o salir.
- [x] Guardar durante/después de morir no escribe una run muerta.
- [ ] F5: morir de verdad (sin KP5) y comprobar pantalla, pausa y menú.

## Resultado

- `scripts/player.gd`: `signal died`, `is_dead()` y emisión al final de `_die()`.
- `scripts/game.gd`: conexión de `died` y `_on_player_died()` con borrado del
  slot, margen para la animación y `DeathScreen.show_death(seed, coins)`.
- `scripts/ui/pause_menu.gd`: "Guardar y salir" no guarda si `player.is_dead()`.
- `scripts/save_game.gd`: `save_run()` devuelve `false` con salud ≤ 0.
- Nuevos `scenes/ui/death_screen.tscn` y `scripts/ui/death_screen.gd`, y nodo
  `DeathScreen` en `scenes/game.tscn` (CanvasLayer 30, `process_mode = ALWAYS`).
- Bug encontrado por Ruben (13-11): la pantalla no aparecía. Causa: el editor
  abierto reserializó `scenes/game.tscn` y eliminó el nodo `DeathScreen` (y su
  `ext_resource`), así que `Game._on_player_died()` moría en silencio al no
  encontrarlo. Arreglo: nodo devuelto a la escena **y**
  `Game._ensure_death_screen()`, que instancia `death_screen.tscn` si falta.
- Verificado con script headless desechable (borrado después): matar al jugador
  (`take_damage(9999)`) deja `dead=true`, `health=0`, `screen_visible=true` y
  `paused=true`; Godot sale con código 0 y sin errores de script. F5 visual
  pendiente.
