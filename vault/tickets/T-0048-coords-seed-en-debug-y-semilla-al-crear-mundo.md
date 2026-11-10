# T-0048 · Coords y seed en el debug + semilla al crear mundo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | ui / mundo / debug |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0015, T-0041, T-0042 |

## Problema

1. La etiqueta de debug de abajo a la izquierda solo enseñaba velocidad e inmortalidad: no
   había forma de saber dónde estabas ni con qué semilla se había generado el mundo.
2. Nueva partida generaba el mundo con `world_seed = 0` (aleatoria) sin dejar elegirla, así
   que un mundo bueno no se podía volver a jugar.

## Plan

1. `scripts/debug_tools.gd`: segunda línea con `pos` en píxeles, `tile` y `seed`
   (`WorldGenerator.current_seed()`), reconstruida solo cuando cambia.
2. `Menu/SeedDialog` en `main_menu.tscn`: `LineEdit` con `Empty = random` y botones
   **Back** / **Start** (Enter también arranca, Esc retrocede). Vacío o no numérico = 0
   (aleatoria).
3. Transporte entre escenas con `SaveGame.pending_seed` (estático, igual que
   `pending_load`); `WorldGenerator._ready()` lo consume y lo limpia.
4. Documentar en `docs/ui.md` (diálogo + overlay) y `docs/world.md` (seed desde el menú).

## Criterios de aceptación

- [x] El overlay muestra píxeles, tiles y la seed real de la partida.
- [x] Nueva partida pide semilla; vacío = aleatoria.
- [x] La seed escrita en el menú genera exactamente ese mundo (`_seed`/`_noise.seed`).
- [x] Continuar sigue usando la seed guardada (`pending_load` manda).
- [ ] F5: escribir una seed, verla en el overlay y que el mundo se repita al reintroducirla.

## Resultado

`scripts/debug_tools.gd`, `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`,
`scripts/save_game.gd` y `scripts/world_generator.gd`. El orden en `_ready()` del generador
es: aleatoria → `pending_seed` → `pending_load`, así que Continue nunca pisa la seed
guardada con una del menú (el menú limpia ambas al pulsar Nueva partida). F5 pendiente.
