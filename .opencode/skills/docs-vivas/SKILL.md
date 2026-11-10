---
name: docs-vivas
description: Use before exploring the codebase for how a system works (player, enemies, world generation, HUD, inventory, passives, loot) and after any task that changes behavior or closes a decision. Keeps docs/*.md as the project memory so one small file is read instead of re-reading code.
---

# Living documentation (`docs/`)

The project memory is `docs/*.md`. Code is read only when the doc does not answer; if the doc does not answer, fix the doc in that same task.

## Before investigating

1. Check the index in `AGENTS.md`. If there is a file for the system, **read it before touching code**.
2. If the doc does not cover what you need, search `docs/` by keyword (`grep`) before opening scripts.
3. Only then explore code, and keep it scoped (a specific file or function), not the whole project.
4. If the doc contradicts the code, the code wins: fix the doc when you finish.

## When to write

- Behavior, a scene, a UI scene, a resource or an export changed.
- A decision was closed (even if it was "not doing it").
- A bug took more than two attempts: write down the cause, not the symptom.
- An editor, `.tscn`/`.tres` or export trap was discovered.

## Format

`docs/<system>.md`, **≤30 lines**, in English, with file/node/class names in `` `code` ``:

```md
# <System> — <what it covers in one line>
_YYYY-MM-DD · branch `<branch>`_

## What it does and where it lives
- Node/script and path.

## Closed decisions
- What was chosen and why (one line each).

## Traps
- A mistake that already bit and how to avoid it.

## Pending
- Only if something was agreed but not done.
```

- Don't paste whole code: names, signals, exports and the reason.
- One file per system. If it goes past ~30 lines, split by subsystem and add the row to the index.
- Don't repeat here what `AGENTS.md` already says: that file doesn't grow.
- When creating a new file, add its row to the `AGENTS.md` index.
