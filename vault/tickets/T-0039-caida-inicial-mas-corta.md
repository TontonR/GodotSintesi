# T-0039 · Caída inicial más corta

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player / world |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0018 |

## Problema

Al entrar en la partida la caída desde el cielo dura demasiado: se tarda en empezar a
jugar. `scripts/world/fall_intro.gd` arrancaba al jugador 520 px por encima del punto de
spawn a 300 px/s (≈1,7 s), y el generador deja además 6 tiles (96 px) entre el spawn y el
suelo (`player_spawn_height_tiles`), así que el total pasaba de 2 s.

## Causa / contexto

Los valores por defecto del `FallIntro` no se sobrescriben en `scenes/game.tscn`: mandan
los del script. `max_seconds` (6 s) solo es red de seguridad, no el motivo del retraso.

## Plan

1. Bajar `fall_height_px` a 260 y subir `fall_speed` a 620 (≈0,4 s de caída).
2. Bajar `max_seconds` a 3 para que la red de seguridad no deje al jugador colgado.
3. Anotar el nuevo tiempo en `docs/player.md`.

## Criterios de aceptación

- [ ] Desde Play se controla al jugador en menos de 1 s.
- [ ] La caída sigue viéndose (no aparece ya en el suelo).
- [x] `docs/player.md` actualizado.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

`fall_intro.gd`: `fall_height_px` 260, `fall_speed` 620 y `max_seconds` 3; con los 96 px
del generador la caída completa dura ~0,7 s (antes ~2,2 s). F5 pendiente.
