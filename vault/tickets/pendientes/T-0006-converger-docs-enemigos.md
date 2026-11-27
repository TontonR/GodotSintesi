# T-0006 · Converger la documentación de los enemigos nuevos

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `docs` |
| Prioridad | `alta` |
| Dueño | `sin asignar` |
| Sistema | docs |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0001 |
| Ficheros | `docs/enemies.md`, `AGENTS.md`, docs de la rama `feat/enemigos-demon-toad-werewolf` |

## Problema

Los tres docs del compañero (`docs/enemigo_demon.md`, `docs/enemigo_mutant_toad.md`, `docs/enemigo_werewolf.md`) viven **solo en su rama** (`685bc30`). En `main` no existen, no están en el índice de `AGENTS.md` y `docs/enemies.md` no menciona a los tres enemigos.

Al ser un proyecto de dos agentes, un doc que se queda en una rama es conocimiento perdido: el otro agente re-investiga el código.

## Contenido que hay que salvar de sus docs

- Demonio: ciclo FLY/BREATH/aturdimiento, `lean_degrees` 12°, 5 daño/0.5 s, aturdido 5 s o 3 golpes, alcance de la hurtbox 34×60 en `y+10`.
- Sapo: estados `IDLE/JUMP/ATTACK`, salto cada `jump_wait_min..max`, ataque cada 3 aterrizajes, ráfaga de 3 con desviación ±12°, proyectil destructible de 1 golpe, vida 4 s.
- Lobo: ciclo 2 embestidas + 1 salto, `charge_windup`, embestida recta a 220 px/s, knockup 280 + bloqueo 0.12 s, merodeo por zona y dependencia del grupo `world_generator`.

## Correcciones al portar

- El doc del sapo dice sprites en `Spritesheets/`; el commit añade `Sprites/`.
- El doc del sapo dice que ya no hay charcos tóxicos: confirmar contra `mutant_toad.gd` al integrar.
- Los docs del compañero miden 44–59 líneas y usan `Fecha:`; el estándar de `AGENTS.md` es **≤30 líneas** por sistema.
- `docs/enemies.md` puede quedarse corto con 5 enemigos: si pasa de ~30 líneas, dividir en `docs/enemigo_demon.md`, `docs/enemigo_mutant_toad.md`, `docs/enemigo_werewolf.md` y añadir 3 filas al índice.

## Plan

1. Al cerrar T-0001, fusionar el contenido en `docs/enemies.md` (o crear los tres ficheros).
2. Añadir las filas al índice de `AGENTS.md` (sin pasar de ~70 líneas en total).
3. Borrar los docs sueltos de la rama y dejar una sola fuente de verdad.

## Criterios de aceptación

- [ ] Los tres enemigos están documentados en `main`.
- [ ] `AGENTS.md` enlaza cada doc nuevo.
- [ ] Ninguna ruta de sprite o nombre de export contradice el código.

## Resultado

Pendiente.
