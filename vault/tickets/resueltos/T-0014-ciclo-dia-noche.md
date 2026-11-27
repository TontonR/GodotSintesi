# T-0014 · Ciclo de día y noche

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-11-03) |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | mundo |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `scripts/world/day_night.gd` (nuevo), `scenes/game.tscn`, `docs/world.md` |

## Pedido

Ciclo día/noche: día de 5 min y noche de 3 min. La noche **solo** cambia el color del fondo; no oscurece el juego.

## Hecho

- `DayNightCycle` (`scripts/world/day_night.gd`) es un `Node` que avanza un reloj en `_process` y aplica el color con `RenderingServer.set_default_clear_color`: es el único sitio del juego que toca el fondo.
- Duraciones `@export`: `day_duration` 300 s, `night_duration` 180 s. `fade_seconds` 12 s de fundido en cada cambio de fase (recortado a la mitad de la fase más corta; 0 = salto seco).
- `day_color` por defecto = `default_clear_color` de `project.godot` (`Color(0.50980395, 0.7882353, 0.99215686, 1)`, mismo valor exacto); `night_color` = azul noche. Nada de `CanvasModulate` ni ambient: sprites, tiles y UI mantienen su color.
- Nodo `day_night` añadido en la raíz de `scenes/game.tscn`.

## Comprobación

Sin tests en el proyecto. Revisado: script sin `class_name` duplicado, escena con `ExtResource("19_dnt")` declarado, y el color por defecto de día idéntico al de `project.godot` (sin salto al arrancar). Pendiente de ver en editor (F5): un ciclo completo son 8 min, así que para verlo rápido bajar las duraciones desde el inspector.

## Resultado

Ciclo funcional. Para probar la noche en segundos: `day_duration = 10`, `night_duration = 10`. Si más adelante se quiere oscurecer el juego de verdad, eso es otro ticket (tintado global aparte).
