# GodotSintesi — Reglas del agente

Roguelike 2D en **Godot 4.7** (`project.godot`), pixel-art. Idioma: comentarios `#`, textos de UI y `.tres` **en español**; identificadores, `@export(_group)` y doc `##` **en inglés** en los sistemas de objetos/inventario/UI/pasivas/loot (ver `docs/ui.md`). `player`/`enemies`/`world_generator` siguen como estaban.

## Carga perezosa de documentación (CRITICAL)

Este es el único fichero siempre en contexto. **No leas nada más "por si acaso"**:

- Si la tarea necesita detalles de un sistema, carga SOLO el fichero del índice con Read, bajo demanda.
- No precargues todos; no re-investigues lo que ya está documentado.
- Para búsquedas amplias por el código delega en `@explore` y pide un resumen: así no llenas el contexto principal.

### Índice (leer solo si hace falta)

| Fichero | Cuándo |
|---|---|
| `docs/items.md` | Inventario (5 huecos), catálogo de 6 objetos, drops y recogida |
| `docs/ui.md` | HUD, grid de pasivas (6 col, 10 filas/página), pantalla de inventario (Tab/I), convención EN/ES |
| `docs/player.md` | Movimiento, combo, guardia, vida, stamina y teclas |
| `docs/enemies.md` | `EnemyBase`, fantasma (TP) y orco; loot |
| `docs/world.md` | Generación por zonas, suelo, población y capas |
| `docs/historial.md` | Bugs ya resueltos (drops, loot); leer solo si algo huele a eso |
| `documentation.md` | Histórico (396 líneas). Solo arqueología; no usar como fuente |

## Reglas de trabajo

- **No tocar nada que no se haya pedido.** Sin tests, validaciones, commits ni comandos de Godot salvo petición explícita.
- El editor de Godot suele estar **abierto**: tras un `checkout/reset` reserializa las escenas abiertas (añade `unique_id`/`node_paths`). Si `git status` muestra una escena que no tocaste, es el editor.
- Salidas de terminal: **filtra siempre**. Nunca listes `assets/` sin filtrar (+1000 PNG revientan el contexto).

## Convenciones

- GDScript con tabs; `class_name`; `##` sobre cada `@export`; agrupar en `@export_group`.
- Escenas en `scenes/`, scripts en `scripts/`. En la raíz hay legacy: `player.tscn`, `item_pickup.gd/.tscn`, `documentation.md`.
- Enemigos extienden `EnemyBase` (`scripts/enemies/enemy_base.gd`); jugador en grupo `player`.
- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 384×216.
- Exports de escena del fantasma: `projectile` (no `projectile_scene`).

## Guardar conocimiento (siempre)

Al terminar una tarea que cambie comportamiento o cierre una decisión:

1. Resume el resultado en `docs/<sistema>.md` (créalo si no existe), ~30 líneas máximo, con fecha `AAAA-MM-DD`.
2. **Este fichero no crece**: si supera ~70 líneas, lo nuevo va a `docs/`.
3. Si creas un fichero nuevo, añádelo al índice de arriba.
4. Plantilla y cuándo escribir: skill `docs-vivas` (cárgala antes de investigar y al cerrar la tarea).
