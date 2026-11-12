# T-0053 · Debug de velocidad: KP7 mitad, KP9 doble, KP8 reset

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `debug` |
| Prioridad | `baja` |
| Dueño | `buffy` |
| Sistema | debug |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0015, T-0052 |

## Petición

`humano-ruben`: en vez de x1/x5/x20, KP7 debe **reducir la velocidad a la mitad** y KP9
**duplicarla, sin límite**; KP8 **resetea** a x1.

## Plan

1. Quitar `SPEEDS`/`SPEED_LABELS` y el `@export_enum game_speed`: el estado pasa a ser
   un float `_speed` aplicado a `Engine.time_scale`.
2. KP9 `_speed * 2`, KP7 `_speed * 0.5`, KP8 `1.0`; sin tope por arriba.
3. Suelo `MIN_SPEED` 0.001 para que dividir nunca llegue a x0 (congelaría el juego).
4. Etiqueta con el factor actual (`x2`, `x0.5`).

## Criterios de aceptación

- [x] KP9 duplica sin tope; KP7 parte a la mitad; KP8 vuelve a x1.
- [x] La etiqueta muestra el factor real.
- [x] `_exit_tree` sigue devolviendo `time_scale` a 1.0.

## Resultado

`scripts/debug_tools.gd`: fuera los arrays de velocidades; `_speed` + `_apply_speed(value)`
y `_speed_label()`; `game_speed` pasa a `start_speed` (`@export`, por defecto x1).

Comprobado con script headless enviando teclas al nodo `debug_tools`: x1 → KP9 x2 →
KP9 x4 → KP7 x2 → KP8 x1 → KP7 x0.5 → KP7 x0.25, con la etiqueta en `x0.25`. F5
pendiente (el nodo no fija `start_speed` en la escena, así que el editor arranca en x1).
