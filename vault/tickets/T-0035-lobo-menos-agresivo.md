# T-0035 · Bajar la agresividad del lobo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | enemies |
| Creado | 2026-11-09 |
| Actualizado | 2026-11-09 |
| Relacionado | T-0019 |

## Problema

El lobo (`scripts/enemies/werewolf.gd`) es demasiado difícil: embiste a 220 px/s
(más que el sprint del jugador, 221 px/s), recorre todo el diámetro de detección
(~972 px) y al terminar volvía a perseguir y embestir casi sin pausa.

## Plan

1. Bajar `charge_speed` a 150 px/s.
2. Añadir `charge_distance_scale` (0.4) sobre `_get_detection_diameter()`.
3. Subir `attack_recovery` a 1.5 s y dejar al lobo parado en el destino durante
   la recuperación (quitar la persecución de `_recover_chasing`).

## Criterios de aceptación

- [ ] En F5 el lobo se puede esquivar corriendo y deja 1,5 s de pausa tras cada embestida.
- [x] `docs/enemies.md` actualizado.
- [x] Entrada en `changelog.md` y `estado.md`.

## Resultado

Cambiados los exports por defecto de `werewolf.gd`: `charge_speed` 150,
`charge_distance_scale` 0.4, `attack_recovery` 1.5. `_begin_recovery()` ya no
persigue: se queda quieto en el destino. F5 pendiente (no se ejecuta Godot).
