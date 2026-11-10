# T-0041 · Menú principal con ajustes de ventana

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui / repo |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0018 |

## Problema

El menú solo tenía el botón **Play**. Ruben quiere **Nueva partida**, **Continuar**
(solo si hay partida guardada), **Ajustes** y **Salir**, y en Ajustes únicamente modo de
ventana (ventana, pantalla completa y ventana en pantalla completa) y resoluciones.

## Causa / contexto

`project.godot` usa viewport 768×432, `window/size/window_width_override` 1536×864,
`window/stretch/mode="canvas_items"` y `window/stretch/scale_mode="integer"`. El aviso de
Ruben: no cambiar ese esquema, solo reescalar. Por eso las resoluciones son múltiplos
enteros del viewport y se aplican con `DisplayServer.window_set_size()`, no tocando
`viewport_width/height`.

No hay sistema de guardado: **Continuar** se muestra solo si existe
`user://savegame.cfg`, y nada lo escribe todavía.

## Plan

1. `scenes/main_menu.tscn`: `NewGame`, `Continue` (oculto por defecto), `Settings` y `Quit`;
   panel `SettingsPanel` con modo de ventana, resolución y `Back`.
2. `scripts/ui/main_menu.gd`: ajustes en `user://settings.cfg`, aplicación al arrancar,
   lista de resoluciones filtrada por pantalla, Esc para volver y `change_scene_to_file`
   compartido por Nueva partida y Continuar.
3. Documentar en `docs/ui.md`.

## Criterios de aceptación

- [ ] Los cuatro botones responden con ratón y teclado; Esc cierra Ajustes.
- [ ] Ventana / pantalla completa / ventana en pantalla completa cambian al instante.
- [ ] Las resoluciones se aplican solo en modo ventana y caben en la pantalla.
- [ ] Los ajustes se conservan al cerrar y abrir el juego.
- [ ] `Continuar` no aparece si no hay `user://savegame.cfg`.
- [x] `docs/ui.md` actualizado.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

Menú con 4 entradas y panel de ajustes (modo de ventana + resoluciones múltiplo del
viewport, guardados en `user://settings.cfg`). `Continuar` queda condicionado a
`user://savegame.cfg`, que aún no escribe nadie. Viewport y stretch intactos. F5 pendiente.
