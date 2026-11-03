# T-0015 · Debug: velocidad x1/x2/x4 y viaje rápido en el numpad

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-11-03) |
| Tipo | `feat` (debug) |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | debug / player |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `scripts/debug_tools.gd` (nuevo), `scripts/player.gd`, `scenes/game.tscn`, `README.md`, `docs/player.md` |

## Pedido

Volver a tener la opción de velocidad x1/x2/x4 y más atajos en el numpad para probar: KP6 = viaje a la derecha y algo hacia arriba (para no quedarse atrapado en montañas), KP4 = lo mismo al otro lado.

## Hecho

- `DebugTools` (`scripts/debug_tools.gd`), nodo `debug_tools` en la raíz de `scenes/game.tscn`.
- Velocidad: `@export_enum("x1", "x5", "x20") game_speed` (arranque, visible en el inspector) y KP7/KP8/KP9 en caliente, aplicados a `Engine.time_scale`. `_exit_tree` lo devuelve a 1.0. (2026-11-03: los antiguos x2/x4 pasan a x5/x20 a petición de Jorge.)
- Viaje rápido: KP6 (`+64` tiles en X) y KP4 (`-64` tiles), ambos `-10` tiles en Y. Exportados `teleport_distance_tiles` y `teleport_lift_tiles`.
- `player.debug_teleport(offset)` mueve, corta la velocidad, limpia el desfase de escalón y reinicia `_cam_y`.
- Etiqueta `DebugHint` abajo a la izquierda con la velocidad actual y las teclas.
- Los ítems de prueba (KP0-KP3) no se han tocado: siguen en `scenes/inventory/inventory.gd`.

## Comprobación

Sin tests en el proyecto. Revisado: teclas sin solape con el inventario, `class_name` sin duplicado, `ExtResource("20_dbg")` declarado en la escena y el nodo con su script. Falta verlo en editor (F5): KP9 debe acelerar también el ciclo de día/noche (usa el mismo `time_scale`).

## Resultado

Atajos de prueba centralizados en un solo nodo borrable. Si se quita el debug: quitar el nodo `debug_tools` de `game.tscn` y `debug_teleport()` de `player.gd`.
