# T-0061 · Contador de metros (bloques) arriba al centro

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0060 |

## Problema

No había forma de saber cuánto se había avanzado: el HUD solo mostraba vida,
stamina, monedas y pasivas. Ruben quiere un contador de metros (bloques) arriba
al centro, y que las partidas guardadas muestren ese dato al cargarlas.

## Plan

1. `WorldGenerator.meters_at(world_x)`: distancia en bloques desde el spawn
   (`safe_start_tiles` 50 × 16 + 8), negativa por detrás del inicio.
2. `UILayer/Meters`: `Label` centrado arriba (y 6…26, 16 px, blanco con sombra).
3. `Game._process()` lee la X del jugador, pide los metros al generador y solo
   reescribe el texto cuando cambia el bloque.
4. Guardado: `[run] meters` en cada slot; `SaveGame.slot_summary()` lo expone y,
   para slots viejos, lo deriva de `position` con `SPAWN_X` (808).
5. `main_menu.gd`: las filas de Load muestran `M m · C coins` en vez de la seed.

## Criterios de aceptación

- [x] El contador está arriba al centro, arranca en `0 m` y avanza con la X.
- [x] Se oculta con el HUD durante la caída inicial y no tapa vida/stamina.
- [x] `meters_at()` devuelve negativos detrás del spawn.
- [x] El guardado escribe `meters` y Load lo muestra con las monedas.
- [ ] F5: recorrer el mundo y comprobar el contador y las filas de Load.

## Resultado

- `scripts/world_generator.gd`: `meters_at(world_x)` junto a `current_seed()`.
- `scenes/game.tscn`: nodo `UILayer/Meters` (Label anclado al centro superior).
- `scripts/game.gd`: `_process()` con `label.text` cacheado.
- `scripts/save_game.gd`: `SPAWN_X` (808), `[run] meters` en `save_run()` y
  `slot_summary()` con fallback `_meters_from_position()`.
- `scripts/ui/main_menu.gd`: filas de Load con metros y monedas.
- Comprobado con Godot headless (script desechable): spawn = `0 m` y tras mover
  al jugador 160 px el label pasa a `10 m`. F5 visual pendiente.
