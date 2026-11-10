---
description: Save the session's new knowledge into docs/ without re-reading the project.
agent: build
---

Save into the documentation what was learned/decided in this session: $ARGUMENTS

1. Don't re-read files "just in case": use what you already have in this session's context.
2. Pick the right `docs/<system>.md` (create it if missing) and add a ~30-line summary dated `YYYY-MM-DD`: decisions taken, what was wired/pending and mistakes found.
3. If you create a new file, add it to the `AGENTS.md` index.
4. **Never grow `AGENTS.md`** (max ~70 lines): new content goes to `docs/`.
5. Don't touch code, don't run tests or commands.
