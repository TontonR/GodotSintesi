# Estado del proyecto

_Actualizado 2026-11-13 por `opencode-jorge`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `main`, commits locales de la sesión (T-0039..T-0049); sin push |
| Árbol | T-0039..T-0049 (menús, guardado, biomas, sangre, fullscreen, pendiente), T-0051 (pociones), T-0052/T-0053 (iconos de pasivas), sin commit; ver `changelog.md` |
| Fase | Mundo procedural, cámara, menú, caída y loot estables. Terreno con escalón máximo de 1 tile; 6 enemigos terrestres activos. |
| Siguiente paso | F5 de T-0039..T-0049, T-0051, T-0052 y T-0053 (pociones e iconos de pasivas). Quedan las 4 filas del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. T-0001 queda absorbido por T-0019 (port manual, sin merge) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `buffy` | Sin confirmar desde `28050dd` | — |
| `opencode-jorge` | T-0053 correcciones de iconos de pasivas (hecho, pendiente de F5) | `resources/*.tres`, `docs/items.md`, `docs/pasivas-cambios-2026-11-13.png` |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-12 | T-0049 | `max_step_tiles` (1) en el generador: fuera paredes de 4 tiles, costuras exactas; F5 pendiente |
| 2026-11-10 | T-0048 | Overlay de debug con `pos`/`tile`/seed y Nueva partida pide semilla; F5 pendiente |
| 2026-11-10 | T-0047 | Cámara del menú en la posición del spawn; F5 pendiente |
| 2026-11-10 | T-0046 | Fullscreen sin bandas con escala entera y viewport adaptativo; F5 pendiente |
| 2026-11-10 | T-0045 | Fuera `STRETCH_FRACTIONAL`: parallax sin tirones; F5 pendiente |
| 2026-11-10 | T-0044 | Biomas por tramos y mundo solo hacia la derecha; F5 pendiente |
| 2026-11-10 | T-0043 | `blood_color` por enemigo; F5 pendiente |
| 2026-11-10 | T-0042 | Pausa, ajustes compartidos y guardado; F5 pendiente |
| 2026-11-10 | T-0041 | Menú principal con ajustes; F5 pendiente |
| 2026-11-10 | T-0040 | `MountainBase` tintado con el `forest_color` del bioma; F5 pendiente |
| 2026-11-10 | T-0039 | Caída inicial más corta; F5 pendiente |
| 2026-11-10 | T-0038 | 3 consumibles con teclas 1-3 y catálogo completo en `docs/items.md`; F5 pendiente |

## Riesgos vivos

- La rama del compañero sale de `58c4a0f` (2026-10-15), **antes** del mundo por chunks y de los arreglos de cámara: un merge ciego pierde T-0009/T-0010 y vuelve a `enemy_counts_per_zone`.
- `AGENTS.md` llama legacy a `item_pickup.gd/.tscn`, pero es el pickup **vivo** (`scripts/enemies/enemy_base.gd:54`). No borrar (T-0004).
- El proyecto no tiene tests: toda verificación es en editor (F5) o con un script headless desechable.
- 16 enemigos por chunk maduro y el doble de densidad en general: si baja el rendimiento, `enemy_ramp_max_multiplier` es la palanca.
- El tope de pendiente hace que las alturas encadenen desde la columna 0: no recalcular una columna suelta sin su predecesora (rompe la costura). `_clamped_last` es la semilla de la cadena.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y quitarlos de `DISABLED_ENEMY_SCENES`.
