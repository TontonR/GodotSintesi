# T-0068 · Sincronizar el vault tras el F5 y corregir el diseño de objetos

| Campo | Valor |
|---|---|
| Estado | `cerrado` |
| Tipo | `docs` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | docs / vault |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-17 |
| Relacionado | T-0002, T-0004, T-0056, T-0065 |

## Problema

Ruben ha probado estos días todo lo que estaba en `revision`: funciona. Pero el vault
seguía contando lo contrario:

- `estado.md` decía que estábamos en `feat/decor` con el PR #1 abierto, cuando `main` ya
  tiene mergeados el PR #1 y el PR #3 (T-0066 y T-0067 incluidos).
- ~55 tickets en `revision` o `en curso` esperando un F5 que ya se hizo.
- `roadmap.md` mantenía abierto **T-0002 (skills)** y listaba "armas mejorables" como
  diseño pendiente; ambas cosas están descartadas: **no habrá skills ni armas**.
- `ideas.md` seguía pidiendo 5 huecos (2 skills + 3 consumibles) y armas mejorables.
- El árbol tenía `scenes/enemies/mutant_toad.tscn` modificado (el editor borró
  `node_paths`) y `.obsidian/` sin ignorar.

## Diseño confirmado por Ruben (2026-11-17)

- Solo hay **consumibles** (huecos 1, 2, 3; se pueden obtener más huecos) y
  **coleccionables**: cada uno da una habilidad pasiva, que puede ser siempre activa o
  cumplirse bajo una condición. El taparrabos es el ejemplo de siempre activa (+stats).
- **No hay armas** y nunca las habrá. No hay skills.

## Plan

1. Cerrar los tickets ya verificados en F5 y T-0002 como descartado.
2. Reescribir `estado.md` con la realidad de `main` y el siguiente paso.
3. Purgar `roadmap.md` de cerrados y de skills/armas.
4. Corregir `ideas.md` (estructura del inventario, decisiones 14-16) y `docs/items.md`.
5. Revertir `mutant_toad.tscn` e ignorar `.obsidian/`.
6. Entrada en `changelog.md` y en `bitacora.md`.

## Criterios de aceptación

- [x] Ningún ticket queda en `revision` si Ruben ya lo probó.
- [x] T-0002 cerrado como descartado, con el motivo escrito.
- [x] `estado.md`, `roadmap.md` e `ideas.md` sin skills, sin armas y con `main` al día.
- [x] Árbol limpio salvo cambios con ticket.
- [x] PR #4 mergeado en `main` (`df20843`).

## Resultado

- 58 tickets cerrados en bloque (F5 de Ruben); casillas de F5 marcadas. T-0001 cerrado
  como absorbido por T-0019 y T-0002 como descartado.
- `estado.md` reescrito: `main` en `3001492` (PR #1 y #3 mergeados), árbol limpio,
  siguiente paso = coleccionables del arquero + T-0003/T-0007.
- `roadmap.md`: fuera cerrados, T-0002 y armas; quedan T-0003, T-0004, T-0005, T-0006,
  T-0007 y T-0008.
- `ideas.md`: inventario = 3 consumibles (ampliables) + coleccionables; sin armas ni
  skills; decisiones 14-16 reescritas.
- `docs/items.md`: nota de taxonomía (sin armas, sin skills) y slots extra como diseño.
- `docs/passives.md` y `vault/items.md`: el nombre de diseño es *coleccionable*; una
  pasiva siempre activa o condicional por coleccionable.
- `mutant_toad.tscn` revertido (el `node_paths` lo borraba el editor; el script ya tiene
  fallback `get_node_or_null`) y `.obsidian/` añadido a `.gitignore`.

Merge: [PR #4](https://github.com/TontonR/GodotSintesi/pull/4), squash en `df20843`.
