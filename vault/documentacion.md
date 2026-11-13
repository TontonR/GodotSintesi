# Documentación — mapa, auditoría y huecos

_2026-11-12 · creado por `buffy` (T-0056)_

Punto de entrada único a la documentación. Regla: **la verdad técnica vive en `docs/`**;
el vault solo enlaza, audita y dice qué falta. Si `docs/` y el código se contradicen, gana
el código y se corrige el doc en esa tarea.

## Qué cubre cada `docs/`

| Sistema | Doc | Estado | Qué incluye |
|---|---|---|---|
| Enemigos | [`docs/enemies.md`](../docs/enemies.md) | reescrito 2026-11-12 | Base, catálogo de los 8 con stats, comportamiento, spawn y trampas |
| Loot y recogida | [`docs/loot.md`](../docs/loot.md) | nuevo 2026-11-12 | Monedas, tirada única de objetos, tablas reales por enemigo, física y persistencia |
| Biomas | [`docs/biomes.md`](../docs/biomes.md) | nuevo 2026-11-12 | Campos del `.tres`, los 3 biomas, runs, transiciones, tintes y ambiente |
| Pasivas | [`docs/passives.md`](../docs/passives.md) | nuevo 2026-11-12 | `PlayerPassives`, hooks, catálogo de 35 pasivas y cómo añadir una |
| Items e inventario | [`docs/items.md`](../docs/items.md) | reescrito 2026-11-12 | Jerarquía, 3 slots, 9 consumibles reales, iconos y debug |
| Mundo | [`docs/world.md`](../docs/world.md) | corregido 2026-11-12 | Chunks, terreno, pared izquierda, biomas (resumen), día/noche y caída |
| Jugador | [`docs/player.md`](../docs/player.md) | corregido 2026-11-12 | Movimiento, combo, guardia/parry, stats y debug |
| UI | [`docs/ui.md`](../docs/ui.md) | corregido 2026-11-12 | HUD, monedas, rejilla de pasivas, inventario, menús, pausa y guardado |
| FX | [`docs/fx.md`](../docs/fx.md) | al día | Partículas, números de daño, shake, parry y sangre |
| Historial | [`docs/historial.md`](../docs/historial.md) | ampliado 2026-11-12 | Bugs que ya mordieron (drops, HUD, relieve, enemigos) |
| Pasivas por enemigo | [`vault/pasivas/`](pasivas/README.md) | corregido 2026-11-12 | Reparto de Jorge con probabilidades reales (histórico) |
| Cómo correr y controles | [`README.md`](../README.md) | corregido 2026-11-12 | F5, controles reales (1-3 consumibles) y debug |

## Lo que faltaba y se ha creado

Antes del 2026-11-12, `docs/` tenía 7 ficheros pero el contenido estaba desfasado en varios
puntos y no existía referencia de tres sistemas completos:

1. **Biomas**: estaban enterrados en `docs/world.md` y los sets de enemigos ya no coincidían
   con los `.tres`. Ahora hay tabla por bioma, reglas de runs y checklist para añadir uno.
2. **Loot**: no había doc propio. Se documentaron las dos tiradas (moneda y objeto), las
   tablas reales (orco 42 %, lobo/rana/slime 32 %) y la física de `item_pickup`/`coin`.
3. **Pasivas**: solo existían las tablas del vault. Ahora `docs/passives.md` explica
   `PlayerPassives`, los hooks, el catálogo completo y cómo añadir una.
4. **Catálogo de enemigos**: `docs/enemies.md` hablaba de "4 orcos + 1 fantasma" pero los
   biomas ya no usan fantasmas ni demonios. Se reescribió con stats y comportamiento real.
5. **Items**: decía "missing texture" en las 44 filas; los 44 `.tres` ya tienen icono.
   También se corrigieron la Maza (+2) y el Colmillo de lobo (+3).
6. **README**: los controles seguían hablando de skills 1-2 y consumibles 3-5 (ahora son
   consumibles 1-3) y del botón "Play" (ahora "New Game").

## Huecos que siguen sin documentación (a propósito)

No se inventan docs para sistemas que no existen o no están cerrados:

| Hueco | Por qué no hay doc |
|---|---|
| Audio / música | No hay sistema ni assets de audio en el proyecto |
| Muerte y respawn del jugador | `_die()` es un placeholder que respawnea lleno (idea en `roadmap.md`) |
| Skills / habilidades activas | Eliminadas del código; solo queda el ticket T-0002 |
| Jefe de zona, salas especiales | Ideas sin implementar |
| Progresión (niveles, subir stats) | Ideas sin implementar |
| Balance fino | Los números están en los `.tres`/escenas y se cambian ahí; no se copian aquí |
| Formato de assets y arte | Depende del pack; pendiente de un `docs/assets.md` si crece |
| Tests | El proyecto no tiene tests; la verificación es F5 o script headless desechable |

## Cómo mantener esto

- Al cerrar un ticket que cambie comportamiento: actualizar el `docs/<sistema>.md` y, si el
  mapa cambia, esta tabla.
- Si aparece un sistema nuevo (audio, progresión, jefe): crear `docs/<sistema>.md`, añadirlo
  a `AGENTS.md` y a la tabla de arriba.
- No duplicar tablas entre `docs/` y `vault/`: el vault enlaza y anota el estado.
- Marcar la fecha de la última revisión en cada doc (`_YYYY-MM-DD_` bajo el título).
