# T-0066 · Biomas más cortos, estamina más duradera y monedas fuera del suelo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world / player / loot |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0030 (física de monedas), T-0044 (biomas por tramos) |

## Problema

Ruben: los biomas duran demasiado; la estamina se agota muy rápido corriendo y
guardando; y algunas monedas aparecen enterradas bajo el suelo.

## Causa

- `scripts/world_generator.gd`: los tramos se sorteaban entre 1024 y 4096 tiles
  (4–16 chunks), así que un bioma podía ocupar media pantalla de mundo.
- `scripts/player.gd`: correr costaba 10 + 10/s y guardar 15 + 20/s; la barra de
  100 se vaciaba en ~4 s guardando.
- `scripts/collectables/coin.gd`: el rayo de suelo partía del centro de la moneda.
  Un drop de enemigo nace en `global_position + loot_drop_y` (±15 px), a veces
  dentro del tile; un rayo que arranca dentro de un colisionador no detecta nada,
  así que tras 30 intentos la moneda se asentaba donde estaba, enterrada.

## Plan

1. Bajar `min_biome_tiles` a 512 (2 chunks) y `max_biome_tiles` a 2048 (8 chunks).
2. Abaratar carrera y guardia: 7 + 6/s y 10 + 12/s.
3. Lanzar el rayo de suelo desde 64 px sobre la moneda y alargar el alcance en esa
   misma distancia, para que una moneda enterrada aflore a la superficie.

## Criterios de aceptación

- [x] Los biomas duran entre 2 y 8 chunks; siguen sin solaparse dos transiciones.
- [x] Correr y guardar consumen menos estamina (más segundos por barra).
- [x] Una moneda que nace dentro del suelo sube a la superficie al detectar el suelo.
- [x] `docs/world.md`, `docs/biomes.md`, `docs/player.md` y `docs/loot.md` al día.
- [ ] F5: notar la duración de los biomas y la estamina; ver monedas de drops de pie.

## Resultado

- `scripts/world_generator.gd`: `min_biome_tiles` 512, `max_biome_tiles` 2048
  (antes 1024/4096). La transición de 256 tiles sigue siendo menor que el tramo
  mínimo de 512.
- `scripts/player.gd`: `run_initial_cost` 7, `run_drain_per_second` 6,
  `guard_initial_cost` 10 y `guard_drain_per_second` 12 (antes 10/10/15/20).
  La regeneración sigue en 10/s y el reembolso del parry en 30.
- `scripts/collectables/coin.gd`: `GROUND_PROBE_ABOVE` (64 px); `_find_ground()`
  castea desde `global_position - (0, 64)` con alcance 1088 y, si la moneda está
  por debajo de la superficie, `_settle()` la sube al borde del tile.
- Sin ejecutar Godot (regla de `AGENTS.md`): cambios de constantes y un rayo;
  revisión del diff. F5 pendiente.
