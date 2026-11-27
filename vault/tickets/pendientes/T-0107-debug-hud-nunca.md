# T-0107 · El aviso de debug no puede aparecer en una partida normal

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0005 · T-0015 |

## Problema

Con `DEBUG_TOOLS = false` (T-0005) los objetos de prueba ya no respondían, pero el nodo
`debug_tools` seguía vivo: `_ready()` montaba siempre el `Label` `DebugHint` en `UILayer` y
el nodo continuaba leyendo el numpad. En la captura de Ruben se veía la línea
`speed x1 · immortal no · KP7/KP8/KP9 speed half/reset/double …` abajo a la izquierda, y
`Engine.time_scale` seguía dependiendo de la escena.

## Causa / contexto

El interruptor de T-0005 solo cubría `scenes/inventory/inventory.gd`. `scripts/debug_tools.gd`
no tenía ningún interruptor: el label se construía sin condición.

## Plan

1. `enabled` exportado, `false` por defecto, en `DebugTools`.
2. `_ready()`: con el nodo apagado no monta label, no procesa ni escucha input y deja
   `Engine.time_scale` en 1.
3. `enabled = false` explícito en `game.tscn`, para verlo en el inspector.
4. Docs (`README.md`, `docs/player.md`).

## Criterios de aceptación

- [x] Una partida normal no muestra `DebugHint` ni reacciona al numpad.
- [x] `Engine.time_scale` se queda en 1 con el nodo apagado.
- [x] Encenderlo desde el inspector recupera todos los atajos de siempre.
- [x] `docs/player.md` y `README.md` actualizados.

## Resultado

Hecho el 2026-11-27 por `buffy`. `DebugTools.enabled` (`scripts/debug_tools.gd`) apaga el nodo
entero: sin label, sin `_unhandled_input`, `Engine.time_scale = 1`. `scenes/game.tscn` lo deja
en `false`, así que el aviso de la captura ya no puede salir en una partida normal; para
depurar se marca la casilla en el inspector. Comprobado por lectura, **sin F5**.
