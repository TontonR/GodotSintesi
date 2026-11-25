# T-0094 — Refactor: separar responsabilidades de world_generator.gd

_Creado 2026-11-25 · rama `refactor/world-split`_

## Problema

`world_generator.gd` tiene 1654 líneas y mezcla sin separación:
- Gestión de chunks (carga/descarga/streaming)
- Generación de terreno (noise, alturas, left wall)
- Lógica de biomas (runs, transiciones, colores)
- Lógica de decoración (pick, tinting, foliage)
- Spawning de entidades (enemigos, coins, crates, structures)

Esto dificulta el mantenimiento, la lectura y el testeo.

## Solución

Extraer tres clases auxiliares que `WorldGenerator` instancia e invoca. No hay cambio de comportamiento.

| Clase nueva | Archivo | Responsabilidad |
|---|---|---|
| `WorldBiomeManager` | `scripts/world/world_biome_manager.gd` | Runs de biomas, transiciones, colores, terreno mixto |
| `WorldDecorManager` | `scripts/world/world_decor_manager.gd` | Pick de decor, foliage tinting, dead tree ratio |
| `WorldSpawner` | `scripts/world/world_spawner.gd` | Spawn de enemigos, coins, structures, crates en un chunk |

`WorldGenerator` mantiene: chunk streaming, terrain height, left wall, `_generate_chunk`, API pública (`ground_y_at`, `biome_at_world_x`, etc.). Sin cambios de señales ni exports visibles desde escena.

## Criterios de éxito

- El mundo se genera igual con la misma semilla antes y después.
- No hay errores en el output de Godot.
- `world_generator.gd` queda < 700 líneas.
- Cada archivo nuevo < 400 líneas.

## Estado

- [ ] Extraer `WorldBiomeManager`
- [ ] Extraer `WorldDecorManager`  
- [ ] Extraer `WorldSpawner`
- [ ] Limpiar `world_generator.gd`
- [ ] Verificar sin errores
- [ ] Commitear y PR

## Archivos tocados

- `scripts/world_generator.gd`
- `scripts/world/world_biome_manager.gd` (nuevo)
- `scripts/world/world_decor_manager.gd` (nuevo)
- `scripts/world/world_spawner.gd` (nuevo)
