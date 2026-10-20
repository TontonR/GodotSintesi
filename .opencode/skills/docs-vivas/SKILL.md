---
name: docs-vivas
description: Use before exploring the codebase for how a system works (player, enemies, world generation, HUD, inventory, passives, loot) and after any task that changes behavior or closes a decision. Keeps docs/*.md as the project memory so one small file is read instead of re-reading code.
---

# Documentación viva (`docs/`)

La memoria del proyecto son `docs/*.md`. El código se lee solo cuando el doc no responde; si el doc no responde, se arregla el doc en esa misma tarea.

## Antes de investigar

1. Mira el índice de `AGENTS.md`. Si hay fichero para el sistema, **léelo antes de tocar código**.
2. Si el doc no cubre lo que necesitas, busca en `docs/` por palabras clave (`grep`) antes de abrir scripts.
3. Solo entonces explora código, y acotado (fichero o función concreta), no el proyecto entero.
4. Si el doc contradice al código, gana el código: corrige el doc al terminar.

## Cuándo escribir

- Cambió comportamiento, escena, escena de UI, recurso o export.
- Se cerró una decisión (aunque sea "no se hace").
- Un bug costó más de dos intentos: apunta la causa, no el síntoma.
- Se descubrió una trampa del editor, de `.tscn`/`.tres` o de un export.

## Formato

`docs/<sistema>.md`, **≤30 líneas**, en español, con nombres de ficheros/nodos/clases en `` `code` ``:

```md
# <Sistema> — <qué cubre en una línea>
_AAAA-MM-DD · rama `<rama>`_

## Qué hace y dónde vive
- Nodo/script y ruta.

## Decisiones cerradas
- Qué se eligió y por qué (una línea cada una).

## Trampas
- Error que ya picó y cómo se evita.

## Pendiente
- Solo si hay algo acordado sin hacer.
```

- No pegues código entero: nombres, señales, exports y el porqué.
- Un fichero por sistema. Si pasa de ~30 líneas, divide por subsistema y añade la fila al índice.
- No repitas aquí lo que ya está en `AGENTS.md`: ese fichero no crece.
- Al crear un fichero nuevo, añade su fila al índice de `AGENTS.md`.
