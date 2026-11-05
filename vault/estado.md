# Estado del proyecto

_Actualizado 2026-11-05 por `buffy`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `main` en `a914593` (2026-10-29, *Fix enemy loot drop placement*) |
| Árbol | commits locales: T-0022 (juego), T-0023/T-0024 (biomas y fondos) y T-0025 (gris medio + verde original); sin push |
| Fase | Mundo procedural, cámara, menú, caída y loot estables. 6 enemigos terrestres activos; los voladores (fantasma y demonio) aparcados. |
| Siguiente paso | F5 de T-0022 (pickups/pasivas) y T-0023 (biomas por bloque), más el arranque, el reparto de enemigos y la banda `#283D43`. Quedan las 4 filas del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. T-0001 queda absorbido por T-0019 (port manual, sin merge) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `buffy` | T-0025 gris medio + verde original de la pradera (hecho, pendiente de F5); T-0022/T-0023/T-0024 también pendientes de F5 | `assets/map/background/*_gray.png`, `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/biomes/*.tres` |
| `opencode-jorge` | Sin confirmar desde este repo | — |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-05 | T-0025 | Fondos con gris medio y `forest_color`: pradera con el verde original, bosque rojo rojo |
| 2026-11-05 | T-0024 | Fondos grises claros solo de vegetación, overlay de montaña sin tocar la punta y relieve por bioma |
| 2026-11-05 | T-0023 | Bioma y césped por bloque con transición de 256 bloques; más bosque rojo |
| 2026-11-05 | T-0022 | KP5 inmortal, pasivas sin stack (ni drop ni recogida) y caducidad de pickups 25/30/60 s |
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
