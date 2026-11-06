# T-0033 · La sacudida de cámara no debe borrar el encuadre

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player |
| Creado | 2026-11-06 |
| Actualizado | 2026-11-06 |
| Relacionado | T-0009, T-0028 |

## Problema

Al recibir el primer golpe la cámara se recentra en el jugador y ya no vuelve al
encuadre inicial: se pierde el desfase de `(60, -70)` que trae la `Camera2D` en
`scenes/player.tscn:450`. Se nota sobre todo al reiniciar la partida y comparar
con el arranque.

## Causa / contexto

`scripts/fx.gd` hace la sacudida escribiendo directamente `camera.offset` y, al
terminar, lo deja en `Vector2.ZERO` (`_process`). Ese `offset` es el encuadre del
juego (jugador algo a la izquierda y por debajo del centro), no un valor de la
sacudida, así que la primera sacudida lo borra de forma permanente. Cualquier
sacudida lo dispara (golpe recibido, crítico, muerte de enemigo, parry), pero se
hace evidente con el primer golpe.

## Plan

1. Guardar el `offset` base de la cámara al iniciar una sacudida (solo si no hay
   otra activa, para no capturar el temblor).
2. Aplicar el temblor como `base + aleatorio` y restaurar `base` al acabar.

## Criterios de aceptación

- [ ] Tras un golpe, un crítico, una muerte o un parry la cámara vuelve al
      encuadre de `(60, -70)`, no al centro del jugador.
- [ ] Varias sacudidas seguidas no desplazan el encuadre de forma acumulativa.
- [ ] `docs/fx.md` actualizado; changelog y estado al cerrar.

## Resultado

Código en `scripts/fx.gd`: `_camera_base_offset` se captura en `shake()` cuando
no hay sacudida activa y `_process` lo restaura al expirar el temblor. Pendiente
de F5 (regla de `AGENTS.md`).
