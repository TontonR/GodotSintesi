# T-0064 · Lobo: no se queda congelado y tras el stun elige embestida o salto

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `arreglo` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | enemies |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0062 |

## Problema

Ruben: el lobo, cuando te persigue y se queda quieto, se queda así para siempre.
Además, al salir del stun debe poder tanto volver a correr (embestir) como hacer
un ataque de salto.

## Causa

- `_update_behavior()` tenía `match _state` con `WANDER`, `WINDUP`, `CHARGE`,
  `JUMP` y `STUN`, pero **sin rama `RECOVER`**: `_process_recovery()` existía y
  nunca se llamaba. Tras cada embestida o salto el estado quedaba en `RECOVER`
  con su temporizador parado: el lobo se paraba en seco y no volvía a moverse
  ni a atacar nunca.
- El temporizador de `RECOVER` es lo que devuelve al lobo a `WINDUP` (o a
  vagar si el jugador ya no está), así que su ausencia también rompía la vuelta
  al vagabundeo cuando el jugador sale del área.
- El final del stun siempre llamaba a `_start_windup()`, que decidía con el
  contador del ciclo 2 + 1: salía siempre una embestida más (el stun no cuenta
  como embestida).

## Plan

1. Añadir `State.RECOVER: _process_recovery(delta)` al `match`.
2. Añadir `stun_jump_chance` (0.5): al terminar el stun, elegir al azar entre
   embestida y salto con `_stun_next_attack`, que `_launch_attack()` respeta una
   sola vez.

## Criterios de aceptación

- [x] Tras una embestida o un salto el lobo vuelve a moverse (no se congela).
- [x] Si el jugador sale del área, el lobo vuelve a vagar en vez de quedarse
      parado.
- [x] Al terminar el stun puede embestir o saltar (ambas salidas aparecen).
- [ ] F5: embestir, parar el golpe con parry y ver que alterna.

## Resultado

- `scripts/enemies/werewolf.gd`: rama `RECOVER` en el `match`, `stun_jump_chance`
  (0.5), `_stun_next_attack` (-1 automático / 1 embestida / 2 salto) consumido en
  `_launch_attack()` y limpiado en `_return_to_wander()`.
- Verificado headless con script desechable: `RECOVER` con temporizador a 0 pasa
  a `WINDUP`; 40 stuns seguidos reparten intenciones entre embestida y salto; la
  intención forzada lleva a `CHARGE`/`JUMP`. `--check-only` sin errores. F5
  pendiente.
