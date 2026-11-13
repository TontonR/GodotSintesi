# Estado del proyecto

_Actualizado 2026-11-13 por `buffy`_

## Ahora mismo

| Campo | Valor |
|---|---|
| Rama | `feat/decor` (T-0057, segunda pasada) con [PR #1](https://github.com/TontonR/GodotSintesi/pull/1); `main` local con 3 commits sobre `origin/main` |
| Árbol | T-0039..T-0048 (menús, guardado, biomas por tramos, sangre, fullscreen), T-0049 (tope de ±1), T-0051 (sin elevaciones exageradas por bioma), T-0052 (montaña en la barrera izquierda) y T-0053 (debug de velocidad mitad/doble/reset); T-0050 revertido; T-0057 (decoraciones de bioma, cuarta pasada), T-0058 (atravesar enemigos cuesta vida), T-0059 (pantalla de muerte), T-0060 (tres slots de guardado con aviso de sobrescritura), T-0061 (contador de metros), T-0062 (el parry aturde al lobo), T-0063 (cimas blancas en la nieve) y T-0064 (el lobo ya no se congela y elige embestida o salto tras el stun). Ver `changelog.md` |
| Fase | Mundo procedural, cámara, menú, caída y loot estables. Terreno con escalón máximo de 1 tile y ningún bioma que exagere el relieve; 6 enemigos terrestres activos. |
| Siguiente paso | F5 de T-0039..T-0049 y T-0051 (menús/guardado, biomas, sangre, fullscreen y relieve). Quedan las 4 filas del arquero (`vault/pasivas/arquero.md`) |
| Bloqueos | Ninguno técnico. T-0001 queda absorbido por T-0019 (port manual, sin merge) |

## Foco por agente

| Agente | Trabajando en | Ficheros que toca |
|---|---|---|
| `buffy` | T-0057 (decoraciones, cuarta pasada), T-0058 (atravesar enemigos), T-0059 (muerte), T-0060 (slots), T-0062 (parry del lobo), T-0063 (cimas nevadas) y T-0064 (recuperación y stun del lobo) y T-0065 (catálogo de enemigos e items con estado y skills), todo en revisión; T-0051..T-0055 pendientes de F5, T-0056 solo de revisión | `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `scripts/fx.gd`, `scripts/player.gd`, `scripts/game.gd`, `scripts/save_game.gd`, `scripts/ui/{main_menu,pause_menu,death_screen}.gd`, `resources/world/biomes/*.tres`, `scenes/enemies/{slime,skeleton,archer}.tscn`, `scripts/enemies/{enemy_base,werewolf}.gd`, `scenes/{main_menu,game}.tscn`, `scenes/ui/death_screen.tscn`, `assets/map/decor/`, `vault/enemies.md`, `vault/enemies/`, `vault/items.md`, `vault/items/`, `.opencode/skills/estado-enemigos/`, `.opencode/skills/estado-items/`, `.agents/skills/` |
| `opencode-jorge` | — | — |

> Al reclamar un ticket, añade aquí tu firma y los ficheros. Al soltarlo, bórralo.

## Últimos cierres

| Fecha | Ticket | Qué |
|---|---|---|
| 2026-11-13 | T-0064 | Lobo: faltaba `State.RECOVER` en el `match` y se quedaba quieto para siempre tras la primera embestida; al salir del stun elige embestida o salto (`stun_jump_chance` 0.5); verificado headless, F5 pendiente |
| 2026-11-13 | T-0063 | Cimas de montaña: capa `mountains/Sprite2DSnow` regenerada con los tres tonos de roca (`Biome.snow_color` + `snow_tint_paths`); blanca en la nieve y con el color original (±5 %) más un mini toque de prado/bosque rojo en el resto; verificado headless, F5 pendiente |
| 2026-11-13 | T-0062 | Lobo: el parry perfecto lo aturde 0.8 s (`Player.parried`), embestida a 140 y fuera el daño de contacto genérico encima del suyo; verificado headless, F5 pendiente |
| 2026-11-13 | T-0061 | Contador de metros arriba al centro (`UILayer/Meters`, `meters_at()`, `[run] meters` en el guardado y en Load); verificado headless 0→10 m |
| 2026-11-13 | T-0060 | Aviso de sobrescritura: sin hueco libre, New Game pide qué run reemplazar; Load con metros y monedas; F5 pendiente |
| 2026-11-13 | T-0059 | Arreglo: el editor borró `DeathScreen` de `game.tscn` y la pantalla no salía; nodo devuelto + `_ensure_death_screen()`; verificado headless (`visible`, `paused`) |
| 2026-11-13 | T-0060 | Revisión de UX del guardado: menú New Game/Continue + botón Load con los 3 slots; Continue = `latest_slot()` y New Game = primer hueco o el más antiguo; F5 pendiente |
| 2026-11-13 | T-0060 | Guardado en tres slots: `user://run_slot_N.cfg`, menú con filas Play/Erase y `SaveGame.current_slot`; F5 pendiente |
| 2026-11-13 | T-0059 | Pantalla de muerte y fin de run: `player.died`, borrado del slot y `DeathScreen`; sin revivir; F5 pendiente |
| 2026-11-13 | T-0058 | Atravesar enemigos en vez de empujarlos: slime/esqueleto/arquero a `collision_mask` 1 y daño de contacto (5, 1 s por enemigo) en `player.gd`; F5 pendiente |
| 2026-11-13 | T-0057 | Cuarta pasada: vegetación nevada casi blanca (tintes 0.98/0.88/0.78, pesos 3/3/2); F5 pendiente |
| 2026-11-12 | T-0057 | Decoraciones de bioma, tercera pasada: troncos sin teñir (tinte por píxel solo en hojas), separación mínima de 3 tiles, densidad 20/26/10 y nieve con 40% de árboles muertos; F5 pendiente |
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
- El bosque rojo pone 26 sprites de decorado por chunk y algunos se tocan a propósito (copa densa): si el rendimiento cae, `decor_per_chunk` del bioma es la palanca antes que tocar el código.
- El tinte de la vegetación se genera por píxel en runtime y se cachea por textura + color; añadir muchos colores nuevos sube un poco la memoria, pero no el coste por frame.
