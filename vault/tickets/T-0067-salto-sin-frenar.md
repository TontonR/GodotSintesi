# T-0067 · El salto no corta la carrera ni cobra la entrada dos veces

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0066 |

## Problema

Corriendo con Shift, saltar corta la carrera: el jugador pierde el 1.7× en el
aire, se frena y, al aterrizar con Shift pulsado, se le cobra otra vez la
entrada de carrera (`run_initial_cost`). Resulta incómodo y gasta estamina de
más en cada salto.

## Causa

`Player._update_stamina()` apagaba `_is_running` en cuanto `is_on_floor()` era
falso. Sin `_is_running`, `_physics_process()` usa `move_speed` (130) y
`acceleration` (750) en vez de los multiplicados (221 y 975), así que
`move_toward` frena la X en el aire. Al volver al suelo, la rama de entrada
veía `run_input` + `is_on_floor()` y volvía a llamar a `spend_stamina(run_initial_cost)`.

## Plan

1. Quitar `not is_on_floor()` de la condición que apaga la carrera.
2. Dejar que el drenaje siga en el aire; solo se corta al soltar Shift,
   guardar, atacar o quedarse sin estamina.
3. Documentar el comportamiento en `docs/player.md`.

## Criterios de aceptación

- [x] Saltar corriendo mantiene la velocidad de carrera y no frena la X.
- [x] Al aterrizar con Shift pulsado no se cobra de nuevo la entrada.
- [x] El drenaje de carrera sigue activo mientras se está en el aire.
- [x] `docs/player.md` actualizado.
- [ ] F5: correr, saltar y comprobar que no frena y que la barra solo baja por drenaje.

## Resultado

- `scripts/player.gd`: `_is_running` ya no se apaga por `not is_on_floor()`;
  la condición queda en soltar Shift, guardar o atacar. La rama de entrada no
  se repite al aterrizar porque la carrera nunca llegó a apagarse.
- `docs/player.md`: nota en Movement y valores de guardia del anti-spam al día.
- Sin ejecutar Godot (regla de `AGENTS.md`); revisión del diff. F5 pendiente.
