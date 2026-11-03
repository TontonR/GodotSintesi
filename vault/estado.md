# Estado del proyecto

_Actualizado 2026-11-03 por `buffy`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `main` en `a914593` (2026-10-29, *Fix enemy loot drop placement*) |
| Árbol | limpio: día/noche (T-0014), debug (T-0015), noche (T-0016), 9 pasivas de ogro/lobo (T-0017), menú + caída (T-0018), enemigos/loot del compañero (T-0019), arranque/drops/dificultad (T-0020) y voladores/reparto/banda (T-0021) en un commit local |
| Fase | Mundo procedural, cámara, menú, caída y loot estables. 6 enemigos terrestres activos; los voladores (fantasma y demonio) aparcados. |
| Siguiente paso | F5 del arranque (caída de ~1,7 s sin tirón), del reparto de enemigos y de la banda `#283D43`. Quedan las 4 filas del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. T-0001 queda absorbido por T-0019 (port manual, sin merge) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `buffy` | T-0021 voladores fuera + reparto + banda bajo montañas (hecho, pendiente de F5) | `scripts/world_generator.gd`, `scenes/main_menu.tscn`, `scenes/game.tscn` |
| `opencode-jorge` | Sin confirmar desde este repo | — |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-03 | T-0021 | Fantasma y demonio fuera, enemigos repartidos en huecos y banda `#283D43` bajo las montañas |
| 2026-11-03 | T-0020 | Caída sin tirón, drops raros, 6 objetos originales desactivados, enemigos ×1.35/×1.25 y más densidad |
| 2026-11-03 | T-0019 | 6 enemigos del compañero, 19 objetos nuevos y loot por enemigo con calidad |
| 2026-11-03 | T-0018 | Nombre OffBeaten Path, menú principal y caída desde el cielo |
| 2026-11-03 | T-0017 | 9 pasivas de ogro y lobo: recursos y efectos (drops pendientes) |
| 2026-11-03 | T-0016 | Noche: estrellas, montañas oscuras y velo negro del 10% |
| 2026-11-03 | T-0015 | Debug: velocidad x1/x5/x20 (KP7/8/9) y viaje rápido (KP4/6) |
| 2026-11-03 | T-0014 | Ciclo día/noche: día 5 min, noche 3 min, solo color de fondo |
| 2026-10-29 | T-0009 | Cámara: suavizado, redondeo a píxel, lag y subida de escalón |
| 2026-10-29 | T-0010 | Escala entera de ventana y fullscreen (2× exactos) |
| 2026-10-29 | T-0011 | Loot de enemigos y colocación de drops |
| 2026-10-22 | T-0012 | Inventario de 5 huecos, pasivas paginadas y `InventorySlot` |
| 2026-10-25 | T-0013 | Mundo procedural por chunks con persistencia de spawns |

## Riesgos vivos

- La rama del compañero sale de `58c4a0f` (2026-10-15), **antes** del mundo por chunks y de los arreglos de cámara: un merge ciego pierde T-0009/T-0010 y vuelve a `enemy_counts_per_zone`.
- `AGENTS.md` llama legacy a `item_pickup.gd/.tscn`, pero es el pickup **vivo** (`scripts/enemies/enemy_base.gd:54`). No borrar (T-0004).
- El proyecto no tiene tests: toda verificación es en editor (F5) o con `_diag.gd`.
- 16 enemigos por chunk maduro y el doble de densidad en general: si baja el rendimiento, `enemy_ramp_max_multiplier` es la palanca.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y quitarlos de `DISABLED_ENEMY_SCENES`.
