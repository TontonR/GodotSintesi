# Mundo — generación por zonas

_2026-10-20 · rama `feat/skills-and-complex-passives`_

## Qué hace y dónde vive

- `scripts/world_generator.gd` sobre un `TileMapLayer`: suelo plano de 16×16 en zonas de `zone_width_tiles` 250, cargando las 5 zonas alrededor del jugador (`zone_load_margin` 2).
- Suelo en `ground_level` 25 → **y=400**, con `ground_depth` 15 capas. Tiles: hierba `(1,0)`, relleno `(1,2)`.
- Escena de juego `scenes/game.tscn`; `project.godot` fija la main scene por `uid`.

## Población

- `enemy_scenes` (fantasma, orco) con `enemy_counts_per_zone` [4, 1] y 20 monedas por zona (`coin_scene`, `coin_ground_offset` 8).
- `safe_start_tiles` 15: el jugador aparece en `(248, 368)`.

## Capas y cámara

- Capas 2D: 1 mundo, 2 jugador, 3 enemigos, 4 ataque jugador. Viewport 384×216.
- El mundo es plano a propósito (sin ruido); la variedad viene de las zonas y sus enemigos.

## Trampas

- Lo colocado a y=0 queda fuera de cámara: el suelo está en y=400 (ver `docs/historial.md`).
- Si tocas `zone_width_tiles`, revisa también `enemy_counts_per_zone` y `safe_start_tiles`.
