# Estado del proyecto

_Actualizado 2026-11-12 por `buffy`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `feat/decor` (T-0057), pendiente de push/PR; `main` con la base documental commiteada |
| Árbol | T-0039..T-0048 (menús, guardado, biomas por tramos, sangre, fullscreen), T-0049 (tope de ±1), T-0051 (sin elevaciones exageradas por bioma), T-0052 (montaña en la barrera izquierda) y T-0053 (debug de velocidad mitad/doble/reset); T-0050 revertido; T-0057 (decoraciones de bioma). Ver `changelog.md` |
| Fase | Mundo procedural, cámara, menú, caída y loot estables. Terreno con escalón máximo de 1 tile y ningún bioma que exagere el relieve; 6 enemigos terrestres activos. |
| Siguiente paso | F5 de T-0039..T-0049 y T-0051 (menús/guardado, biomas, sangre, fullscreen y relieve). Quedan las 4 filas del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. T-0001 queda absorbido por T-0019 (port manual, sin merge) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `buffy` | T-0057 en revisión (decoraciones); T-0051..T-0055 pendientes de F5, T-0056 solo de revisión | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `resources/world/biomes/*.tres`, `assets/map/decor/` |
| `opencode-jorge` | — | — |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-12 | T-0057 | Decoraciones de bioma: arbustos, árboles y rocas por chunk detrás del suelo, grises tintados y `decor_colors` en los tres biomas; F5 pendiente |
| 2026-11-12 | T-0056 | Auditoría de documentación: `enemies`/`items` reescritos, `biomes`/`loot`/`passives` nuevos, mundo/UI/jugador/README al día y mapa en `vault/documentacion.md` |
| 2026-11-12 | T-0055 | Monedas arriba a la izquierda con icono: fuera los anchors de pantalla completa, rect fijo (26, 26) y `coin_icon` 16×16; F5 pendiente |
| 2026-11-12 | T-0054 | KP4/KP6 aterrizan 4 tiles sobre el suelo del destino (`ground_y_at()` + `refresh_chunks()`); F5 pendiente |
| 2026-11-12 | T-0052 | Barrera izquierda como montaña: 56 columnas pintadas, 2 escalones andando y paredes de 4 filas inescalables; F5 pendiente |
| 2026-11-12 | T-0053 | KP7 mitad, KP9 doble sin tope y KP8 reset a x1; `start_speed` en vez de `game_speed`; F5 pendiente |
| 2026-11-12 | T-0051 | Bosque rojo a 0.95/1.0: fuera las montañas de 30–40 tiles y las rampas de 123 escalones; F5 pendiente |
| 2026-11-12 | T-0050 | Revertido: los suelos de 2 tiles eran demasiado frecuentes; vuelve el tope de ±1 de T-0049 |
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
- **Ningún bioma puede subir `terrain_amplitude_multiplier` ni `terrain_frequency_multiplier` por encima de 1.0**: con el tope de ±1 el suelo no puede seguir a un ruido más rápido o más alto y salen rampas de un escalón por columna (30–40 tiles de montaña, 123 escalones seguidos; T-0051). Un bioma solo aplana.
- El tope de pendiente hace que las alturas encadenen desde la columna 0: no recalcular una columna suelta sin su predecesora (rompe la costura). `_clamped_last` es la semilla de la cadena.
- La montaña de la izquierda (T-0052) no pasa por `_build_clamped_heights()`: es barrera, no terreno generado. Si alguien la mete en la cadena, el tope de ±1 la convierte en rampa escalable y deja de tapar el vacío.
- Volver a meter fantasma/demonio exige tocar a la vez `enemy_scenes` y `enemy_counts_per_chunk` (mismo orden) y quitarlos de `DISABLED_ENEMY_SCENES`.
